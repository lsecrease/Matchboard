//
//  CheckMobileServiceClient.swift
//  Matchboard
//
//  Created by Seth Hein on 10/16/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation

class CheckMobileServiceClient {
    var service : NSURLSession!
    let serviceUrl = "https://api.checkmobi.com/v1"
    init(){
        let configuration = NSURLSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["Authorization": "A2580AEC-670B-4809-B684-42A8BE811403", "Accept": "application/json"]
        service = NSURLSession(configuration: configuration)
        
    }
    func callService(entity: String, method: String, data: Dictionary<String, AnyObject>, callBack:((data: NSDictionary) -> Void)!){
        let url = NSURL(string: serviceUrl + "/" + entity + "/" + method)
        let errorPointer = NSErrorPointer()
        var serializedData : NSData?
        do {
            serializedData = try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.PrettyPrinted)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = serializedData
        
        if serializedData != nil
        {
            print(errorPointer)
        }
        
        service.dataTaskWithRequest(request, completionHandler:{data, response, error -> Void in
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
                
                print("Response: \(response)")
                print("Error: \(error)")
                
                callBack(data: jsonData)
            } catch let error as NSError {
                print (error.debugDescription)
            }
            
        }).resume()
    }
}