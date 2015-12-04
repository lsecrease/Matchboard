//
//  BlockUserCell.swift
//  Matchboard
//
//  
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol BlockUserDelegate
{
    func blockUserPressed()
}

class BlockUserCell: UITableViewCell {

    var delegate : BlockUserDelegate?
    
    @IBAction func blockUserPressed(sender: AnyObject) {
        if let delegate = delegate
        {
            delegate.blockUserPressed()
        }
    }
}
