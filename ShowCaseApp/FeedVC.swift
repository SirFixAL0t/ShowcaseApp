//
//  FeedVC.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/17/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    var posts = [Post]()

    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        postField.delegate = self

        tableView.estimatedRowHeight = 600
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots.reverse() {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        postField.endEditing(true)
        return true
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 300
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]

        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            cell.configureCell(post)
            cell.parentVC = self
            return cell
        }
        
        return PostCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Did select row")
        let post = posts[indexPath.row]
        performSegueWithIdentifier("ViewPost", sender: post)
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        
        let defaultImg = UIImage(named: "camera")!
        
        if let desc = postField.text where desc != "" {
            if let img = imageSelectorImage.image {
                if !img.isEqual(defaultImg) {
                    ImageStore.uploadImage(img, afterUploadImage: { (imageLink) in
                        self.postToFirebase(imageLink)
                    })
                } else {
                    self.postToFirebase(nil)
                }
            } else {
                self.postToFirebase(nil)
            }
        }
        
        imageSelectorImage.image = defaultImg
    }
    
    @IBAction func logout(sender: UIButton!) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_UID)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoginScreen")
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageSelectorImage.image = image
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postToFirebase(imgUrl: String? ) {
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0,
            "user": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID)!
        ]
        
        if let img = imgUrl {
            post["imageUrl"] = img
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        firebasePost.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let postId = snapshot.key {
                DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").childByAppendingPath(postId).setValue(true)
            }
        })
        
        postField.text = ""
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditPost" {
            if let postRef = sender as? Firebase {
                let target = segue.destinationViewController as! EditPostVC
                target.postRef = postRef
            }
        }
        
        if segue.identifier == "ViewPost" {
            if let post = sender as? Post {
                let target = segue.destinationViewController as! ViewPostVC
                target.post = post
            }
        }
    }
}