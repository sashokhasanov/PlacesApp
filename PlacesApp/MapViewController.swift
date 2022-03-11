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
    func setUpAddress(address: String?)
}

class MapViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    let locationManager = CLLocationManager()
    
    let mapManager = MapManager()
    var place: Place = Place()
    var delegate: MapViewControllerDelegate?
    
    let annotationId = "placeAnnotationId"
    
    var incomeSegueId = ""
    
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, previousLocation: previousLocation) { currentLocation in
                self.previousLocation = currentLocation
        
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
        
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        mapManager.checkLocationServices()
        
        if incomeSegueId == "showPlace" {
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
        mapManager.getDirections(for: mapView) { location in
            self.previousLocation = location
        }
    }
    
    //  MARK: - Private methods
    private func setupViewController() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        setupMapManager()

        if incomeSegueId == "showPlace" {
            routeButton.isHidden = false
        } else {
            mapPinImage.isHidden = false
            doneButton.isHidden = false
            blurView.isHidden = false
            addressLabel.text = ""
        }
    }
    
    private func setupMapManager() {
        mapManager.locationManager.delegate = self
        mapManager.locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        let center = mapManager.getCenterLocation(for: mapView)
        
        let geocoder = CLGeocoder()
        
        if incomeSegueId == "showPlace", previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.mapManager.showUserLocation(mapView: self.mapView)
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

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if incomeSegueId == "getAddress" {
            mapManager.showUserLocation(mapView: mapView)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

extension MapViewController {
    enum Mode {
        case showPlace
        case selectAddress
    }
}
