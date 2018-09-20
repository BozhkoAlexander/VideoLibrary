//
//  UIImageView.swift
//  video app
//
//  Created by Alexander Bozhko on 10/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import QuartzCore

extension String {
    
    func link(_ size: CGSize) -> String {
        guard !self.contains(".jpg") else { return self }
        let scale = UIScreen.main.scale
        return appendingFormat("%ix%i.jpg", Int(size.width * scale), Int(size.height * scale))
    }
    
}

extension UIImageView {
    
    func setImage(_ link: String?) {
        image = nil
        let link = link?.link(bounds.size)
        Images.load(link) { [weak self] (image, cached) in
            self?.image = image
            
            if !cached {
                let anim = CATransition()
                anim.duration = 0.2
                anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                anim.type = CATransitionType.fade
                self?.layer.add(anim, forKey: nil)
            }
        }
    }
    
}
