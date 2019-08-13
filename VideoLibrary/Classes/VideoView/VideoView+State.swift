//
//  VideoView+State.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 27/06/2019.
//

import UIKit

public extension BetaVideoView {
    
    enum State: UInt {
        
        case empty = 0
        
        case stopped = 1
        
        case playing = 2
        
        case paused = 3
        
        
        /// Flag shows required video layer opacity.
        public var videoLayerOpacity: Float {
            switch self {
            case .empty,
                 .stopped: return 0
            case .playing,
                 .paused: return 1
            }
        }
        
    }
    
}
