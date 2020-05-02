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

class SecondViewController: UIViewController {
    
    // globle data
    var ref: DatabaseReference! = nil
    @IBOutlet weak var verifyBtn: UIButton!
    var key: String = ""
    @IBOutlet weak var secreteKey: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.verifyBtn.isEnabled = false
        self.verifyBtn.isHidden = true

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
                        self.key = key
                        self.secreteKey.text = key
                        
                        self.verifyBtn.isHidden = false
                        self.verifyBtn.isEnabled = true
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
    
    
    @IBAction func verifyOpen(_ sender: Any) {
        self.ref.child("lockers/100001").updateChildValues(["_verifyOpen": true])
        
        let finalKey = self.getFinalKey()
        self.ref.child("lockers/100001/users/0").updateChildValues(["finalKey": finalKey])
        
        self.ref.child("users").setValue(nil)
    }
    
    
    func getUniqueKeyFromDivice() -> String {
        let uniqueKey = "70dfbca685f7424fa7ff90845d0fa564=="
        return uniqueKey
    }
    
    func getFinalKey() -> String {
        let uniqueKey = getUniqueKeyFromDivice()
        let finalKey: String = uniqueKey + self.key
        return finalKey
    }
}

