//
//  NewPlaceViewController.swift
//  PlacesApp
//
//  Created by Сашок on 01.03.2022.
//

import UIKit
import Cosmos

class PlaceDetailsViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var ratingView: CosmosView!
    
    // MARK: - Internal properties
    var editedPlace: Place?
    var imagePicked = false
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeName.addTarget(self, action: #selector(placeNameChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        savePlace()
        performSegue(withIdentifier: "unwindSegue", sender: self)
    }
}

// MARK: - Navigation
extension PlaceDetailsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier, let mapViewController = segue.destination as? MapViewController else {
            return
        }
        
        if let mode = MapViewController.Mode(rawValue: segueId) {
            mapViewController.controllerMode = mode
        }
        
        mapViewController.delegate = self
        
        if segueId == "showPlace" {
            mapViewController.place.name = placeName.text ?? ""
            mapViewController.place.location = placeLocation.text
            mapViewController.place.type = placeType.text
            mapViewController.place.imageData = placeImage.image?.pngData()
        }
    }
}

// MARK: - Table view delegate
extension PlaceDetailsViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showImageActionsSheet()
        } else {
            view.endEditing(true)
        }
    }
}

// MARK: - Text field delegate
extension PlaceDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func placeNameChanged() {
        saveButton.isEnabled = !(placeName.text?.isEmpty ?? true)
    }
}

// MARK: - Image processing
extension PlaceDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

// MARK: - MapViewControllerDelegate
extension PlaceDetailsViewController: MapViewControllerDelegate {
    func setUpAddress(address: String?) {
        placeLocation.text = address
    }
}

// MARK: - Private methods
extension PlaceDetailsViewController {
    
    private func setupEditScreen() {
        guard let editedPlace = editedPlace else {
            return
        }
        
        setupNavigationBar()
        
        placeName.text = editedPlace.name
        placeLocation.text = editedPlace.location
        placeType.text = editedPlace.type
        ratingView.rating = editedPlace.rating
        
        if let imageData = editedPlace.imageData, let image = UIImage(data: imageData) {
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
        title = editedPlace?.name
        saveButton.isEnabled = true
    }
    
    private func showImageActionsSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Сделать фото", style: .default) { _ in
            self.chooseImagePicker(source: .camera)
        }
        camera.setValue(UIImage(systemName: "camera"), forKey: "image")
        
        let photo = UIAlertAction(title: "Выбрать фото", style: .default) { _ in
            self.chooseImagePicker(source: .photoLibrary)
        }
        photo.setValue(UIImage(systemName: "photo"), forKey: "image")
        
        let cancel = UIAlertAction(title: "Отменить", style: .cancel)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(photo)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true)
    }
    
    private func savePlace() {
        let image = imagePicked ? placeImage.image : UIImage(named: "imagePlaceholder")

        let newPlace = Place(name: placeName.text ?? "",
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: image?.pngData(),
                             rating: ratingView.rating)
        
        if let currentPlace = editedPlace {
            StorageService.shared.updateObject(currentPlace, with: newPlace)
        } else {
            StorageService.shared.saveObject(newPlace)
        }
    }
}
