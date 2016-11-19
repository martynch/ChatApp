//
//  LoginVC.swift
//  ChetChat
//
//  Created by Martyn Cheatle on 11/11/2016.
//  Copyright © 2016 Martyn Cheatle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit
import JSQMessagesViewController

class LoginVC: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var loginRegisterSegment: UISegmentedControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    // Facebook Login Button
    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Unable to auth with facebook - \(error)")
            } else if result?.isCancelled == true {
                print("User Cancelled FB Authentication")
            } else {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                self.firebaseAuth(credential)
                print(result?.token.tokenString ?? "")
            }
        }
         print("Facebook Login Tapped")
    }
    
    // Twitter Login Button
    @IBAction func twitterBtnTapped(_ sender: TWTRLogInButton) {
        
        Twitter.sharedInstance().logIn(completion: {session, error in
            if (session != nil) {
                let authToken = session?.authToken
                let authTokenSecret = session?.authTokenSecret
                
                let credential = FIRTwitterAuthProvider.credential(withToken: authToken!, secret: authTokenSecret!)
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if error != nil {
                        print("First error")
                        return
                    }
                    
                    print("User Logged in with Twitter")
                })
            } else {
                if error != nil {
                    print("Second error")
                }
            }
        })
    }
    
    // Google Login
    @IBAction func goggleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()

    }
    
    // Login Button
    @IBAction func signInTapped(_ sender: UIButton) {
        
        if (loginRegisterSegment.selectedSegmentIndex == 1) {
            
            handleRegister()
            print("Loging Button Seleted Segement is Register")
            
        } else {
            handleLogin()
        }

    }
    
    func handleRegister() {
        
        
        print("Arrived at handleRegister Func")
    }
    
    
    // Handle Login
    func handleLogin() {
        
        self.emailField.resignFirstResponder()
        self.pwdField.resignFirstResponder()
        
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user: FIRUser?, error) in
                if error == nil {
                    self.login()
                    print("Login Tapped")
                    print(error?.localizedDescription ?? "")
                    print("You are successfully Logged in")
                } else {
                    print("Login Tapped")
                    print("Login Failed... Please Try Again")
                    print(error?.localizedDescription ?? "Error")
                }
            })
                        self.emailField.text = ""
                        self.pwdField.text = ""
        }

    }
    
    func login() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
        
    }
    // Firebase Auth
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Unable to authenticate with Firebase - \(error)")
            } else {
                print("Sucessfully authenticated with FB")
                self.login()
            }
        })
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            pwdField.becomeFirstResponder()
        } else if textField == self.pwdField {
            emailField.becomeFirstResponder()
            self.view.endEditing(true)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
