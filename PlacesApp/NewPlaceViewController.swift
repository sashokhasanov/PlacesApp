//
//  NewPlaceViewController.swift
//  PlacesApp
//
//  Created by Сашок on 01.03.2022.
//

import UIKit
import Cosmos

class NewPlaceViewController: UITableViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var cosmosView: CosmosView!
    
    
    var currentPlace: Place?
    var imagePicked = false
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeName.addTarget(self, action: #selector(placeNameChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        savePlace()
        performSegue(withIdentifier: "unwindSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showImageActionsSheet()
        } else {
            view.endEditing(true)
        }
    }
    
    private func showImageActionsSheet() {
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
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0
    }
    
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
    
    func savePlace() {

        let image = imagePicked ? placeImage.image : UIImage(named: "imagePlaceholder")

        let newPlace = Place(name: placeName.text ?? "",
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: image?.pngData(),
                             rating: cosmosView.rating
        )
        
        if let currentPlace = currentPlace {
            StorageManager.shared.updateObject(currentPlace, with: newPlace)
        } else {
            StorageManager.shared.saveObject(newPlace)
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

// MARK: - Image processing
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

// MARK: - MapViewControllerDelegate
extension NewPlaceViewController: MapViewControllerDelegate {
    func setUpAddress(address: String?) {
        placeLocation.text = address
    }
}
