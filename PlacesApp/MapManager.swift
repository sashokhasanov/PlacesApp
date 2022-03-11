//
//  MapManager.swift
//  PlacesApp
//
//  Created by Сашок on 10.03.2022.
//

import Foundation
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let regionDeltaMeters = 1000.0
    
    private var directions: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?

    func setupPlacemark(place: Place, mapView: MKMapView) {
        
        guard let placeLocation = place.location else {
            return
        }
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(placeLocation) { placemarks, error in
            guard error == nil else {
                print(error as Any)
                return
            }
            
            guard let placemarkLocation = placemarks?.first?.location else {
                return
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            AlertSevice.shared.showPredefinedAlert(type: .locationServicesUnavailable)
        }
    }
    
    func checkLocationAuthorization() {
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            AlertSevice.shared.showPredefinedAlert(type: .locationAccessDenied)
            
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            
        @unknown default:
            print("unknown case")
        }
    }
    
    func showUserLocation(mapView: MKMapView) {
        
        guard let location = locationManager.location?.coordinate else {
            AlertSevice.shared.showPredefinedAlert(type: .locationNotFound)
            return
        }
        
        let region = MKCoordinateRegion(center: location,
                                        latitudinalMeters: regionDeltaMeters,
                                        longitudinalMeters: regionDeltaMeters)

        mapView.setRegion(region, animated: true)
    }
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> Void) {
        
        guard let coordinate = locationManager.location?.coordinate else {
            AlertSevice.shared.showPredefinedAlert(type: .locationNotFound)
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        guard let request = createDirectionsRequest(from: coordinate) else {
            AlertSevice.shared.showPredefinedAlert(type: .failedToBuildRoute)
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(with: directions, mapView: mapView)
        
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                AlertSevice.shared.showPredefinedAlert(type: .failedToBuildRoute)
                return
            }
            
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//
//                let distance = String(format: "$.1f", route.distance / 1000)
//                let time = route.expectedTravelTime
//
//                print("Distance: \(distance)km")
//                print("Time: \(time)s")
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else {
            return nil
        }
        
        let sourcePlacemark = MKPlacemark(coordinate: coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    func startTrackingUserLocation(for mapView: MKMapView, previousLocation: CLLocation?, closure: (_ currentLocation: CLLocation) -> Void) {
        guard let previousLocation = previousLocation else {
            return
        }
        
        let center = getCenterLocation(for: mapView)
        
        guard center.distance(from: previousLocation) > 50 else {
            return
        }
        
        closure(center)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func resetMapView(with newDirections: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directions.append(newDirections)
        let _ = directions.map { $0.cancel() }
        directions.removeAll()
        
    }
}
