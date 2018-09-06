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
        do {
            try audio.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {}
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
    
    public func load(_ link: String?, callback: Callback?) {
        guard let link = link, let url = URL(string: link) else {
            callback?(nil, false)
            return
        }
        guard !loadingKeys.contains(link) else { return }
        if let cached = Cache.videos.object(forKey: link as NSString) {
            callback?(cached, true)
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
                switch status {
                case .loaded: break
                case .failed, .cancelled:
                    print("VIDEO: Failed to load asset successfully")
                    DispatchQueue.main.async {
                        callback?(nil, false)
                        if let index = this.loadingKeys.index(of: link) {
                            this.loadingKeys.remove(at: index)
                        }
                    }
                    return
                default:
                    print("VIDEO: Unkown state of asset")
                    DispatchQueue.main.async {
                        callback?(nil, false)
                        if let index = this.loadingKeys.index(of: link) {
                            this.loadingKeys.remove(at: index)
                        }
                    }
                    return
                }
                let player = AVPlayer()
                player.isMuted = this.isMuted
                let item = AVPlayerItem(asset: asset)
                let container = Container(player: player, item: item)
                DispatchQueue.main.async {
                    this.loadedKeys.append(link)
                    Cache.videos.setObject(container, forKey: link as NSString)
                    container.player.replaceCurrentItem(with: container.item)
                    callback?(container, false)
                    if let index = this.loadingKeys.index(of: link) {
                        this.loadingKeys.remove(at: index)
                    }
                }
            }
        }
    }
    
    /** Calculate current video in the collection view */
    public func sync(for scrollView: UIScrollView?) {
        guard let scrollView = scrollView else {
            loadedKeys.forEach { (link) in
                guard let container = Cache.videos.object(forKey: link as NSString) else { return }
                container.stop()
            }
            return
        }
        let visibleVideos = self.visibleCells(for: scrollView).filter({ $0.videoView != nil })
        var visibleFrame = scrollView.bounds
        if #available(iOS 11.0, *) {
            visibleFrame = UIEdgeInsetsInsetRect(scrollView.bounds, scrollView.safeAreaInsets)
        }
        let center = round(visibleFrame.midY)
        // calculate current video
        var result: (delta: CGFloat, cell: VideoCell)? = nil
        // if there is force link (play button pressed)
        if let link = forceVideo, !link.isEmpty {
            if let cell = visibleVideos.filter({ $0.videoView?.videoLink == link }).first {
                result = (delta: 0, cell: cell)
            }
        }
        // if there is no force link (usual way)
        if result == nil {
            let results = visibleVideos.compactMap({ cell -> (delta: CGFloat, cell: VideoCell)? in
                guard let videoFrame = cell.videoView?.frame, cell.videoView?.videoLink != nil else { return nil }
                let midY = cell.convert(videoFrame, to: scrollView).midY
                var delta = abs(center - midY)
                if cell.frame.minY < cell.bounds.midY || // for the first element
                    (scrollView.contentSize.height - cell.frame.maxY) < cell.bounds.midY { // for the last element
                    var insetFrame = scrollView.frame
                    if #available(iOS 11.0, *) {
                        insetFrame = UIEdgeInsetsInsetRect(scrollView.frame, scrollView.safeAreaInsets)
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
        
        // try to get current loaded container
        var current: Container? = nil
        if let link = result?.cell.videoView.videoLink {
            current = Cache.videos.object(forKey: link as NSString)
        }
        // stop all videos except current
        visibleVideos.forEach({ cell in
            guard result == nil || cell as UIView != result!.cell as UIView else { return }
            cell.videoView.update(status: .stopped, container: nil)
            cell.video(cell, didChangeStatus: .stopped, withContainer: nil)
        })
        loadedKeys.forEach { (link) in
            guard let container = Cache.videos.object(forKey: link as NSString), container != current else { return }
            container.stop()
        }
        // play or load
        guard let cell = result?.cell, let delta = result?.delta else { return }
        self.play(cell, delta: delta, for: scrollView, container: current)
    }
    
    public func play(_ cell: VideoCell, delta: CGFloat = 0, for scrollView: UIScrollView? = nil, container: Container? = nil) {
        if let container = container {
            if cell.videoView.autoplay || cell.videoView.videoLink == forceVideo {
                container.play()
                cell.videoView.setContainer(container)
                cell.videoView.update(status: .playing, container: container)
                cell.video(cell, didChangeStatus: .playing, withContainer: nil)
            } else {
                cell.videoView.update(status: .stopped, container: container)
                cell.video(cell, didChangeStatus: .stopped, withContainer: nil)
            }
        } else if let link = cell.videoView.videoLink {
            if !loadedKeys.contains(link) {
                cell.videoView.update(status: .loading, container: nil)
                cell.video(cell, didChangeStatus: .loading, withContainer: nil)
            }
            self.load(link) { [weak self] (container, cached) in
                guard container != nil else {
                    cell.videoView.update(status: .empty, container: nil)
                    cell.video(cell, didChangeStatus: .empty, withContainer: nil)
                    return
                }
                if scrollView != nil {
                    self?.sync(for: scrollView)
                } else {
                    self?.play(cell, delta: delta, for: scrollView, container: container)
                }
            }
        }
    }
    
    /** Pause video by pressing pause button */
    public func pause(_ link: String, cell: VideoCell? = nil, for scrollView: UIScrollView?) {
        self.forceVideo = nil
        if let container = Cache.videos.object(forKey: link as NSString) {
            container.pause()
        }
        if let cell = cell {
            // video did end displaying
            cell.videoView.update(status: .stopped, container: nil)
            cell.video(cell, didChangeStatus: .stopped, withContainer: nil)
        } else if let cell = self.visibleCells(for: scrollView).filter({ $0.videoView.videoLink == link }).first {
            // video paused by play button
            cell.videoView.update(status: .paused, container: nil)
            cell.video(cell, didChangeStatus: .paused, withContainer: nil)
        }
    }
    
    /** Stop video after it ends */
    public func finish(_ link: String, for scrollView: UIScrollView?) {
        forceVideo = nil
        if let container = Cache.videos.object(forKey: link as NSString) {
            container.stop()
        }
        guard let cell = self.visibleCells(for: scrollView).filter({ $0.videoView?.videoLink == link }).first else { return }
        cell.videoView.update(status: .ended, container: nil)
        cell.video(cell, didChangeStatus: .ended, withContainer: nil)
    }
    
    /** Buffering for a video */
    public func buffering(_ container: Container, for scrollView: UIScrollView?) {
        guard let cell = self.visibleCells(for: scrollView).filter({ $0.videoView?.videoLayer.player == container.player }).first else { return }
        guard let status = container.bufferingStatus() else { return }
        cell.videoView.update(status: status, container: container)
        cell.video(cell, didChangeStatus: status, withContainer: container)
    }
    
    /** Sync view after transition */
    public func sync(for viewController: UIViewController?) {
        let scrollView = (viewController as? VideoViewController)?.videoController.scrollView
        self.visibleCells(for: scrollView).compactMap({ $0.videoView }).forEach({
            $0.setupControlsTimer()
        })
        Video.shared.sync(for: scrollView)
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
        let playing = loadedKeys.compactMap({ Cache.videos.object(forKey: $0 as NSString) }).filter({ $0.player.rate > 0 })
        playing.forEach({
            guard let link = ($0.item.asset as? AVURLAsset)?.url.absoluteString else { return }
            NotificationCenter.default.post(name: .VideoPausePressed, object: link)
        })
        
    }
    
    // MARK: - Helpers
    
    private func visibleCells(for scrollView: UIScrollView?) -> Array<VideoCell> {
        if let collectionView = scrollView as? UICollectionView {
            return collectionView.visibleCells.compactMap({ $0 as? VideoCell })
        } else if let tableView = scrollView as? UITableView {
            return tableView.visibleCells.compactMap({ $0 as? VideoCell })
        }
        return []
    }
    
}
