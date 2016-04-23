//
//  Constants.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/16/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import Foundation
import UIKit

let SHADOW_COLOR: CGFloat = 157.0 / 255.0
let KEY_UID = "uid"

//Segues
let SEGUE_LOGGEDIN = "loggedIn"

//Status Codes
let STATUS_ACCOUNT_NON_EXIST = -8

//API URLS
let API_URL_IMAGE_SHACK = "http://post.imageshack.us/upload_api.php"

//API Keys
let API_KEY_IMAGE_SHACK = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3"

//AfterActions
typealias AfterDownloadImage = (img: UIImage) -> ()
typealias AfterUploadImage = (url: String) -> ()