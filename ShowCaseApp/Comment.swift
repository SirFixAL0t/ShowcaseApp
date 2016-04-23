//
//  Comment.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/22/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import Foundation

class Comment {
    
    private var _key: String!
    private var _owner: String!
    private var _comment: String!
    private var _timestamp: Double!
    private var _postKey: String!
    
    var owner: String {
        return _owner
    }
    
    var comment: String {
        return _comment
    }
    
    var timestamp: Double {
        return _timestamp
    }
    
    var timestampAsDate: String {
        //calculate the timestamp based on the date
        let dateObj = NSDate(timeIntervalSince1970: timestamp)
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        
        let date = formatter.stringFromDate(dateObj)
        return "Posted on \(date)"
    }
    
    var postKey: String {
        return _postKey
    }
    
    var key: String {
        return _key
    }
    
    init(key:String, owner: String, comment: String, timestamp: Double, postKey: String) {
        _owner = owner
        _comment = comment
        _timestamp = timestamp
        _key = key
        _postKey = postKey
    }
    
    init(key: String, data: Dictionary<String, AnyObject>) {
        _key = key
        
        if let owner = data["owner"] as? String {
            _owner = owner
        }
        
        if let comment = data["comment"] as? String {
            _comment = comment
        }
        
        if let timestamp = data["timestamp"] as? Double {
            _timestamp = timestamp
        }
        
        if let postKey = data["post"] as? String {
            _postKey = postKey
        }
    }
}