//
//  VideoView+VideoLayerView.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 09.12.2019.
//

import UIKit
import AVKit

internal extension VideoView {
    
    class VideoLayerView: UIView {
        
        override class var layerClass: AnyClass {
            return AVPlayerLayer.self
        }
        
        init() {
            super.init(frame: .zero)
            
            (layer as? AVPlayerLayer)?.videoGravity = .resizeAspect
            (layer as? AVPlayerLayer)?.backgroundColor = UIColor.black.cgColor
        }
        
        required init?(coder: NSCoder) {
            return nil
        }
        
    }
    
}
