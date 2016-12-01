//
//  ChatVC.swift
//  ChetChat
//
//  Created by Martyn Cheatle on 11/11/2016.
//  Copyright © 2016 Martyn Cheatle. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper


class ChatVC: UIViewController {
    
    @IBOutlet weak var currentUser: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        
    }
    
    @IBAction func messagesBtn(_ sender: Any) {
        
        performSegue(withIdentifier: "goToMessages", sender: nil)
    }
    
    @IBAction func signOut(_ sender: Any) {
        
        handleLogout()
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            handleLogout()
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: Any] {
                    // THIS WILL CHANGE WHEN I HAVE THE USERS
                    self.currentUser.text = dictionary["username"] as? String
                }
                print(snapshot)
                
            }, withCancel: { (nil) in
                
            })
        }
    }
    
    func handleLogout() {
        try! FIRAuth.auth()?.signOut()
        KeychainWrapper.removeObjectForKey(KEY_UID)
        performSegue(withIdentifier: "goToLoginVC", sender: nil)
    }
}
