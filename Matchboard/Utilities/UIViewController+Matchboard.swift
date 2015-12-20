//
//  UIViewController+Matchboard.swift
//  Matchboard
//
//  Created by Seth Hein on 12/20/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation

extension UIViewController {
    
    public func alert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK action"), style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
}