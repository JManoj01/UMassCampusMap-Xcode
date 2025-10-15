import Foundation
import MapKit
import Combine

class MapViewModel: ObservableObject {
    @Published var locations: [CampusLocation] = []
    @Published var selectedLocation: CampusLocation?
    
    init() {
        loadLocations()
    }
    
    func loadLocations() {
        locations = [
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
            if let selectedIndex = selectedLocation?.id, selectedIndex == location.id {
                selectedLocation = locations[index]
            }
        }
    }
    
    func centerOnCampus() {
    }
    
    var favoriteLocations: [CampusLocation] {
        locations.filter { $0.isFavorite }
    }
}
