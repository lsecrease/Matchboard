//
//  MatchboardColors.swift
//  Matchboard
//
//  Created by Seth Hein on 9/23/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation

enum MatchboardColors {
    case DarkBackground
    
    func color() -> UIColor {
        switch (self) {
        case .DarkBackground:
            return UIColor(red:0.12, green:0.31, blue:0.52, alpha:1)
        default:
            return UIColor.blackColor()
        }
    }
}