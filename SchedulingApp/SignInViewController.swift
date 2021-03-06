//
//  SignInViewController.swift
//  SchedulingApp
//
//  Created by Zeal on 4/21/16.
//  Copyright © 2016 Jake Zeal. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK:- Outlets
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK:- View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTextFields()
        prepareSecureSignIn()
        prepareSubviews()
    }
    
    //MARK:- Preparations
    func prepareSubviews() {
        self.loginButton.addShadow()
        self.usernameTextField.addShadow()
        self.passwordTextField.addShadow()
    }
    
    func prepareTextFields() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        setupTextFieldViews()
    }
    
    func prepareSecureSignIn() {
        self.passwordTextField.secureTextEntry = true
    }
    
    func setupTextFieldViews() {
        //Username Text Field
        usernameTextField.leftViewMode = .Always
        let imageView = UIImageView(image: UIImage(named: "User"))
        imageView.contentMode = UIViewContentMode.Center
        imageView.frame = CGRectMake(0.0, 0.0, imageView.image!.size.width + 20.0, imageView.image!.size.height)
        usernameTextField.leftView = imageView
        
        //Password Text Field
        passwordTextField.leftViewMode = .Always
        let imageView2 = UIImageView(image: UIImage(named: "Lock"))
        
        imageView2.contentMode = UIViewContentMode.Center
        imageView2.frame = CGRectMake(0.0, 0.0, imageView2.image!.size.width + 20.0, imageView2.image!.size.height)
        passwordTextField.leftView = imageView2
    }
    
    // MARK:- Actions
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        if !(username ?? "").isEmpty && !(password ?? "").isEmpty {
            userSignIn(username!, password: password!)
            DataManager.sharedInstance.updateUser()
        } else {
            showAlert()
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK:- Segues
    func segueToCalendarCollectionViewController() {
        performSegueWithIdentifier("CalendarCollectionViewController", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CalendarCollectionViewController" {
            let nav = segue.destinationViewController as! UINavigationController
            nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 202.0/255.0, green: 15.0/255.0, blue: 19.0/255.0, alpha: 1.0)]
        }
    }
    
    // MARK:- Helpers
    func userSignIn(username: String, password: String) {
        DataManager.sharedInstance.signInUser(username, password: password) { (user, error) -> Void in
            if user != nil {
                self.segueToCalendarCollectionViewController()
            } else {
                self.showAlert()
            }
        }
    }
}

// MARK:- Private Extensions
private extension SignInViewController {
    
    func showAlert() {
        showAlert(SignInViewControllerConstants.errorTitle, message: SignInViewControllerConstants.errorMessage, actionTitle: SignInViewControllerConstants.errorActionTitle)
    }
    
    func showAlert(title:String, message:String) {
        showAlert(title, message: message, actionTitle: SignInViewControllerConstants.errorActionTitle)
    }
    
    func showAlert(title:String, message:String, actionTitle:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
