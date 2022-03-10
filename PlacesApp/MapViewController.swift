//
//  MapViewController.swift
//  PlacesApp
//
//  Created by Сашок on 09.03.2022.
//

import UIKit
import MapKit
import CoreLocation


protocol MapViewControllerDelegate {
    func getAddress(address: String?)
}

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var routeButton: UIButton!
    
    var place: Place = Place()
    let annotationId = "annotationId"
    let locationManager = CLLocationManager()
    
    let regionDeltaMeters = 1000.0
    
    var incomeSegueId = ""
    var placeCoordinate: CLLocationCoordinate2D?
    
    var delegate: MapViewControllerDelegate?
    var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    
    var directions: [MKDirections] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        
        mapView.delegate = self
        setupMapView()
        
        checkLocationServices()
    }
    
    @IBAction func routeButtonPressed() {
        getDirections()
    }
    
    
    @IBAction func closeMap() {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed() {
        delegate?.getAddress(address: addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func centerByUSerLocation() {
        showUserLocation()
    }
    
    private func startTrackingUserLocation() {
        guard let previousLocation = previousLocation else {
            return
        }
        
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation) > 50 else {
            return
        }
        
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
            
        }
    }
    
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            span: MKCoordinateSpan(latitudeDelta: regionDeltaMeters,
                                                                   longitudeDelta: regionDeltaMeters))
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func setupMapView() {
        
        routeButton.isHidden = true
        
        if incomeSegueId == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            routeButton.isHidden = false
        }
    }
    
    private func resetMapView(with newDirections: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        let _ = directions.map { $0.cancel() }
        directions.removeAll()
        
        directions.append(newDirections)
    }
    
    private func getDirections() {
        
        guard let coordinate = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        guard let request = createDirectionsReques(from: coordinate) else {
            showAlert(title: "Error", message: "Failed to build route")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(with: directions)
        
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
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "$.1f", route.distance / 1000)
                let time = route.expectedTravelTime
                
                print("Distance: \(distance)km")
                print("Time: \(time)s")
            }
        }
    }
    
    private func createDirectionsReques(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else {
            return nil
        }
        
        let startingLocation = MKPlacemark(coordinate: coordinate)
        
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.destination = MKMapItem(placemark: destination)
        request.source = MKMapItem(placemark: startingLocation)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func setupPlacemark() {
        
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
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
        
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location services are disabled",
                               message: "Please enable location services")
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
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
            if incomeSegueId == "showAddress" {
                showUserLocation()
            }
        @unknown default:
            print("unknown case")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        
        let geocoder = CLGeocoder()
        
        if incomeSegueId == "showPlace", previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                
                self.showUserLocation()
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {
                return
            }
            
            let placemark = placemarks.first
            
            let streetName = placemark?.thoroughfare
            let buildingNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                
                if streetName != nil && buildingNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildingNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    
    
}
