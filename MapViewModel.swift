import Foundation
import MapKit
import Combine
import CoreLocation

class MapViewModel: ObservableObject {
    @Published var locations: [CampusLocation] = []
    @Published var selectedLocation: CampusLocation?
    @Published var route: MKRoute?
    @Published var isCalculatingRoute = false
    @Published var userLocation: CLLocation?
    @Published var routeError: String?
    
    private let favoritesKey = "savedFavorites"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadLocations()
        loadFavorites()
    }
    
    func loadLocations() {
        locations = [
            // Study Spots
            CampusLocation(
                name: "W.E.B. Du Bois Library",
                category: .studySpot,
                coordinate: CLLocationCoordinate2D(latitude: 42.3907, longitude: -72.5285),
                description: "26-floor library with quiet study floors (2, 5, 8, 11, 14, 17, 20) and group study rooms. Scenic views from floor 23.",
                building: "154 Hicks Way"
            ),
            CampusLocation(
                name: "Science & Engineering Library",
                category: .studySpot,
                coordinate: CLLocationCoordinate2D(latitude: 42.3945, longitude: -72.5265),
                description: "Specialized library with group study rooms and technical resources for STEM students.",
                building: "740 N Pleasant St"
            ),
            CampusLocation(
                name: "Integrative Learning Center (ILC)",
                category: .studySpot,
                coordinate: CLLocationCoordinate2D(latitude: 42.3902, longitude: -72.5252),
                description: "Modern study spaces with collaborative work areas and technology resources.",
                building: "ILC"
            ),
            CampusLocation(
                name: "Campus Center Study Lounge",
                category: .studySpot,
                coordinate: CLLocationCoordinate2D(latitude: 42.3915, longitude: -72.5295),
                description: "Central location with comfortable seating and easy access to food options.",
                building: "Campus Center"
            ),
            CampusLocation(
                name: "Learning Commons - Du Bois",
                category: .studySpot,
                coordinate: CLLocationCoordinate2D(latitude: 42.3907, longitude: -72.5283),
                description: "Collaborative learning space with group study rooms and digital resources.",
                building: "Du Bois Library Lower Level"
            ),
            
            // Coffee Shops
            CampusLocation(
                name: "Peet's Coffee (ILC)",
                category: .coffeeShop,
                coordinate: CLLocationCoordinate2D(latitude: 42.3902, longitude: -72.5252),
                description: "Popular coffee chain located on the bottom floor of the ILC. Great for a quick caffeine fix before class.",
                building: "Integrative Learning Center"
            ),
            CampusLocation(
                name: "People's Organic Coffee",
                category: .coffeeShop,
                coordinate: CLLocationCoordinate2D(latitude: 42.3915, longitude: -72.5295),
                description: "Natural, organic coffee on the main concourse. Fair-trade and locally roasted.",
                building: "Campus Center"
            ),
            CampusLocation(
                name: "Procrastination Station Café",
                category: .coffeeShop,
                coordinate: CLLocationCoordinate2D(latitude: 42.3907, longitude: -72.5285),
                description: "Convenient café inside Du Bois Library. Perfect for study breaks.",
                building: "Du Bois Library"
            ),
            CampusLocation(
                name: "Worcester Café",
                category: .coffeeShop,
                coordinate: CLLocationCoordinate2D(latitude: 42.3935, longitude: -72.5308),
                description: "Fresh brewed coffee and breakfast items. Located on the first floor.",
                building: "Worcester Commons"
            ),
            
            // Lecture Halls
            CampusLocation(
                name: "Marston Hall",
                category: .lectureHall,
                coordinate: CLLocationCoordinate2D(latitude: 42.3928, longitude: -72.5268),
                description: "Engineering building with large lecture halls and classrooms. Home to Civil and Environmental Engineering.",
                building: "130 Natural Resources Rd"
            ),
            CampusLocation(
                name: "Integrated Sciences Building (ISB)",
                category: .lectureHall,
                coordinate: CLLocationCoordinate2D(latitude: 42.3948, longitude: -72.5263),
                description: "State-of-the-art science building with modern lecture halls and research labs.",
                building: "661 N Pleasant St"
            ),
            CampusLocation(
                name: "Machmer Hall",
                category: .lectureHall,
                coordinate: CLLocationCoordinate2D(latitude: 42.3918, longitude: -72.5273),
                description: "Large lecture halls for social sciences and humanities courses.",
                building: "240 Hicks Way"
            ),
            CampusLocation(
                name: "Bartlett Hall",
                category: .lectureHall,
                coordinate: CLLocationCoordinate2D(latitude: 42.3898, longitude: -72.5298),
                description: "Historic building with multiple lecture rooms and classrooms.",
                building: "130 Hicks Way"
            ),
            CampusLocation(
                name: "Hasbrouck Laboratory",
                category: .lectureHall,
                coordinate: CLLocationCoordinate2D(latitude: 42.3923, longitude: -72.5288),
                description: "Physics and astronomy building with lecture halls and lab spaces.",
                building: "140 Governors Dr"
            ),
            CampusLocation(
                name: "Computer Science Building",
                category: .lectureHall,
                coordinate: CLLocationCoordinate2D(latitude: 42.3951, longitude: -72.5265),
                description: "Home to the College of Information and Computer Sciences with lecture halls and lab spaces.",
                building: "140 Governors Dr"
            ),
            CampusLocation(
                name: "Isenberg School of Management",
                category: .lectureHall,
                coordinate: CLLocationCoordinate2D(latitude: 42.3890, longitude: -72.5255),
                description: "Business school with modern lecture halls and collaborative spaces.",
                building: "121 Presidents Dr"
            )
        ]
    }
    
    func filteredLocations(for category: LocationCategory?) -> [CampusLocation] {
        guard let category = category else {
            return locations
        }
        return locations.filter { $0.category == category }
    }
    
    func toggleFavorite(location: CampusLocation) {
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            locations[index].isFavorite.toggle()
            saveFavorites()
            
            if let selectedIndex = selectedLocation?.id, selectedIndex == location.id {
                selectedLocation = locations[index]
            }
        }
    }
    
    func locationsSortedByDistance() -> [CampusLocation] {
        guard let userLocation = userLocation else { 
            return locations.sorted { $0.name < $1.name }
        }
        
        return locations.sorted { location1, location2 in
            let distance1 = userLocation.distance(from: CLLocation(
                latitude: location1.coordinate.latitude,
                longitude: location1.coordinate.longitude
            ))
            let distance2 = userLocation.distance(from: CLLocation(
                latitude: location2.coordinate.latitude,
                longitude: location2.coordinate.longitude
            ))
            return distance1 < distance2
        }
    }
    
    func centerOnCampus() {
        selectedLocation = nil
        route = nil
    }
    
    func getWalkingDirections(from source: CampusLocation, to destination: CampusLocation) {
        isCalculatingRoute = true
        routeError = nil
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isCalculatingRoute = false
                
                if let error = error {
                    self?.routeError = "Could not calculate route: \(error.localizedDescription)"
                    self?.route = nil
                    return
                }
                
                guard let route = response?.routes.first else {
                    self?.routeError = "No route found"
                    self?.route = nil
                    return
                }
                
                self?.route = route
                self?.routeError = nil
            }
        }
    }
    
    func clearRoute() {
        route = nil
        routeError = nil
        isCalculatingRoute = false
    }
    
    func distanceToLocation(_ location: CampusLocation) -> String? {
        guard let userLocation = userLocation else { return nil }
        
        let distance = userLocation.distance(from: CLLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ))
        
        if distance < 1000 {
            return String(format: "%.0f m away", distance)
        } else {
            return String(format: "%.1f km away", distance / 1000)
        }
    }
    
    func walkingTimeToLocation(_ location: CampusLocation) -> String? {
        guard let userLocation = userLocation else { return nil }
        
        let distance = userLocation.distance(from: CLLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ))
        
        let timeInSeconds = distance / 1.4
        let minutes = Int(ceil(timeInSeconds / 60))
        
        if minutes < 1 {
            return "< 1 min walk"
        } else if minutes == 1 {
            return "1 min walk"
        } else {
            return "\(minutes) min walk"
        }
    }
    
    var favoriteLocations: [CampusLocation] {
        locations.filter { $0.isFavorite }
    }
    
    
    private func saveFavorites() {
        let favoriteIDs = locations.filter { $0.isFavorite }.map { $0.id.uuidString }
        UserDefaults.standard.set(favoriteIDs, forKey: favoritesKey)
    }
    
    private func loadFavorites() {
        guard let savedIDs = UserDefaults.standard.array(forKey: favoritesKey) as? [String] else { 
            return 
        }
        let savedUUIDs = savedIDs.compactMap { UUID(uuidString: $0) }
        
        for index in locations.indices {
            if savedUUIDs.contains(locations[index].id) {
                locations[index].isFavorite = true
            }
        }
    }
}
