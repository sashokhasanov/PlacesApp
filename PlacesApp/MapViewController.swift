//
//  MapViewController.swift
//  PlacesApp
//
//  Created by Сашок on 09.03.2022.
//

import UIKit
import MapKit
import CoreLocation

// MARK: - Protocol MapViewControllerDelegate
protocol MapViewControllerDelegate {
    func setUpAddress(address: String?)
}

// MARK: - MapViewController
class MapViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var clearRouteButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    let mapManager = MapManager()
    var place: Place = Place()
    var delegate: MapViewControllerDelegate?
    
    let annotationId = "placeAnnotationId"
    var controllerMode = Mode.showPlace
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if controllerMode == .showPlace {
            mapManager.setupPlacemark(place: place, mapView: mapView)
        }
    }
    
    // MARK: - IBActions
    @IBAction func closeButtonPressed() {
        dismiss(animated: true)
    }

    @IBAction func doneButtonPressed() {
        delegate?.setUpAddress(address: addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func userLocationButtonPressed() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func routeButtonPressed() {
        mapManager.getDirections(for: mapView)
    }
    
    //  MARK: - Private methods
    private func setupViewController() {
        
        if controllerMode == .showPlace {
            routeButton.isHidden = false
        } else {
            mapPinImage.isHidden = false
            doneButton.isHidden = false
            blurView.isHidden = false
            addressLabel.text = ""
        }
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        mapManager.attemptLocationAccess {
            mapManager.locationManager.delegate = self
            mapManager.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
}

// MARK: - MapViewController + Mode enum
extension MapViewController {
    enum Mode: String {
        case showPlace
        case getAddress
    }
}

// MARK: - MKMapViewDelegate
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        guard controllerMode == .getAddress else {
            return
        }
        
        let center = mapManager.getCenterLocation(for: mapView)
        
        let geocoder = CLGeocoder()
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

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else {
            return
        }
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard controllerMode == .getAddress else {
            return
        }
        manager.stopUpdatingLocation()
        mapManager.showUserLocation(mapView: mapView)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let error = error as? CLError else {
            return
        }
        
        manager.stopUpdatingLocation()
        
        switch error.code {
        case CLError.Code.locationUnknown:
            AlertSevice.shared.showPredefinedAlert(type: .locationNotFound)
        case CLError.Code.denied:
            AlertSevice.shared.showPredefinedAlert(type: .locationAccessDenied)
        default:
            print("Location manager error: \(error.localizedDescription)")
        }
    }
}


