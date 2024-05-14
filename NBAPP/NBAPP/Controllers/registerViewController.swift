//
//  registerViewController.swift
//  NBAPP
//
//  Created by Raymond Kim on 3/27/24.
//

import UIKit
import Firebase

/*
 This represents the Registeration page
 Using Firebase for registeration
 */
class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let err = error { print(err.localizedDescription) }
                else { self.performSegue(withIdentifier: "registerToMain", sender: self) }
            }
        }
    }
    
}
