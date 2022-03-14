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
        case placeLocationNotFound
        case userLocationNotFound
        case failedToBuildRoute
    }
    
    func showPredefinedAlert(type: PredefinedAlertType) {
        var title = ""
        var message = ""
        
        switch type {
        case .locationServicesUnavailable:
            title = "😥 Сервисы геолокации отключены"
            message = "Включите сервисы геолокации в настройках"
        case .locationAccessDenied:
            title = "😥 Доступ к геопозиции отключен"
            message = "Разрешите приложению доступ к геопозиции"
        case .placeLocationNotFound:
            title = "😥 Ошибка"
            message = "Не удалось определить адрес"
        case .userLocationNotFound:
            title = "😥 Ошибка"
            message = "Не удалось определить вашу геопозицию"
        case .failedToBuildRoute:
            title = "😥 Ошибка"
            message = "Не удалось построить маршрут"
        }
        
        if !message.isEmpty || !title.isEmpty {
            showAlert(title: title, message: message)
        }
    }
    

}
