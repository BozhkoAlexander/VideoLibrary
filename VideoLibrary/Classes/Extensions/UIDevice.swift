//
//  UIDevice.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 13/11/2018.
//

import UIKit

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    var isWeak: Bool {
        return modelName == "iPhone7,1"
    }
    
}
