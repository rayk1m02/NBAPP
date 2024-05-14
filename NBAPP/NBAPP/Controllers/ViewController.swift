//
//  ViewController.swift
//  NBAPP
//
//  Created by Raymond Kim on 3/26/24.
//

import UIKit
import CLTypingLabel

/*
 This represents that opening page
 CLTypingLabel for text display UI
 */
class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: CLTypingLabel!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerBtn.layer.cornerRadius = 10
        registerBtn.clipsToBounds = true
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
        titleLabel.text = "🏀 NBAPP"
    }

}

