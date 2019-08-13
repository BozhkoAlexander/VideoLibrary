//
//  TestViewController.swift
//  VideoLibrary_Example
//
//  Created by Alexander Bozhko on 27/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import VideoLibrary

class TestViewController: UIViewController, VideoViewDelegate {
    
    // MARK: - Properties
    
    var testView: TestView! { return view as? TestView }
    
    // MARK: - Life cycle
    
    override func loadView() {
        view = TestView(for: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "New video view"
        testView.videoView.link = "https://video-ver.azureedge.net/stories/videos/SP2_GIF_RELAXING_1x1_OV_EN_TXTD_H264_no%20(1).mp4"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        testView.videoView.play()
    }
    
    // MARK: - Video view delegate
    
    func videoView(_ videoView: BetaVideoView, didChangedState state: BetaVideoView.State) {
        testView.statusLabel.text = "\(state)"
    }

}
