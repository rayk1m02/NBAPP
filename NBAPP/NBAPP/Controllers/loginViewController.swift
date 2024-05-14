//
//  loginViewController.swift
//  NBAPP
//
//  Created by Raymond Kim on 3/27/24.
//

import UIKit
import Firebase

/*
 This represents the Login page
 Using Firebase for login
 */
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!

    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let err = error { print(err) }
                else { self.performSegue(withIdentifier: "loginToMain", sender: self) }
            }
        }
    }
    
}
