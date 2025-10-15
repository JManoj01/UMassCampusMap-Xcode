import SwiftUI

struct LocationDetailCard: View {
    let location: CampusLocation
    let onClose: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: location.category.icon)
                            .font(.caption)
                        Text(location.category.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(location.category.color)
                }
                
                Spacer()
                
                Button(action: onToggleFavorite) {
                    Image(systemName: location.isFavorite ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(location.isFavorite ? .yellow : .gray)
                }
                .padding(.trailing, 8)
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Divider()
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(.gray)
                    Text(location.building)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(location.description)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        openInMaps(location: location)
                    }) {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Directions")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        shareLocation(location: location)
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
    
    private func openInMaps(location: CampusLocation) {
        let coordinate = location.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    private func shareLocation(location: CampusLocation) {
        let text = "\(location.name) - \(location.building)\n\(location.description)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
