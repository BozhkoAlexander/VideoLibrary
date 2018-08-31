//
//  VideoController.swift
//  video app
//
//  Created by Alexander Bozhko on 29/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import AVKit

public protocol VideoViewController {
    var videoController: VideoController { get set }
}

public class VideoController: NSObject, UICollectionViewDelegate, UITableViewDelegate {
    
    // MARK: - Properties
    
    weak var scrollView: UIScrollView? = nil
    
    // MARK: - Life cycle
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemBuffering(_:)), name: .VideoBuffered, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemPlayPressed(_:)), name: .VideoPlayPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemPausePressed(_:)), name: .VideoPausePressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.syncVideo), name: .VideoResync, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: .VideoBuffered, object: nil)
        NotificationCenter.default.removeObserver(self, name: .VideoPlayPressed, object: nil)
        NotificationCenter.default.removeObserver(self, name: .VideoPausePressed, object: nil)
        NotificationCenter.default.removeObserver(self, name: .VideoResync, object: nil)
    }
    
    // MARK: - AVPlayer notifications
    
    @objc func itemDidPlayToEndTime(_ notification: Notification) {
        guard let link = ((notification.object as? AVPlayerItem)?.asset as? AVURLAsset)?.url.absoluteString else { return }
        Video.shared.finish(link, for: scrollView)
    }
    
    @objc func itemBuffering(_ notification: Notification) {
        guard let container = notification.object as? Video.Container else { return }
        Video.shared.buffering(container, for: scrollView)
    }
    
    @objc func itemPlayPressed(_ notification: Notification) {
        Video.shared.sync(for: scrollView)
    }
    
    @objc func itemPausePressed(_ notification: Notification) {
        guard let link = notification.object as? String else { return }
        Video.shared.pause(link, for: scrollView)
    }
    
    @objc func syncVideo() {
        Video.shared.sync(for: scrollView)
    }
    
    // MARK: - Feature methods (needs to be called in view controller which support video view)
    
    /** Call in viewDidLoad */
    public func setupScrollView(_ scrollView: UIScrollView?) {
        self.scrollView = scrollView
    }
    
    /** Call in viewDidAppear and any other place where needs to resync video. */
    public func sync() {
        self.syncVideo()
    }
    
    /** Call in scrollViewDidEndDragging */
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { syncVideo() }
    }
    
    /** Call in scrollViewDidEndDecelerating */
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        syncVideo()
    }
    
    /** Call in collectionView didEndDisplaying */
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? VideoCell, let link = cell.videoView.videoLink {
            Video.shared.pause(link, cell: cell, for: collectionView)
        }
    }
    
    /** Call in collectionView didSelectItemAt */
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? VideoCell else { return }
        cell.videoView.setupControlsTimer()
    }
    
    /** Call in tablView didEndDisplaying */
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? VideoCell, let link = cell.videoView.videoLink {
            Video.shared.pause(link, cell: cell, for: tableView)
        }
    }
    
    /** Call in tableView didSelectRow */
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? VideoCell else { return }
        cell.videoView.setupControlsTimer()
    }
    
}
