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


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(loginRegisterSegment.selectedSegmentIndex)
        handleSegmentControl()
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    // Facebook Login Button
    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        print("NUMBER 1")
        
        let facebookLogin = FBSDKLoginManager()
        
        print("NUMBER 2")
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                
                print("Unable to logon with Facebook \(error)")
                print(error?.localizedDescription ?? "Number 3")
                print (error.debugDescription)
                
            } else if result?.isCancelled == true {
                print("User Cancelled FB Authentication")
                print(error?.localizedDescription ?? "Number 3.5")
                print (error.debugDescription)
            } else {
                
                print("NUMBER 4")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                self.firebaseAuth(credential)
                
                print(error?.localizedDescription ?? "Failed Number 4")
                print (error.debugDescription)
            }
            print(error?.localizedDescription ?? "Failed Number 5")
            self.showAlert("Email in use, did you use another methond to register", msg: "Please try again")
            print (error.debugDescription)
            print("NUMBER 5")
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
                        print(error?.localizedDescription ?? "Failed here")
                        print (error.debugDescription)
                        print("First error")
                        return
                    }
                    self.login()
                })
            } else {
                if error != nil {
                    print(error?.localizedDescription ?? "Failed here")
                    print (error.debugDescription)
                    print("Second error")
                    
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
            
            print("Segment 1")
            handleSegmentControl()
            handleRegister()
            
            
        } else {
            print("Segment 2")
            handleLogin()

        }
    }
    
    
    func handleRegister() {
        
        self.emailField.resignFirstResponder()
        self.pwdField.resignFirstResponder()
        
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user: FIRUser?, error) in
                
                if error != nil {
        
                    print(error?.localizedDescription ?? "Failed here")
                    print (error.debugDescription)
                    
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeEmailAlreadyInUse:
                            self.showAlert("The email address is already in use", msg: "Did you register using another method below?")
                        case .errorCodeWeakPassword:
                            self.showAlert("Weak Password", msg: "The password must be at least 6 characters long")
                        default:
                            print("DID NOT CATCH ANY FAULT")
                        }
                    }
                    
                } else {
                    self.login()
                    print("Sucessfully logged in")
                }
            })
        }
        
        print("Arrived at handleRegister Func")
    }
    
    
    // Handle Login
    func handleLogin() {
        
        self.emailField.resignFirstResponder()
        self.pwdField.resignFirstResponder()
        
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user: FIRUser?, error) in
                
                if (error != nil) {

                    print(error?.localizedDescription ?? "Failed here")
                    print (error.debugDescription)
                    
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeWrongPassword:
                            self.showAlert("Incorrect password", msg: "Please try again")
                            break;
                        case .errorCodeUserNotFound:
                            self.showAlert("Email address not found", msg: "Please try again or register")
                            print("NO SUCH FUCKING USER BITCH")
                            break;
                        case .errorCodeInvalidCredential:
                            print("invalid user")
                            break;
                        case .errorCodeInvalidEmail:
                            print("Shit Email")
                            break;
                        default:
                            print("Didnt Catch THe Error Above")
                        }
                    }
                }
                
                else {
                    
                    self.login()
                    print("LOGGED IN")
                    print(error?.localizedDescription ?? "No Errors Found")
                    print(error.debugDescription)
                }
            })
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
                self.login()
            }
        })
    }
    
    func handleSegmentControl() {
        switch loginRegisterSegment.selectedSegmentIndex {
        case 0:
            loginRegisterBtn.setTitle("Login", for: .normal)
            break;
        case 1:
            loginRegisterBtn.setTitle("Register", for: .normal)
            break;
        default:
            loginRegisterBtn.setTitle("Default", for: .normal)
        }
    }
    
    func login() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
        
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
    
    func showAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
