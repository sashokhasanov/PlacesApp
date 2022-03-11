//
//  UIApplication+topMostViewController.swift
//  PlacesApp
//
//  Created by Сашок on 11.03.2022.
//

import UIKit

extension UIApplication {
    
    static var topMostViewController: UIViewController? {
        let rootViewController =
            UIApplication.shared.connectedScenes.compactMap {
                ($0 as? UIWindowScene)?.windows.filter { $0.isKeyWindow }.first?.rootViewController
            }.first
        
        return rootViewController?.visibleViewController
    }
}
