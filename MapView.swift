import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    @Binding var selectedCategory: LocationCategory?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        
        // Center on UMass Amherst
        let center = CLLocationCoordinate2D(latitude: 42.391155, longitude: -72.526711)
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )
        mapView.setRegion(region, animated: false)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        
        // Filter locations based on selected category
        let locationsToShow = viewModel.filteredLocations(for: selectedCategory)
        
        // Add annotations
        let annotations = locationsToShow.map { location -> LocationAnnotation in
            let annotation = LocationAnnotation(location: location)
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let locationAnnotation = annotation as? LocationAnnotation else {
                return nil
            }
            
            let identifier = "LocationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }
            
            let location = locationAnnotation.location
            annotationView?.markerTintColor = UIColor(location.category.color)
            annotationView?.glyphImage = UIImage(systemName: location.category.icon)
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let locationAnnotation = view.annotation as? LocationAnnotation else {
                return
            }
            parent.viewModel.selectedLocation = locationAnnotation.location
        }
    }
}
