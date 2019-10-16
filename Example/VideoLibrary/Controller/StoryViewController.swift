//
//  StoryViewController.swift
//  VideoLibrary_Example
//
//  Created by Alexander Bozhko on 15/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import VideoLibrary

class StoryViewController: ViewController, VideoViewController {
    
    var videoController = VideoController()
    
    func shouldPlayVideo(_ element: VideoElement) -> Bool {
        return true
    }
    
    var storyView: StoryView! { return view as? StoryView }

    override func loadView() {
        view = StoryView(self, closeAction: #selector(close))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoController.setup(storyView, for: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let video = "http://video.filmweb.no/16107561/18266890/64073bd582b4e2a5187b3846f498aed6/video_medium/alpha-trailer-video.mp4"
        storyView.videoView.setVideo(video)
        
        Video.shared.forceVideo = nil
        videoController.sync()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Video.shared.forceVideo = nil
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

}
