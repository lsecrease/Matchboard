//
//  LinkCell.swift
//  Matchboard
//
//  
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class LinkCell: UITableViewCell {

    @IBOutlet weak var linkImageView: UIImageView!
    @IBOutlet weak var linkTextField: UITextField!
    
    override func layoutSubviews() {
        linkImageView.layer.masksToBounds = true
        linkImageView.layer.cornerRadius = MatchboardUtils.cornerRadius()
    }
    
    func configureCell(linkName : String, cellRow : Int, textValue : String) {
        linkImageView.image = UIImage(named: linkName)
        linkTextField.tag = cellRow
        linkTextField.text = textValue
    }
}
