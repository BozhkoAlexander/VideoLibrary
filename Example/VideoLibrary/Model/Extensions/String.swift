//
//  String.swift
//  video app
//
//  Created by Alexander Bozhko on 21/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

extension String {
    
    func boundingRect(with size: CGSize, font: UIFont) -> CGRect {
        return (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    }
    
}
