//
//  SecondViewController.swift
//  LoginApp
//
//  Created by Allan Shivji on 3/21/19.
//  Copyright © 2019 Allan Shivji. All rights reserved.
//

import UIKit
import FirebaseDatabase
import UserNotifications

class SecondViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var textfield: UITextField!
    var locked = false
    
    var ref: DatabaseReference! = nil
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var keyInput: UITextField!
    @IBOutlet weak var secreteKey: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textfield.delegate = self
        
        self.secreteKey.text = ""
        self.enableVerifyBtn(status: false)

        // Do any additional setup after loading the view.
        self.ref = Database.database().reference()
        
        self.ref.child("users/30001/messages/message/body")
            .observe(DataEventType.value, with: { (snapshot) in
                if let message = snapshot.value as? String {
                    print(message)
                }
                
                self.ref.child("users/30001/messages/payload")
                .observe(DataEventType.value, with: { (snapshot) in
                    if let key = snapshot.value as? String {
                        self.secreteKey.text = key
                        self.checkKeyInputValidity(input: self.keyInput)
                    }
                })
            })
        
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications \(didAllow)")
            }
        }
    }
    
    @IBAction func keyInputDidChange(_ input: UITextField) {
        checkKeyInputValidity(input: input)
    }
    
    @IBAction func requestOTP(_ sender: Any) {
        self.ref.child("lockers/100001").updateChildValues(["_tryingToOpen": true])
    }
    
    @IBAction func verifyOpen(_ sender: Any) {
        if locked {
            print(locked)
        }
        
        print("clicked verify button")
        self.ref.child("lockers/100001").updateChildValues(["_verifyOpen": true])
        
        let finalKey = self.getFinalKey()
        print("final key" + finalKey)
        self.ref.child("lockers/100001/users/0").updateChildValues(["finalKey": finalKey])
        
        self.handleVerifyOpen()
        self.ref.child("users").setValue(nil)
    }
    
    func handleVerifyOpen() {
        self.ref.child("lockers/100001/_doOpen")
        .observe(DataEventType.value, with: { (snapshot) in
            if let isOpen: Bool = snapshot.value as? Bool {
                if isOpen {
                    self.alertMessage(msg: "Opened", title: "Success", btnName: "OK")
                }
            }
        })
        
        self.ref.child("lockers/100001/_doLock")
        .observe(DataEventType.value, with: { (snapshot) in
            if let isLock: Bool = snapshot.value as? Bool {
                if isLock {
                    self.locked = true;
                    self.secreteKey.text = ""
                    self.checkKeyInputValidity(input: self.keyInput)
                    self.alertMessage(msg: "Locked", title: "Error", btnName: "OK")
                }
            }
        })
    }
    
    func getFinalKey() -> String {
        let uniqueKey = getUniqueKeyFromDivice()
        return uniqueKey + self.keyInput.text!
    }
    
    func getUniqueKeyFromDivice() -> String {
        let uniqueKey = "70dfbca685f7424fa7ff90845d0fa564=="
        return uniqueKey
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return true
    }
    
    func enableVerifyBtn(status: Bool) {
        if status {
            self.verifyBtn.backgroundColor = UIColor.red
            self.verifyBtn.isEnabled = true
        } else {
            self.verifyBtn.backgroundColor = UIColor.gray
            self.verifyBtn.isEnabled = false
        }
    }
    
    func checkKeyInputValidity(input: UITextField) {
        let isValid = input.text!.count == 6 && self.secreteKey.text!.count > 0
        self.enableVerifyBtn(status: isValid)
    }
    
    func alertMessage(msg: String, title: String, btnName: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: btnName, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

