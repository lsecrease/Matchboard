//
//  SectionHeaderView.swift
//  Matchboard
//
//  Created by Hansen Zhang on 12/3/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation
import UIKit

protocol SectionHeaderViewDelegate {
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionOpened: Int)
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionClosed: Int)
}

class SectionHeaderView: UITableViewHeaderFooterView {
    
    var section: Int?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclosureButton: UIButton!
    @IBAction func toggleOpen() {
        self.toggleOpenWithUserAction(true)
    }
    var delegate: SectionHeaderViewDelegate?
    
    func toggleOpenWithUserAction(userAction: Bool) {
        self.disclosureButton.selected = !self.disclosureButton.selected
        
        if userAction {
            if self.disclosureButton.selected {
                self.delegate?.sectionHeaderView(self, sectionClosed: self.section!)
            } else {
                self.delegate?.sectionHeaderView(self, sectionOpened: self.section!)
            }
        }
    }
    
    override func awakeFromNib() {
        var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "toggleOpen")
        self.addGestureRecognizer(tapGesture)
        // change the button image
        self.disclosureButton.setImage(UIImage(named: "carat-open"), forState: UIControlState.Selected)
        self.disclosureButton.setImage(UIImage(named: "carat"), forState: UIControlState.Normal)
    }
    
}
