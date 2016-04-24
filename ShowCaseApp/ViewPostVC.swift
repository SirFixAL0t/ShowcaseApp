//
//  ViewPostVC.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/23/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import UIKit
import Firebase

class ViewPostVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var userImage: MaterialImage!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var postImage: RoundedCorners!
    
    var comments = [Comment]()
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentField.delegate = self
        
        post.postRef.observeEventType(.Value, withBlock: { (snapshot) in
            if let postData = snapshot.value as? Dictionary<String, AnyObject> {
                if let img = postData["imageUrl"] as? String {
                    ImageStore.downloadImage(img, afterDownloadImage: {
                        (newImg) in
                        self.postImage.image = newImg
                    })
                }
                
                if let text = postData["description"] as? String {
                    self.postDescription.text = text
                }
                
                if let userKey = postData["user"] as? String {
                    DataService.ds.REF_USERS.childByAppendingPath(userKey).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        if let userData = snapshot.value as? Dictionary<String, AnyObject>{
                            if let username = userData["username"] as? String {
                                self.usernameLbl.text = username
                            } else {
                                if let email = userData["email"] as? String {
                                    self.usernameLbl.text = email
                                }
                            }
                            
                            if let userImg = userData["profileUrl"] as? String {
                                ImageStore.downloadImage(userImg, afterDownloadImage: { (img) in
                                    self.userImage.image = img
                                })
                            }
                        }
                    })
                }
                
            }
        })
        
        
        post.postRef.childByAppendingPath("comments").observeEventType(.Value, withBlock: { (snapshot) in
            if let commentsList = snapshot.children.allObjects as? [FDataSnapshot] {
                self.comments = []
                for commentKey in commentsList.reverse() {
                    DataService.ds.REF_COMMENTS.childByAppendingPath(commentKey.key).observeEventType(.Value, withBlock: { (snapshot) in
                        if let comment = snapshot.value as? Dictionary<String, AnyObject>{
                            self.comments.append(Comment(key: commentKey.key, data: comment))
                            self.commentTableView.reloadData()
                            self.toggleCommentSection()
                        }
                    })
                }
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        commentField.endEditing(true)
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        toggleCommentSection()
    }
    
    func toggleCommentSection(){
        self.commentTableView.reloadData()
        if comments.count > 0 {
            commentTableView.hidden = false
        } else {
            commentTableView.hidden = true
        }
    }
    
    @IBAction func postComment(sender: UIButton!) {
        if let message = commentField.text where message != ""{
            let newComment = DataService.ds.REF_COMMENTS.childByAutoId()
            let messageArr: Dictionary<String, AnyObject> = [
                "comment": message,
                "owner": NSUserDefaults.standardUserDefaults().stringForKey(KEY_UID)!,
                "post": post.postKey,
                "timestamp": NSDate().timeIntervalSince1970
            ]
            
            newComment.setValue(messageArr)
            
            newComment.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let commentId = snapshot.key {
                    self.post.postRef.childByAppendingPath("comments").childByAppendingPath(commentId).setValue(true)
                    DataService.ds.REF_USER_CURRENT.childByAppendingPath("comments").childByAppendingPath(commentId).setValue(true)
                    
                    self.commentField.text = ""
                }
            })
            
            toggleCommentSection()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as? CommentCell {
            cell.configureCell(comment)
            return cell
        }
        return CommentCell()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

}
