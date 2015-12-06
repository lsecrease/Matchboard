//
//  MatchboardColors.swift
//  Matchboard
//
// 
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation

enum MatchboardColors {
    case DarkBackground
    case FieldBorder
    case NavBar
    
    func color() -> UIColor {
        switch (self) {
        case .DarkBackground:
            return UIColor(red:0.12, green:0.31, blue:0.52, alpha:1)
        case .FieldBorder:
            return UIColor(red:0.78, green:0.78, blue:0.78, alpha:1)
        case .NavBar:
            return UIColor(red:0.13, green:0.31, blue:0.53, alpha:1)
        default:
            return UIColor.blackColor()
        }
    }
}