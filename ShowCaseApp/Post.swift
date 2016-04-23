//
//  Post.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/18/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: Firebase!
    private var _userId: String!
    private var _comments = [String]()
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    var userId: String {
        return _userId
    }
    
    var postRef: Firebase {
        return _postRef
    }
    
    var comments: [String] {
        return _comments
    }
    
    init(description: String, imageUrl: String?, username: String ) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = username
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let description = dictionary["description"] as? String {
            self._postDescription = description
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let user = dictionary["user"] as? String {
            self._userId = user
        }
        
        if let comments = dictionary["comments"] as? Dictionary<String, Bool>{
            for comment in comments {
                self._comments.append(comment.0)
            }
        }
        
        _postRef = DataService.ds.REF_POSTS.childByAppendingPath(postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.childByAppendingPath("likes").setValue(_likes)
        
    }
}
