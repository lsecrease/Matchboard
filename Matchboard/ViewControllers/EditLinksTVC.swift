//
//  EditLinksTVC.swift
//  Matchboard
//
//  Created by Seth Hein on 10/13/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

enum EditLinksTableRows : Int {
    case Facebook
    case LinkedIn
    case Instagram
    case Twitter
    case Web
}

protocol EditLinksDelegate
{
    func saveLinks(sender:AnyObject, facebook: String, linkedin: String, instagram: String, twitter: String, web: String)
    func cancelEditLinks(sender: AnyObject)
}

class EditLinksTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate : EditLinksDelegate?
    var facebook = ""
    var linkedin = ""
    var instagram = ""
    var twitter = ""
    var web = ""
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.cancelEditLinks(navigationController!)
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        // todo: finish this out
        delegate?.saveLinks(navigationController!, facebook: facebook, linkedin: linkedin, instagram: instagram, twitter: twitter, web: web)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }

    @IBAction func linkChanged(sender: AnyObject) {
        
        if let textField = sender as? UITextField
        {
            if let textFieldText = textField.text
            {
            
                switch sender.tag
                {
                case EditLinksTableRows.Facebook.rawValue:
                    facebook = textFieldText
                case EditLinksTableRows.LinkedIn.rawValue:
                    linkedin = textFieldText
                case EditLinksTableRows.Instagram.rawValue:
                    instagram = textFieldText
                case EditLinksTableRows.Twitter.rawValue:
                    twitter = textFieldText
                case EditLinksTableRows.Web.rawValue:
                    web = textFieldText
                default:
                    print("EditLinksTVC Error: no tag from text field to identify which link we're dealing with")
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        switch indexPath.row {
        case EditLinksTableRows.Facebook.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath) as! LinkCell
            cell.configureCell(UserColumns.facebook.rawValue, cellRow: EditLinksTableRows.Facebook.rawValue, textValue: facebook)
            return cell
            
        case EditLinksTableRows.LinkedIn.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath) as! LinkCell
            cell.configureCell(UserColumns.linkedin.rawValue, cellRow: EditLinksTableRows.LinkedIn.rawValue, textValue: linkedin)
            return cell
            
        case EditLinksTableRows.Instagram.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath) as! LinkCell
            cell.configureCell(UserColumns.instagram.rawValue, cellRow: EditLinksTableRows.Instagram.rawValue, textValue: instagram)
            return cell
            
        case EditLinksTableRows.Twitter.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath) as! LinkCell
            cell.configureCell(UserColumns.twitter.rawValue, cellRow: EditLinksTableRows.Twitter.rawValue, textValue: twitter)
            return cell
            
        case EditLinksTableRows.Web.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath) as! LinkCell
            cell.configureCell(UserColumns.web.rawValue, cellRow: EditLinksTableRows.Web.rawValue, textValue: web)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath)
            return cell
            
        }
    }
}
