//
//  VerifyPhoneViewController.swift
//  Matchboard
//
//  Created by Seth Hein on 10/20/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class VerifyPhoneViewController: UIViewController {
    
    var phoneNumber : String? {
        didSet {
            if let phoneNumber = phoneNumber
            {
                let service = CheckMobileServiceClient()
                service.callService("validation", method: "request", data: ["number":phoneNumber, "type":"cli"], callBack: { (data) -> Void in
                    print(data)
                    
                })
            }
        }
    }
    var displayName : String?
    var userImage : UIImage?
    
    override func viewDidLoad() {
        
    }
}
