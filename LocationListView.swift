import SwiftUI

struct LocationListView: View {
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var filterCategory: LocationCategory?
    @State private var showFavoritesOnly = false
    
    var filteredLocations: [CampusLocation] {
        var result = viewModel.locations
        
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        
        if let category = filterCategory {
            result = result.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            result = result.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.building.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search locations...", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // Filter Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: { showFavoritesOnly.toggle() }) {
                            HStack {
                                Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                                Text("Favorites")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(showFavoritesOnly ? Color.yellow : Color(.systemGray6))
                            .foregroundColor(showFavoritesOnly ? .white : .primary)
                            .cornerRadius(20)
                        }
                        
                        Button(action: { 
                            filterCategory = filterCategory == nil ? nil : nil 
                        }) {
                            Text("All")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(filterCategory == nil ? Color.blue : Color(.systemGray6))
                                .foregroundColor(filterCategory == nil ? .white : .primary)
                                .cornerRadius(20)
                        }
                        
                        ForEach(LocationCategory.allCases, id: \.self) { category in
                            Button(action: { 
                                filterCategory = filterCategory == category ? nil : category 
                            }) {
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(filterCategory == category ? category.color : Color(.systemGray6))
                                .foregroundColor(filterCategory == category ? .white : .primary)
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Location List
                List {
                    ForEach(filteredLocations) { location in
                        LocationRow(
                            location: location,
                            onTap: {
                                viewModel.selectedLocation = location
                                dismiss()
                            },
                            onToggleFavorite: {
                                viewModel.toggleFavorite(location: location)
                            }
                        )
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Campus Locations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LocationRow: View {
    let location: CampusLocation
    let onTap: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(location.category.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: location.category.icon)
                        .foregroundColor(location.category.color)
                        .font(.title3)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(location.building)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(location.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(location.category.color.opacity(0.2))
                        .foregroundColor(location.category.color)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                // Favorite Button
                Button(action: onToggleFavorite) {
                    Image(systemName: location.isFavorite ? "star.fill" : "star")
                        .foregroundColor(location.isFavorite ? .yellow : .gray)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}
