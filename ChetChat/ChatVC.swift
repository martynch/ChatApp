//
//  ChatVC.swift
//  ChetChat
//
//  Created by Martyn Cheatle on 11/11/2016.
//  Copyright © 2016 Martyn Cheatle. All rights reserved.
//

import UIKit
import FBSDKLoginKit


class ChatVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutBtn(_ sender: Any) {
        
        // Create main story board instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // from main storyboard instantiate a navigation controller
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        
        // get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //set login View controller as root view controller
        appDelegate.window?.rootViewController = loginVC

    }
}
