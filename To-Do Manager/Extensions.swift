//
//  Extensions.swift
//  To-Do Manager
//
//  Created by burak kaya on 18/07/2019.
//  Copyright © 2019 burak kaya. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var name: UIColor? {
        switch self {
        case "black": return UIColor.black
        case "darkGray": return UIColor.darkGray
        case "lightGray" : return UIColor.lightGray
        case "white" : return UIColor.white
        case "gray": return UIColor.gray
        case "red":  return UIColor.red
        case "green": return UIColor.green
        case "blue" : return UIColor.blue
        case "cyan": return  UIColor.cyan
        case "yellow" : return UIColor.yellow
        case "magenta": return  UIColor.magenta
        case "orange" : return UIColor.orange
        case "purple" : return UIColor.purple
        case "brown" : return UIColor.brown
        default: return nil
        }
    }
}
