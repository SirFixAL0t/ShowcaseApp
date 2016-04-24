//
//  ProfileVC.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/21/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import UIKit
import Firebase
class ProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    
    var imagePicker = UIImagePickerController()
    var userRef: Firebase!
    var uploadImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        userRef = DataService.ds.REF_USER_CURRENT
        usernameField.delegate = self
        
        populateUsername()
        populateImage()
    }
    
    func populateImage(){
        
        userImage.image = UIImage(named: "noprofile")!
        
        userRef.childByAppendingPath("profileUrl").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let profileImgUrl = snapshot.value as? String {
                if profileImgUrl != "" {
                    ImageStore.downloadImage(profileImgUrl, afterDownloadImage: { (img) in
                        self.userImage.image = img
                    })
                }
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameField.endEditing(true)
        return true
    }
    
    func populateUsername() {
        userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let userData = snapshot.value as? Dictionary<String, AnyObject> {
                if let username = userData["username"] as? String where username != "" {
                    self.usernameField.text = username
                } else {
                    if let email = userData["email"] as? String {
                        self.usernameField.text = email
                    }
                }
            }
        })

    }
    
    @IBAction func updateImage(sender: UIButton!) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        userImage.image = image
        uploadImage = true
    }
    
    private func updateUser() {
        if let profileImg = userImage.image {
            if uploadImage {
                  ImageStore.uploadImage(profileImg, afterUploadImage: { (url) in
                        self.userRef.childByAppendingPath("profileUrl").setValue(url)
                        self.uploadImage = false
                })
            }
        }
        if let username = usernameField.text {
            self.userRef.childByAppendingPath("username").setValue(username)
        }
    }
    
    @IBAction func updateProfile(sender: UIButton!) {

        if let username = usernameField.text where username != "" {
            DataService.ds.REF_USERS.queryOrderedByChild("username").queryEqualToValue(username).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let matchingRecord = snapshot.value as? Dictionary<String, AnyObject> {
                    if let key = matchingRecord.keys.first {
                        if key != NSUserDefaults.standardUserDefaults().stringForKey(KEY_UID)! {
                            self.showErrorAlert("Invalid username", msg: "The username you selected is already in use")
                        } else {
                            self.updateUser()
                        }
                    } else {
                        self.updateUser()
                    }
                } else {
                    self.updateUser()
                }
            })
        }
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}
