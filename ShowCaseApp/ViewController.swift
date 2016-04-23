//
//  ViewController.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/16/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil{
            self.performSegueWithIdentifier(SEGUE_LOGGEDIN, sender: nil)
        }
    }

    @IBAction func FBButtonPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self, handler: {
            (facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            }else{
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { (error, authData) in
                    
                    if error != nil {
                        print ("Login with Facebook OAuth Failed \(error)")
                    } else {
                        
                        var user = ["provider": authData.provider!, "email": ""]
                        if let email = authData.providerData["email"] as? String {
                            user["email"] = email
                            user["username"] = email
                        }
                        
                        //Check if the user exists by email
                        DataService.ds.REF_USERS.queryOrderedByChild("email").queryEqualToValue(user["email"]!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                           
                            if let matchingRecord = snapshot.value as? Dictionary<String, AnyObject> {
                                if let key = matchingRecord.keys.first {
                                    self.setUIDAndLogin(key)
                                } else {
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    self.setUIDAndLogin(authData.uid)
                                }
                            } else {
                                DataService.ds.createFirebaseUser(authData.uid, user: user)
                                self.setUIDAndLogin(authData.uid)
                            }
                        })
                    }
                })
            }
        })
    }
    
    private func setUIDAndLogin(uid: String) {
        NSUserDefaults.standardUserDefaults().setValue(uid, forKey: KEY_UID)
        self.performSegueWithIdentifier(SEGUE_LOGGEDIN, sender: nil)
    }
    
    @IBAction func emailBtnPressed(sender: UIButton!) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { (error, authData) in
                if error != nil {
                    print("Unable to login to Firebase \(error)")
                    if error.code == STATUS_ACCOUNT_NON_EXIST {
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { (error, result) in
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating the account. Try something else")
                            } else {
                                
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { (errorAuth, authData) in
                                    if errorAuth != nil {
                                        print("Unable to log the user \(errorAuth)")
                                    } else {
                                        let user = ["provider": authData.provider!, "email": email, "username": email]
                                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    }
                                })
                                self.setUIDAndLogin(result[KEY_UID] as! String)
                            }
                        })
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your Username or Password")
                    }
                } else {
                    self.setUIDAndLogin(authData.uid)
                }
            })
            
        } else {
            showErrorAlert("Missing Required Field", msg: "You must enter and email and a password")
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}

