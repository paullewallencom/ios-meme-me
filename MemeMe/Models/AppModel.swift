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
    
    static let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedStringKey.strokeColor.rawValue     : UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
        NSAttributedStringKey.font.rawValue            : UIFont(name: "system", size: 32)!,
        NSAttributedStringKey.strokeWidth.rawValue     : 1.0
    ]
}
