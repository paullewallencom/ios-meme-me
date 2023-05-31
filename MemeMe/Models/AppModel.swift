/*
 *  AppModel.swift
 *  MemeMe
 *
 *  Created by Paul Lewallen on 5/31/23.
 *
 */

import UIKit

struct AppModel {
    
    static let fontTableViewSegueIdentifier = "fontTableView"
    static let fontCellReuseIdentifier      = "fontCell"
    static let fontAvailable                = UIFont.familyNames
    static var currentFontIndex : Int       = 1
    static var selectedFont : String        = "system"
    static let defaultTopTextFieldText      = "TOP"
    static let defaultBottomTextFieldText   = "BOTTOM"
    
    struct alert {
        static let alertTitle   = "Trash"
        static let alertMessage = "Are you sure this is trash?"
    }
    
    static let memeTextAttributes = [
        NSAttributedString.Key.strokeColor     : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.font            : UIFont(name: "system", size: 32)!,
        NSAttributedString.Key.strokeWidth     : 1.0
    ] as [String : Any]
}
