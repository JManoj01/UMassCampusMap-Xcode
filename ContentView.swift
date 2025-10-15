import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var selectedCategory: LocationCategory? = nil
    @State private var showingLocationList = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Map View
                MapView(viewModel: viewModel, selectedCategory: $selectedCategory)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Category Filter Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryButton(
                                title: "All",
                                icon: "map.fill",
                                isSelected: selectedCategory == nil,
                                color: .blue
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(LocationCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category,
                                    color: category.color
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 60)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0.9), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                    )
                    
                    Spacer()
                }
                
                // Location Detail Sheet
                if let selectedLocation = viewModel.selectedLocation {
                    VStack {
                        Spacer()
                        LocationDetailCard(
                            location: selectedLocation,
                            onClose: { viewModel.selectedLocation = nil },
                            onToggleFavorite: { viewModel.toggleFavorite(location: selectedLocation) }
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("UMass Campus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingLocationList.toggle() }) {
                        Image(systemName: "list.bullet")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewModel.centerOnCampus() }) {
                        Image(systemName: "location.fill")
                    }
                }
            }
            .sheet(isPresented: $showingLocationList) {
                LocationListView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}
