//
//  LoginControllerExtensionFile.swift
//  Chat App
//
//  Created by Siddique on 31/01/18.
//  Copyright © 2018 Siddique. All rights reserved.
//

import UIKit
import Firebase
extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func handleRegister() {
        guard  let email = emailTextField.text,
            let password = passwordTextField.text,
            let name = nameTextfield.text
            else {
                print("Form is not filled")
                return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            guard let uid = user?.uid else {
                return
            }
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpeg")
            if let profileImage = self.profileImageView.image,
                let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabaseWithUid(uid: uid,
                        values: values as [String : AnyObject])
                    }
                })
            }
        }
    }
    private func registerUserIntoDatabaseWithUid(uid: String,
                values: [String: AnyObject]) {
        var ref = DatabaseReference()
        ref = Database.database().reference()
        let usersRegistered = ref.child("users").child(uid)
        usersRegistered.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
            }
//            self.messagecontroller?.userLoginAndSetBavBar()
//            self.messagecontroller?.navigationItem.title = values["name"] as? String
            let user = Users(dictionary: values)
            self.messagecontroller?.setupNavBarWithUser(user)
            self.dismiss(animated: true, completion: nil)
        })
    }
    @objc func handleProfileImageView() {
        let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as? UIImage
        }
        if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
