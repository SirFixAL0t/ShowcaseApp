//
//  PostCell.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/17/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var heartImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var editPostBtn: UIButton!
    
    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    var user: User!
    var parentVC: UIViewController!
    var comments = [Comment]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        
        heartImg.addGestureRecognizer(tap)
        heartImg.userInteractionEnabled = true
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
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
    
    override func drawRect(rect: CGRect) {
        showcaseImg.clipsToBounds = true
    }
    
    func hideEditButton(){
        if post.userId != NSUserDefaults.standardUserDefaults().stringForKey(KEY_UID)! {
            editPostBtn.hidden = true
        }
    }
    
    func configureCell(post: Post) {
        
        self.post = post
        
        hideEditButton()
        
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)

        if let imgUrl = post.imageUrl {
            ImageStore.downloadImage(imgUrl, afterDownloadImage: { image in
                self.showcaseImg.image = image
            })
        } else {
            self.showcaseImg.hidden = true
        }
        
        likesLbl.text = "\(post.likes)"
        descriptionText.text = post.postDescription
        
        parseLikes()
        setUserProfile()
        
        comments = []
        for comment in post.comments {
            DataService.ds.REF_COMMENTS.childByAppendingPath(comment).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let data = snapshot.value as? Dictionary<String, AnyObject>{
                    self.comments.append(Comment(key: comment, data: data))
                    self.toggleCommentSection()
                }
            })
        }
    }
    
    func parseLikes() {
        likeRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.heartImg.image = UIImage(named: "heart-empty")!
            } else {
                self.heartImg.image = UIImage(named: "heart-full")!
            }
        })
    }
    
    func setUserProfile() {
        
        DataService.ds.REF_USERS.childByAppendingPath(self.post.userId).observeEventType(.Value, withBlock: { (snapshot) in
            if let user = snapshot.value as? Dictionary<String, AnyObject> {
                
                let email = user["email"] as? String ?? snapshot.key
                
                self.user = User(email: email!, profile: user["profileUrl"] as? String, uname: user["username"] as? String)
                let imgUrl = self.user.profileImg
                
                if imgUrl == "noprofile" {
                    self.profileImg.image = UIImage(named: self.user.profileImg)
                } else{
                    ImageStore.downloadImage(imgUrl, afterDownloadImage: { (img) in
                        self.profileImg.image = img
                    })
                }
                
                self.usernameLbl.text = self.user.username
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
         likeRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.heartImg.image = UIImage(named: "heart-full")!
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.heartImg.image = UIImage(named: "heart-empty")!
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
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
        }
    }
    
    @IBAction func editPost(sender: UIButton) {
        parentVC.performSegueWithIdentifier("EditPost", sender: post.postRef)
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
