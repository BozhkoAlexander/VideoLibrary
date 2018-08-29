//
//  String.swift
//  Video Library
//
//  Created by Alexander Bozhko on 29/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

extension String {
    
    func boundingRect(with size: CGSize, font: UIFont) -> CGRect {
        let attributes: Dictionary<NSAttributedStringKey, Any> = [.font: font]
        return (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
    }
    
}
