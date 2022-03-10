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
    
    func checkLocationServices(mapView: MKMapView, segueId: String, closure: () -> Void) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueId: segueId)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services are disabled",
                               message: "Please enable location services")
            }
        }
    }
    
    func checkLocationAuthorization(mapView: MKMapView, segueId: String) {
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            fallthrough
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services are disabled",
                               message: "Please enable location services")
            }
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueId == "getAddress" {
                showUserLocation(mapView: mapView)
            }
        @unknown default:
            print("unknown case")
        }
    }
    
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionDeltaMeters,
                                            longitudinalMeters: regionDeltaMeters)

            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> Void) {
        
        guard let coordinate = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        guard let request = createDirectionsRequest(from: coordinate) else {
            showAlert(title: "Error", message: "Failed to build route")
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
                self.showAlert(title: "Error", message: "Failed to build route")
                return
            }
            
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "$.1f", route.distance / 1000)
                let time = route.expectedTravelTime
                
                print("Distance: \(distance)km")
                print("Time: \(time)s")
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else {
            return nil
        }
        
        let startingLocation = MKPlacemark(coordinate: coordinate)
        
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.destination = MKMapItem(placemark: destination)
        request.source = MKMapItem(placemark: startingLocation)
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
    
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 100
        alertWindow.makeKeyAndVisible()
        
        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
}
