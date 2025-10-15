import Foundation
import MapKit
import SwiftUI

enum LocationCategory: String, CaseIterable {
    case studySpot = "Study Spot"
    case coffeeShop = "Coffee Shop"
    case lectureHall = "Lecture Hall"
    
    var icon: String {
        switch self {
        case .studySpot:
            return "book.fill"
        case .coffeeShop:
            return "cup.and.saucer.fill"
        case .lectureHall:
            return "building.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .studySpot:
            return .green
        case .coffeeShop:
            return .brown
        case .lectureHall:
            return .purple
        }
    }
}

struct CampusLocation: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let category: LocationCategory
    let coordinate: CLLocationCoordinate2D
    let description: String
    let building: String
    var isFavorite: Bool = false
    
    static func == (lhs: CampusLocation, rhs: CampusLocation) -> Bool {
        lhs.id == rhs.id
    }
}

class LocationAnnotation: NSObject, MKAnnotation {
    let location: CampusLocation
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(location: CampusLocation) {
        self.location = location
        self.coordinate = location.coordinate
        self.title = location.name
        self.subtitle = location.building
        super.init()
    }
}
