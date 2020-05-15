//
//  Colors.swift
//  NightLight
//
//  Created by Dan on 10/4/19.
//  Copyright © 2019 Dan Panzarella. All rights reserved.
//

import UIKit


extension UIColor {
    public static var trafficLight: UIColor {
        let base = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: {(traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 0.1)
                }
                return base
            })
        }
        return base
    }
    
    public static var trafficRed: UIColor {
        let base = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: {(traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 0.5, green: 0, blue: 0, alpha: 0.1)
                }
                return base
            })
        }
        return base
    }
    
    public static var trafficYellow: UIColor {
        let base = UIColor(red: 0.7, green: 0.7, blue: 0, alpha: 1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: {(traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.1)
                }
                return base
            })
        }
        return base
    }
    
    public static var trafficGreen: UIColor {
        let base = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
        if #available(iOS 13, *) {
            return UIColor(dynamicProvider: {(traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
                }
                return base
            })
        }
        return base
    }
}
