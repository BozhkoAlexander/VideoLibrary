//
//  Images.swift
//  video app
//
//  Created by Alexander Bozhko on 10/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

class Images {
    
    /** UIImage - retrieved image, Bool - cached (true) */
    typealias Callback = (UIImage?, Bool) -> Void
    
    internal init() {}
    
    class func load(_ link: String?, callback: Callback?) {
        guard let link = link else {
            callback?(nil, false)
            return
        }
        if let cached = Cache.images.object(forKey: link as NSString) {
            callback?(cached, true)
        } else {
            API.loadImage(link) { (image, nil) in
                if let image = image {
                    Cache.images.setObject(image, forKey: link as NSString)
                }
                callback?(image, false)
            }
        }
    }
    
}
