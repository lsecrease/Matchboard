//
//  ParseErrorHandlingController.swift
//  Matchboard
//
//  Created by Seth Hein on 9/10/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation

class ParseErrorHandlingController {
    class func handleParseError(error: NSError) {
        if error.domain != PFParseErrorDomain {
            return
        }
        
        if error.code == PFErrorCode.ErrorInvalidSessionToken.rawValue
        {
            handleInvalidSessionTokenError()
        } else {
            handleOtherError()
        }
    }
    
    private class func handleOtherError() {
        let alert = UIAlertView(title: "Matchboard",
            message: "Something went wrong, try again later or check your internet connection",
            delegate: nil,
            cancelButtonTitle: "OK" )
        alert.show()
    }
    
    private class func handleInvalidSessionTokenError() {

        // if ViewController is at the root (which it should always be), perform the login segue
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? ViewController
        {
            rootVC.performSegueWithIdentifier("login", sender: rootVC)
        }
    }
}