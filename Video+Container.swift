//
//  Video+Container.swift
//  video app
//
//  Created by Alexander Bozhko on 20/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import Foundation
import AVKit

public extension Notification.Name {
    
    public static let VideoBuffered = Notification.Name("videoview-buffering")
    public static let VideoTimer = Notification.Name("videoview-timer")
    public static let VideoPlayPressed = Notification.Name("videoview-play")
    public static let VideoPausePressed = Notification.Name("videoview-pause")
    public static let VideoResync = Notification.Name("videoview-resync")
    
}

public extension Video {
    
    /** Video status */
    public enum Status {
        case empty
        case loading
        case playing
        case stopped
        case paused
        case ended
    }
    
    /** AVPlayer - retrieved video player, Bool - cached (true) */
    public typealias Callback = (Container?, Bool) -> Void
    
    /** The object which is sent in VideoTimer notification */
    public typealias TimerInfo = (Container, String)
    
    /** Video containter */
    public class Container: NSObject {
        
        // MARK: - Properties
        
        public var player: AVPlayer
        public var item: AVPlayerItem

        private var timer: Any! = nil
        
        // MARK: - KVO
        
        private let kvo = [
            #keyPath(AVPlayerItem.isPlaybackBufferEmpty),
            #keyPath(AVPlayerItem.isPlaybackBufferFull),
            #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp),
            #keyPath(AVPlayerItem.status)
        ]
        
        override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard keyPath != nil else { return }
            NotificationCenter.default.post(name: .VideoBuffered, object: self)
        }
        
        // MARK: - Life cycle
        
        public init(player: AVPlayer, item: AVPlayerItem) {
            self.player = player
            self.item = item
            super.init()
            
            addObservers()
        }
        
        deinit {
            removeObservers()
        }
        
        private func addObservers() {
            kvo.forEach({
                item.addObserver(self, forKeyPath: $0, options: .new, context: nil)
            })
            
            timer = player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: .main) { [weak self] (time) in
                guard let this = self else { return }
                guard time != kCMTimeZero else { return }
                let remain = this.item.duration.seconds - time.seconds
                guard !remain.isNaN && !remain.isZero else { return }
                let minutes = Int(remain) / 60
                let seconds = Int(remain) % 60
                let string = String(format: "%02i:%02i", minutes, seconds)
                let info: TimerInfo = (this, string)
                NotificationCenter.default.post(name: .VideoTimer, object: info)
            }
        }
        
        private func removeObservers() {
            kvo.forEach({
                item.removeObserver(self, forKeyPath: $0)
            })
            
            timer = nil
        }
        
        // MARK: - Player interaction
        
        public func play() {
            self.player.play()
        }
        
        public func stop() {
            self.player.seek(to: kCMTimeZero)
            self.player.pause()
        }
        
        public func pause() {
            self.player.pause()
        }
        
        public func bufferingStatus() -> Status? {
            guard item.status != .failed else { return .empty }
            if item.isPlaybackBufferEmpty {
                return .loading
            } else if item.isPlaybackLikelyToKeepUp || item.isPlaybackBufferFull {
                if player.rate > 0 {
                    return .playing
                } else {
                    return .stopped
                }
            }
            return nil
        }
        
    }
    
}
