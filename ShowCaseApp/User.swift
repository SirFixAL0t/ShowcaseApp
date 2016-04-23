//
//  User.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/20/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import Foundation
import UIKit

class User {
    private var _username: String?
    private var _profileImg: String?
    private var _email: String!
    
    var username: String {
        return _username ?? _email
    }
    
    var profileImg: String {
        return _profileImg ?? "noprofile"
    }
    
    init(email: String, profile: String?, uname: String?) {
        _username = uname
        _email = email
        _profileImg = profile
    }
}