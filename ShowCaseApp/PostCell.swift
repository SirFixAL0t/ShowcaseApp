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

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var heartImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var editPostBtn: UIButton!
    
    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    var user: User!
    var parentVC: UIViewController!


    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        
        heartImg.addGestureRecognizer(tap)
        heartImg.userInteractionEnabled = true
    }
    
    
    override func drawRect(rect: CGRect) {
        showcaseImg.clipsToBounds = true
    }
    
    func hideEditButton(){
        if post.userId != NSUserDefaults.standardUserDefaults().stringForKey(KEY_UID)! {
            editPostBtn.hidden = true
        } else {
            editPostBtn.hidden = false
        }
    }
    
    func configureCell(post: Post) {
        
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)

        if let imgUrl = post.imageUrl {
            ImageStore.downloadImage(imgUrl, afterDownloadImage: { image in
                self.showcaseImg.image = image
                self.showcaseImg.hidden = false
            })
        } else {
            self.showcaseImg.hidden = true
        }
        
        likesLbl.text = "\(post.likes)"
        descriptionText.text = post.postDescription
        
        parseLikes()
        setUserProfile()
        
        commentsLbl.text = "\(post.comments.count) comments"
        enableCommentsLink()
        hideEditButton()
    }
    
    func enableCommentsLink() {
        let tapRecognirzer = UITapGestureRecognizer(target: self, action: #selector(PostCell.viewPost(_:)))
        commentsLbl.addGestureRecognizer(tapRecognirzer)
        commentsLbl.userInteractionEnabled = true
    }
    
    func viewPost(tap: UITapGestureRecognizer) {
        parentVC.performSegueWithIdentifier("ViewPost", sender: post)
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
    
        
    @IBAction func editPost(sender: UIButton) {
        parentVC.performSegueWithIdentifier("EditPost", sender: post.postRef)
    }
}
