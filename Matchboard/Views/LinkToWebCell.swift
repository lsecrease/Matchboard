//
//  LinkToWebCel.swift
//  Matchboard
//
//  
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol LinkToWebCellDelegate {
    func linkButtonPressed(sender: AnyObject, url: NSURL)
    func editLinksButtonPressed(sender: AnyObject)
}

class LinkToWebCell: UITableViewCell {
    
    var delegate: LinkToWebCellDelegate?
    
    var fbUrl : NSURL?
    var linkedInUrl : NSURL?
    var instagramUrl : NSURL?
    var webUrl : NSURL?
    var twitterUrl : NSURL?
    
    @IBOutlet weak var editLinksButton: UIButton!
    
    override func layoutSubviews() {
        editLinksButton.setImage(editLinksButton.imageView!.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        
        editLinksButton.layer.cornerRadius = MatchboardUtils.cornerRadius()
    }
    
    func configureCellWithAd(currentAd : PFObject, isMine: Bool)
    {
        // save urls from current user from ad
        if let user = currentAd[AdColumns.username.rawValue] as? PFUser {
            if let fbUsername = user[UserColumns.facebook.rawValue] as? String {
                fbUrl = NSURL(string: fbUsername, relativeToURL: NSURL(string:"https://www.facebook.com/"))
            }
            
            if let linkedInUsername = user[UserColumns.linkedin.rawValue] as? String {
                linkedInUrl = NSURL(string: linkedInUsername, relativeToURL: NSURL(string:"https://www.linkedin.com/in/"))
            }
            
            if let twitterUsername = user[UserColumns.twitter.rawValue] as? String {
                twitterUrl = NSURL(string: twitterUsername, relativeToURL: NSURL(string:"https://twitter.com/"))
            }
            
            if let instagramUsername = user[UserColumns.instagram.rawValue] as? String {
                instagramUrl = NSURL(string: instagramUsername, relativeToURL: NSURL(string:"https://instagram.com/"))
            }
            
            if let webUrlString = user[UserColumns.web.rawValue] as? String {
                webUrl = NSURL(string: webUrlString)
            }
        }
        
        editLinksButton.hidden = !isMine
    }


    @IBAction func editLinksButtonPressed(sender: AnyObject) {
        delegate?.editLinksButtonPressed(sender)
    }
    @IBAction func facebookButtonPressed(sender: AnyObject) {
        if let fbUrl = fbUrl {
            delegate?.linkButtonPressed(sender, url: fbUrl)
        }
    }
    @IBAction func twitterButtonPressed(sender: AnyObject) {
        if let twitterUrl = twitterUrl {
            delegate?.linkButtonPressed(sender, url: twitterUrl)
        }
    }
    @IBAction func instagramButtonPressed(sender: AnyObject) {
        if let instagramUrl = instagramUrl {
            delegate?.linkButtonPressed(sender, url: instagramUrl)
        }
    }
    @IBAction func webButtonPressed(sender: AnyObject) {
        if let webUrl = webUrl {
            delegate?.linkButtonPressed(sender, url: webUrl)
        }
    }
    @IBAction func linkedInButtonPressed(sender: AnyObject) {
        if let linkedInUrl = linkedInUrl {
            delegate?.linkButtonPressed(sender, url: linkedInUrl)
        }
    }
}
