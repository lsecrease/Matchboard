//
//  LinkToWebCel.swift
//  Matchboard
//
//  Created by Seth Hein on 10/12/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol LinkToWebCellDelegate {
    func linkButtonPressed(sender: AnyObject, url: NSURL)
}

class LinkToWebCell: UITableViewCell {
    
    var delegate: LinkToWebCellDelegate?
    
    func configureCellWithAd(currentAd : PFObject)
    {
        
    }

    @IBAction func facebookButtonPressed(sender: AnyObject) {
        delegate?.linkButtonPressed(sender, url: NSURL(string: "FBProfile", relativeToURL: NSURL(string: "base url"))!)
    }
    @IBAction func twitterButtonPressed(sender: AnyObject) {
        delegate?.linkButtonPressed(sender, url: NSURL(string: "reallyseth", relativeToURL: NSURL(string: "https://twitter.com/"))!)
    }
    @IBAction func instagramButtonPressed(sender: AnyObject) {
        delegate?.linkButtonPressed(sender, url: NSURL(string: "FBProfile", relativeToURL: NSURL(string: "base url"))!)
    }
    @IBAction func webButtonPressed(sender: AnyObject) {
        delegate?.linkButtonPressed(sender, url: NSURL(string: "FBProfile", relativeToURL: NSURL(string: "base url"))!)
    }
    @IBAction func linkedInButtonPressed(sender: AnyObject) {
        delegate?.linkButtonPressed(sender, url: NSURL(string: "FBProfile", relativeToURL: NSURL(string: "base url"))!)
    }
}
