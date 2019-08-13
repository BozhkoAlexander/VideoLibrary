//
//  VideoViewDelegate.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 27/06/2019.
//

import UIKit

public protocol VideoViewDelegate: class {
    
    /// Calls when the state of the video view has changed.
    func videoView(_ videoView: BetaVideoView, didChangedState state: BetaVideoView.State)
    
}
