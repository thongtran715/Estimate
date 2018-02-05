//
//  LogInViewController.swift
//  Estimate
//
//  Created by Thong Tran on 1/25/18.
//  Copyright © 2018 Thong Tran. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser != nil{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProjectStoryBoard") as! ViewController
           self.navigationController?.pushViewController(vc, animated: true)

        }

        // Do any additional setup after loading the view.
    }

    @IBAction func LoginBtn(_ sender: Any) {
        if emailText.text != "", passwordText.text != "" {
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else
                {
                    // Navigate to first controller
                    //LogInStoryBoard
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProjectStoryBoard") as! ViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                    

                }
            })
        }
    }
    @IBAction func signUpBtn(_ sender: Any) {
     
        if emailText.text != "", passwordText.text != "" {
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                
                if error != nil {
                    print(error?.localizedDescription)
                    print(error.debugDescription)
                }
                else{
                    
                }
                
            })
        }
        else{
            
        }
    }
    
    @IBAction func forgetPassBtn(_ sender: Any) {
    }
}
