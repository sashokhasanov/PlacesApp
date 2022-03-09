//
//  NewPlaceViewController.swift
//  PlacesApp
//
//  Created by Сашок on 01.03.2022.
//

import UIKit
import Cosmos

class NewPlaceViewController: UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var ratingControl: RatingView!
    @IBOutlet weak var cosmosView: CosmosView!
    
    
    var currentPlace: Place?
    var imagePicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false;
        
        placeName.addTarget(self, action: #selector(placeNameChanged), for: .editingChanged)
        
        setupEditScreen()

    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let actions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(UIImage(named: "camera"), forKey: "image")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(UIImage(named: "photo"), forKey: "image")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actions.addAction(camera)
            actions.addAction(photo)
            actions.addAction(cancel)
            
            present(actions, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func savePlace() {

        var image: UIImage?
        
        if imagePicked {
            image = placeImage.image
        } else {
            image = UIImage(named: "imagePlaceholder")
        }

        let newPlace = Place(name: placeName.text ?? "",
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: image?.pngData(),
//                             rating: Double(ratingControl.rating)
                             rating: cosmosView.rating
        )
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen() {
        guard let currentPlace = currentPlace else {
            return
        }
        
        setupNavigationBar()
        
        placeName.text = currentPlace.name
        placeLocation.text = currentPlace.location
        placeType.text = currentPlace.type
//        ratingControl.rating = Int(currentPlace.rating)
        cosmosView.rating = currentPlace.rating
        
        if let data = currentPlace.imageData, let image = UIImage(data: data) {
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            imagePicked = true
        }
    }
    
    private func setupNavigationBar() {
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backButtonTitle = ""
        }
        
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
}

// MARK: - Text field delegate
extension NewPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func placeNameChanged() {
        saveButton.isEnabled = !(placeName.text?.isEmpty ?? true)
    }
}

// MARK: - Work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        imagePicked = true
        dismiss(animated: true)
    }
    
}
