//
//  StorageManager.swift
//  PlacesApp
//
//  Created by Сашок on 01.03.2022.
//

import RealmSwift

class StorageService {
    // MARK: - Internal properties
    static let shared = StorageService()
    
    let realm = try! Realm()
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Internal methods
    func saveObjects(_ places: [Place]) {
        write {
            realm.add(places)
        }
    }
    
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
    
    // MARK: - Private methods
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
