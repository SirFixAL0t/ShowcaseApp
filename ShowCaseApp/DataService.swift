//
//  DataService.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/17/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://fenrriquez-showcase.firebaseio.com"
class DataService {

    static let ds = DataService()
    

    private var _REF_BASE = Firebase(url: URL_BASE)
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    private var _REF_COMMENTS = Firebase(url: "\(URL_BASE)/comments")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_COMMENTS: Firebase {
        return _REF_COMMENTS
    }
    
    var REF_USER_CURRENT: Firebase {
        if let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as? String {
            let user = Firebase(url: "\(REF_USERS)").childByAppendingPath(uid)
            return user!
        } else {
            return Firebase()
        }
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
}