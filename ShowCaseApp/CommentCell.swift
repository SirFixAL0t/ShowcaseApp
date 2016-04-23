//
//  CommentCell.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/22/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var ownerImg: UIImageView!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var postedOn: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(comment: Comment) {
        
        DataService.ds.REF_USERS.childByAppendingPath(comment.owner).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let data = snapshot.value as? Dictionary<String, AnyObject> {
                if let profile = data["profileUrl"] as? String {
                    ImageStore.downloadImage(profile, afterDownloadImage: {
                        (img) in
                            self.ownerImg.image = img
                    })
                }
                
                if let username = data["username"] as? String where username != ""{
                    self.ownerName.text = username
                } else {
                    self.ownerName.text = data["email"] as? String
                }
            }
        })
        
        self.comment.text = comment.comment
        self.postedOn.text = "\(comment.timestampAsDate)"
        
    }

}
