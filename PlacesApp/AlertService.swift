//
//  AlertService.swift
//  PlacesApp
//
//  Created by Сашок on 11.03.2022.
//

import UIKit

class AlertSevice {
    static let shared = AlertSevice()

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        
        UIApplication.topMostViewController?.present(alert, animated: true)
    }
    
    private init(){}
}

extension AlertSevice {
    enum PredefinedAlertType {
        case locationServicesUnavailable
        case locationAccessDenied
        case locationNotFound
        case failedToBuildRoute
    }
    
    func showPredefinedAlert(type: PredefinedAlertType) {
        var title = ""
        var message = ""
        
        switch type {
        case .locationServicesUnavailable:
            title = "Location services are disabled"
            message = "Please enable location services"
        case .locationAccessDenied:
            title = "Error"
            message = "Please allow to use location"
        case .locationNotFound:
            title = "Error"
            message = "Location can't be found"
        case .failedToBuildRoute:
            title = "Error"
            message = "Failed to build route"
        }
        
        if !message.isEmpty || !title.isEmpty {
            showAlert(title: title, message: message)
        }
    }
    

}
