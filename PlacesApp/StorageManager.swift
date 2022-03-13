//
//  StorageManager.swift
//  PlacesApp
//
//  Created by Сашок on 01.03.2022.
//

import RealmSwift

class StorageManager {
    
    static let shared = StorageManager()
    
    let realm = try! Realm()
    
    private init() {}
    
    func saveObject(_ place: Place) {
        write {
            realm.add(place)
        }
    }
    
    func updateObject(_ place: Place, with newData: Place) {
        write {
            place.name = newData.name
            place.location = newData.location
            place.type = newData.type
            place.imageData = newData.imageData
            place.rating = newData.rating
        }
    }
    
    func deleteObject(_ place: Place) {
        write {
            realm.delete(place)
        }
    }
    
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
}
