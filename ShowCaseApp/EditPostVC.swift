//
//  EditPostVC.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/22/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import UIKit
import Firebase

class EditPostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var uploadImage: UIImage?
    var postRef: Firebase!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        postText.delegate = self
        
        postRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let data = snapshot.value {
                if let text = data["description"] as? String{
                    self.postText.text = text
                }
                
                if let imgUrl = data["imageUrl"]  as? String{
                    ImageStore.downloadImage(imgUrl, afterDownloadImage: {
                        (img) in
                        self.putImage(img)
                    })
                } else {
                    self.putImage(UIImage(named: "no-image")!)
                }
            }
        })
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            postText.endEditing(true)
            return false
        }
        return true
    }

    
    func putImage(img: UIImage) {
        postImage.image = img
    }
    
    @IBAction func savePost(sender: UIButton) {
        if let newText = postText.text {
            postRef.childByAppendingPath("description").setValue(newText)
        }
        
        if let image = uploadImage {
            ImageStore.uploadImage(image, afterUploadImage: {
                (img) in
                    self.postRef.childByAppendingPath("imageUrl").setValue(img)
                    self.navigationController?.popViewControllerAnimated(true)
            })
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func changeImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        uploadImage = image
        putImage(image)
    }
    
    @IBAction func deletePost(sender: UIButton) {
        let deleteAlert = UIAlertController(title: "Delete post", message: "Are you sure you want to delete this post? This action cannot be undone", preferredStyle: UIAlertControllerStyle.Alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes, Delete", style: .Default, handler: {
            (action: UIAlertAction!) in
            
            self.postRef.childByAppendingPath("comments").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let comments = snapshot.children.allObjects as? [FDataSnapshot] {
                    for comment in comments {
                        DataService.ds.REF_COMMENTS.childByAppendingPath(comment.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            if let commentData = snapshot.value as? Dictionary<String, AnyObject> {
                                if let userId = commentData["owner"] as? String {
                                    DataService.ds.REF_USERS.childByAppendingPath(userId).childByAppendingPath("comments").childByAppendingPath(comment.key).removeValue()
                                }
                            }
                        })
                        DataService.ds.REF_COMMENTS.childByAppendingPath(comment.key).removeValue()
                    }
                }
            })
            
            self.postRef.removeValue()
            self.navigationController?.popViewControllerAnimated(true)
            
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "No, Wait!", style: .Cancel, handler: {
            (action: UIAlertAction!) in
        }))
        
        presentViewController(deleteAlert, animated: true, completion: nil)
    }
}
