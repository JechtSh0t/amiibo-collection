//
//  CreateAmiiboViewController.swift
//  AmiiboCollection
//
//  Created by Phil on 12/7/20.
//

import UIKit

protocol CreateAmiiboViewControllerDelegate: class {
    func createAmiiboViewController(_ viewController: CreateAmiiboViewController, didCreateAmiibo amiibo: Amiibo)
}

final class CreateAmiiboViewController: PopoverViewController {
    
    // MARK: - Properties -
    
    private weak var delegate: CreateAmiiboViewControllerDelegate?
    
    // MARK: - UI -
    
    @IBOutlet private weak var popoverView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var imageButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var confirmButton: UIButton!
    
    // MARK: - Setup -
    
    func configure(delegate: CreateAmiiboViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        setConfirmButton(enabled: false)
    }
    
    override func style() {
        
        super.style()
        
        popoverView.roundCorners()
        
        imageButton.setTitleColor(.nintendoGreen, for: .normal)
        
        confirmButton.addBorder(width: 3.0, color: .nintendoFadedGray)
        confirmButton.roundCorners()
        confirmButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        confirmButton.setTitleColor(.nintendoFadedGray, for: .normal)
    }
    
    override func lightStyle() {
        
        super.lightStyle()
        nameTextField.textColor = .black
    }
    
    override func darkStyle() {
        
        super.darkStyle()
        nameTextField.textColor = .white
    }
}

// MARK: - TextField -

extension CreateAmiiboViewController: UITextFieldDelegate {
    
    @IBAction private func textFieldChanged(_ sender: UITextField) {
        setConfirmButton(enabled: sender.text?.isEmpty == false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Image -

extension CreateAmiiboViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction private func imageButtonPressed(_ sender: UIButton) {
        showImagePicker()
    }
    
    private func showImagePicker() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageButton.setTitle("Change Image", for: .normal)
        imageView.image = image
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Transition -

extension CreateAmiiboViewController {
    
    private func setConfirmButton(enabled: Bool) {
        
        confirmButton.isEnabled = enabled
        confirmButton.setTitleColor(enabled ? .nintendoGreen : .nintendoFadedGray, for: .normal)
        confirmButton.addBorder(width: 3.0, color: enabled ? .nintendoGreen : .nintendoFadedGray)
    }
    
    @IBAction private func confirmButtonPressed(_ sender: UIButton) {
        
        do {
            let amiibo = try AmiiboManager.shared.createAmiibo(withName: nameTextField.text!, image: imageView.image)
            try AmiiboManager.shared.addToCollection(amiibo)
            delegate?.createAmiiboViewController(self, didCreateAmiibo: amiibo)
            dismiss(animated: true, completion: nil)
        } catch {
            showAlert(for: error)
        }
    }
}
