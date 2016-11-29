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
import SwiftKeychainWrapper
import TwitterKit
import JSQMessagesViewController


class LoginVC: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var loginRegisterSegment: UISegmentedControl!
    @IBOutlet weak var loginRegisterBtn: UIButton!
    @IBOutlet weak var nameField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.isHidden = false
        
        handleSegmentControl()
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.defaultKeychainWrapper().stringForKey(KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    // Facebook Login Button
    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
    
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print (error.debugDescription)
                
            } else if result?.isCancelled == true {
                print("User Cancelled FB Authentication")
            } else {
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
            self.showAlert("Email in use, did you use another methond to register", msg: "Please try again")
        }
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
                    if let user = user {
                        let userData = ["provider": credential.provider, "username": user.displayName]
                       self.twitterLogin(id: user.uid, userData: userData as! Dictionary<String, String>)
                    }
                })
            } else {
                if error != nil {
                    print (error.debugDescription)
                    return
                }
            }
        })
    }
    
    // Google Login
    @IBAction func goggleLogin(_ sender: GIDSignInButton) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        
        handleSegmentControl()
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        
        if (loginRegisterSegment.selectedSegmentIndex == 1) {
            handleSegmentControl()
            handleRegister()
            
        } else {
            
            handleLogin()
        }
    }
    
    
    func handleRegister() {
        
        self.nameField.resignFirstResponder()
        self.emailField.resignFirstResponder()
        self.pwdField.resignFirstResponder()
        
        if let email = emailField.text, let pwd = pwdField.text {
            
            FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user: FIRUser?, error) in
                
                if error != nil {
        
                    print (error.debugDescription)
                    
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeEmailAlreadyInUse:
                            self.showAlert("The email address is already in use", msg: "Did you register using another method below?")
                        case .errorCodeWeakPassword:
                            self.showAlert("Weak Password", msg: "The password must be at least 6 characters long")
                        case .errorCodeInvalidEmail:
                            self.showAlert("The email address is badly formatted", msg: "Please try again")
                            break;
                        default:
                            print("DID NOT CATCH ANY FAULT")
                        }
                    }
                    
                } else {
                    print("Persisteded into FirDatabase")
                    if let user = user {
                        let userData = ["provider": user.providerID, "email": self.emailField.text ?? "Blank","username": self.nameField.text ?? "empty"] as [String : Any]
                        self.login(id: user.uid, userData: userData as! Dictionary<String, String>)
                        
                    }
                }
            })
        }
    }
    
    
    // Handle Login
    func handleLogin() {
        
        self.emailField.resignFirstResponder()
        self.pwdField.resignFirstResponder()
        
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user: FIRUser?, error) in
                
                if (error != nil) {

                    print (error.debugDescription)
                    
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeWrongPassword:
                            self.showAlert("Incorrect password", msg: "Please try again")
                            break;
                        case .errorCodeUserNotFound:
                            self.showAlert("Email address not found", msg: "Please try again or register")
                            break;
                        case .errorCodeInvalidCredential:
                            break;
                        case .errorCodeInvalidEmail:
                            self.showAlert("The email address is badly formatted", msg: "Please try again or register")
                            break;
                        default:
                            print("Didnt Catch THe Error Above")
                            print(error.debugDescription)
                        }
                    }
                }
                
                else {
                    
                    if let user = user {
                        let userData = ["provider": user.providerID]
                      self.login(id: user.uid, userData: userData)
                    }
                    print(error.debugDescription)
                }
            })
            
            self.nameField.text = ""
            self.emailField.text = ""
            self.pwdField.text = ""
        }
    }
    
    // Firebase Auth
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Unable to authenticate with Firebase - \(error)")
            } else {
                print("Sucessfully authenticated with FB")
                if let user = user {
                    let userData = ["provider": credential.provider, "username": user.displayName, "email": user.email]
                    self.login(id: user.uid, userData: userData as! Dictionary<String, String>)
                }
            }
        })
    }
    
    func handleSegmentControl() {
        switch loginRegisterSegment.selectedSegmentIndex {
        case 0:
            loginRegisterBtn.setTitle("Login", for: .normal)
            nameField.isHidden = true
            break;
        case 1:
            loginRegisterBtn.setTitle("Register", for: .normal)
            nameField.isHidden = false
            break;
        default:
            loginRegisterBtn.setTitle("Default", for: .normal)
        }
    }
    
    func twitterLogin(id: String, userData: Dictionary<String, String>) {
        
        let keychainResult = KeychainWrapper.defaultKeychainWrapper().setString(id, forKey: KEY_UID)
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        print("Data Saved to Keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
        
    }

    
    func login(id: String, userData: Dictionary<String, String>) {
        
        if nameField.text != "" && emailField.text != "" && pwdField.text != "" {
            
        } else {
            
            showAlert("All fields are required", msg: "please try again")
        }
        
        let keychainResult = KeychainWrapper.defaultKeychainWrapper().setString(id, forKey: KEY_UID)
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        performSegue(withIdentifier: "goToFeed", sender: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.nameField {
            emailField.becomeFirstResponder()
            
        } else if textField == self.emailField {
            
            pwdField.becomeFirstResponder()
            self.view.becomeFirstResponder()
            
        } else if textField == self.pwdField {
            nameField.becomeFirstResponder()
            self.view.endEditing(true)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
