//
//  Video.swift
//  video app
//
//  Created by Alexander Bozhko on 10/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import AVKit

public typealias VideoCell = UIView & VideoElement

public class Video: NSObject {
    
    // MARK: - Singletone
    
    public static let shared = Video()
    
    override internal init() {
        super.init()
        startObservers()
        if #available(iOS 10.0, *) {
            do {
                try audio.setCategory(.playback, mode: .default)
            }
            catch {}
        }
    }
    
    deinit {
        stopObservers()
    }
    
    // MARK: - Properties
    
    private let audio = AVAudioSession.sharedInstance()
    
    public var isMuted: Bool = true
    {
        didSet {
            guard isMuted != oldValue else { return }
            loadedKeys.compactMap({ Cache.videos.object(forKey: $0 as NSString) }).forEach({ container in
                container.player.isMuted = isMuted
            })
        }
    }
    
    private var isForeground = true
    
    // MARK: - KVO
    
    private func startObservers() {
        audio.addObserver(self, forKeyPath: #keyPath(AVAudioSession.outputVolume), options: .new, context: nil)
    }
    
    private func stopObservers() {
        audio.removeObserver(self, forKeyPath: #keyPath(AVAudioSession.outputVolume))
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath != nil else { return }
        self.isMuted = audio.outputVolume == 0
    }
    
    
    /** The video which is pressed */
    public var forceVideo: String? = nil
    
    private var loadedKeys = Array<String>()
    private var loadingKeys = Array<String>()
    
    /**
     Loads video asset by the link, creates Container object which contains asset, player and timer info.
     - Parameters:
        - link: url link to the video item
        - callback: callback to be invoked when the loading process is finished
     */
    public func load(_ link: String?, callback: Callback?) {
        guard let link = link, let url = URL(string: link) else {
            callback?(nil, false, NSError.unknown)
            return
        }
        guard !loadingKeys.contains(link) else { return }
        if let cached = Cache.videos.object(forKey: link as NSString) {
            callback?(cached, true, nil)
        } else {
            loadingKeys.append(link)
            let asset = AVURLAsset(url: url)
            let keys = ["playable"]
            asset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
                guard let this = self else { return }
                /**
                 Need to check whether asset loaded successfully, if not successful then don't create
                 AVPlayer and AVPlayerItem and return without caching the videocontainer,
                 so that, the assets can be tried to be downloaded again when need be.
                 */
                var error: NSError? = nil
                let status = asset.statusOfValue(forKey: "playable", error: &error)
                guard status == .loaded else {
                    print("VIDEO: Failed to load asset (\(status.stringValue))")
                    DispatchQueue.main.async {
                        callback?(nil, false, error)
                        if let index = this.loadingKeys.firstIndex(of: link) {
                            this.loadingKeys.remove(at: index)
                        }
                    }
                    return
                }
                let player = AVPlayer()
                player.isMuted = this.isMuted
                let item = AVPlayerItem(asset: asset)
                DispatchQueue.main.async {
                    let container = Container(player: player, item: item)
                    if !this.loadedKeys.contains(link) {
                        this.loadedKeys.append(link)
                    }
                    Cache.videos.setObject(container, forKey: link as NSString)
                    if Cache.videos.object(forKey: link as NSString) == nil { // fix for bug with full cache
                        Cache.videos.setObject(container, forKey: link as NSString)
                    }
                    this.loadedKeys = this.loadedKeys.filter({ Cache.videos.object(forKey: $0 as NSString) != nil })
                    
                    container.player.replaceCurrentItem(with: container.item)
                    callback?(container, false, nil)
                    if let index = this.loadingKeys.firstIndex(of: link) {
                        this.loadingKeys.remove(at: index)
                    }
                }
            }
        }
    }
    
    /** Pause video by pressing pause button */
    public func pause(_ link: String, cell: VideoCell? = nil, for controller: VideoController?) {
        self.forceVideo = nil
        if let container = Cache.videos.object(forKey: link as NSString) {
            container.pause()
        }
        if let cell = cell {
            // video did end displaying
            guard cell.videoView.status != .paused else { return }
            cell.videoView.update(status: .stopped, container: nil)
            cell.video(cell, didChangeStatus: .stopped, withContainer: nil)
        } else if let element = controller?.element(for: link) {
            // video paused by play button
            element.videoView.update(status: .paused, container: nil)
            element.video(element, didChangeStatus: .paused, withContainer: nil)
        }
    }
    
    /** Stop video after it ends */
    public func finish(_ link: String, for controller: VideoController?) {
        forceVideo = nil
        if let container = Cache.videos.object(forKey: link as NSString) {
            container.stop()
        }
        guard let element = controller?.element(for: link) else { return }
        element.videoView.update(status: .ended, container: nil)
        element.video(element, didChangeStatus: .ended, withContainer: nil)

    }
    
    /** Buffering for a video */
    public func buffering(_ container: Container, for controller: VideoController?) {
        guard let status = container.bufferingStatus() else { return }
        let link = (container.player.currentItem?.asset as? AVURLAsset)?.url.absoluteString
        if let element = controller?.element(for: link) {
            element.videoView.update(status: status, container: container)
            element.video(element, didChangeStatus: status, withContainer: container)
        }
    }
    
    /** Sync view controller */
    public func sync(for viewController: UIViewController?) {
        // calculate current video
        var result: (delta: CGFloat, cell: VideoElement)? = nil
        let presentedVC = UIViewController.presented()
        var isPresented = viewController == presentedVC
        if !isPresented, let vc = presentedVC {
            isPresented = !vc.children.filter({ $0 == viewController }).isEmpty
        }
        var visibleVideos = Array<VideoCell>()
        
        if let element = (viewController as? VideoViewController)?.videoController.videoView, isPresented { // if there is no scroll view, just simple video element in the view
            if element.videoView.autoplay {
                result = (delta: 0, cell: element)
            }
        } else if let scrollView = (viewController as? VideoViewController)?.videoController.scrollView { // if there is scroll view
            visibleVideos = scrollView.visibleVideoCells
            visibleVideos.forEach({
                $0.videoView?.setupControlsTimer()
            })
            var visibleFrame = scrollView.bounds
            if #available(iOS 11.0, *) {
                visibleFrame = scrollView.bounds.inset(by: scrollView.safeAreaInsets)
            }
            let center = round(visibleFrame.midY)
            
            // there is forced video (play button pressed)
            if let link = forceVideo, !link.isEmpty && isPresented {
                if let cell = visibleVideos.filter({ $0.videoView?.videoLink == link }).first {
                    result = (delta: 0, cell: cell)
                }
            }
            // if there is no force link (usual way)
            if result == nil && isPresented {
                let results = visibleVideos.compactMap({ cell -> (delta: CGFloat, cell: VideoElement)? in
                    guard let videoFrame = cell.videoView?.frame, cell.videoView?.videoLink != nil && cell.videoView.autoplay else { return nil }
                    let midY = cell.convert(videoFrame, to: scrollView).midY
                    var delta = abs(center - midY)
                    if cell.frame.minY < cell.bounds.midY || // for the first element
                        (scrollView.contentSize.height - cell.frame.maxY) < cell.bounds.midY { // for the last element
                        var insetFrame = scrollView.frame
                        if #available(iOS 11.0, *) {
                            insetFrame = scrollView.frame.inset(by: scrollView.safeAreaInsets)
                        }
                        let visibleHeight = cell.convert(videoFrame, to: nil).intersection(insetFrame).height
                        if visibleHeight >= videoFrame.height {
                            delta = 0
                        }
                    }
                    return (delta: delta, cell: cell)
                })
                result = results.sorted(by: { $0.delta < $1.delta }).first
            }
        } else { // there is nothing to play, stop all videos
            loadedKeys.forEach { (link) in
                guard link != forceVideo, let container = Cache.videos.object(forKey: link as NSString) else { return }
                container.stop()
            }
            return
        }
        
        // try to get current loaded container
        var current: Container? = nil
        if let link = result?.cell.videoView.videoLink {
            current = Cache.videos.object(forKey: link as NSString)
        }
        // stop all videos except current
        visibleVideos.forEach({ cell in
            guard result == nil || cell.videoView != result?.cell.videoView else { return }
            guard cell.videoView.status != .paused else { return }
            if let link = cell.videoView.videoLink, let container = Cache.videos.object(forKey: link as NSString) {
                container.stop()
            }
            cell.videoView.update(status: .stopped, container: nil)
            cell.video(cell, didChangeStatus: .stopped, withContainer: nil)
        })
        loadedKeys.forEach { (link) in
            guard link != forceVideo, let container = Cache.videos.object(forKey: link as NSString), container != current else { return }
            if container.isPlaying {
                container.stop()
            }
        }
        // play or load
        guard let cell = result?.cell, let delta = result?.delta else { return }
        guard cell.videoView.status != .paused else { return }
        self.play(cell, delta: delta, for: viewController, container: current)
    }
    
    public func play(_ cell: VideoElement, delta: CGFloat = 0, for viewController: UIViewController? = nil, container: Container? = nil) {
        if let container = container {
            if cell.videoView.autoplay || cell.videoView.videoLink == forceVideo {
                container.play()
                cell.videoView.setContainer(container)
                let status = container.bufferingStatus() ?? .loading
                cell.videoView.update(status: status, container: container)
                cell.video(cell, didChangeStatus: status, withContainer: nil)
            } else {
                cell.videoView.update(status: .stopped, container: container)
                cell.video(cell, didChangeStatus: .stopped, withContainer: nil)
            }
        } else if let link = cell.videoView.videoLink {
            if !loadedKeys.contains(link) {
                cell.videoView.update(status: .loading, container: nil)
                cell.video(cell, didChangeStatus: .loading, withContainer: nil)
            }
            cell.videoView.error = nil
            self.load(link) { [weak self] (container, cached, error) in
                // TODO: - send error to next methods
                cell.videoView.error = error
                guard container != nil else {
                    cell.videoView.update(status: .empty, container: nil)
                    cell.video(cell, didChangeStatus: .empty, withContainer: nil)
                    return
                }
                if viewController != nil {
                    self?.sync(for: viewController)
                } else {
                    self?.play(cell, delta: delta, for: viewController, container: container)
                }
            }
        }
    }
    
    /** Call when the app is going to background */
    public func resignActive() {
        isForeground = false
    }
    
    /** Call when the app did enter to foreground */
    public func didBecomeActive() {
        guard !isForeground else { return }
        isForeground = true
        NotificationCenter.default.post(name: .VideoResync, object: nil)
    }
    
    /** Call when it needs to simulate Pause button press */
    public func pause() {
        let playing = loadedKeys.compactMap({ Cache.videos.object(forKey: $0 as NSString) })
        playing.forEach({ $0.pause() })
        playing.filter({ $0.player.rate > 0 }).forEach({
            guard let link = ($0.item.asset as? AVURLAsset)?.url.absoluteString else { return }
            NotificationCenter.default.post(name: .VideoPausePressed, object: link)
        })
    }
    
    /** Call when the video view did end displaying and it needs to stop a played video */
    public func stop() {
        let playing = loadedKeys.compactMap({ Cache.videos.object(forKey: $0 as NSString) })
        playing.forEach({ $0.stop() })
        playing.filter({ $0.player.rate > 0 }).forEach({
            guard let link = ($0.item.asset as? AVURLAsset)?.url.absoluteString else { return }
            NotificationCenter.default.post(name: .VideoStop, object: link)
        })
    }
    
}

private extension AVKeyValueStatus {
    
    var stringValue: String {
        switch self {
        case .cancelled: return "canceled"
        case .failed: return "failed"
        case .loaded: return "loaded"
        case .loading: return "loading"
        case .unknown: return "unknown"
        @unknown default: return "unknown"
        }
    }
    
}
