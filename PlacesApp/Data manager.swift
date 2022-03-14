//
//  Data manager.swift
//  PlacesApp
//
//  Created by Сашок on 13.03.2022.
//

import Foundation
import UIKit

class DataManager {
    
    static let shared = DataManager()
    
    func createTempData(completion: @escaping () -> Void) {
        if !UserDefaults.standard.bool(forKey: "TempData") {
            
            let bolshoi = Place(name: "Большой театр", location: "Театральная площадь, 1, Москва, Россия", type: "Театр", imageData: nil, rating: 5)
            if let bolshoiImage = UIImage.init(named: "Bolshoi") {
                bolshoi.imageData = bolshoiImage.pngData()
            }

            let mcDonalds = Place(name: "McDonalds", location: "Газетный переулок, 17, Москва, Россия", type: "Фастфуд", imageData: nil, rating: 5)
            if let mcDonaldsImage = UIImage.init(named: "McDonalds") {
                mcDonalds.imageData = mcDonaldsImage.pngData()
            }
            
            let mipt = Place(name: "МФТИ", location: "Институтский пер., 9, Долгопрудный, Россия", type: "Университет", imageData: nil, rating: 5)
            if let miptImage = UIImage.init(named: "MIPT") {
                mipt.imageData = miptImage.pngData()
            }
            
            let tretyakov = Place(name: "Третьяковская галерея", location: "Лаврушинский пер., 10, стр. 4, Москва, Россия", type: "Музей", imageData: nil, rating: 5)
            if let tretyakovImage = UIImage.init(named: "Tretyakov") {
                tretyakov.imageData = tretyakovImage.pngData()
            }

            
            let zaryadye = Place(name: "Зарядье", location: "ул. Варварка, 6, стр. 1, Москва, Россия", type: "Парк", imageData: nil, rating: 5)
            if let zaryadyeImage = UIImage.init(named: "Zaryadye") {
                zaryadye.imageData = zaryadyeImage.pngData()
            }
            
            let places = [bolshoi, mcDonalds, mipt, tretyakov, zaryadye]

            DispatchQueue.main.async {
                StorageManager.shared.saveObjects(places)
                UserDefaults.standard.set(true, forKey: "TempData")
                completion()
            }
        }
    }
    
    private init() {}
}
