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
    public static let VideoStop = Notification.Name("videoview-stop")
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
        
        public var isPlaying = true // if true then it needs to play video asap, else it needs to pause video
        
        public var player: AVPlayer
        public var item: AVPlayerItem

        private var timer: Any! = nil
        
        // MARK: - KVO
        
        private var bufferKVO: NSKeyValueObservation! = nil
        private var statusKVO: NSKeyValueObservation! = nil
        private var timeControlKVO: NSKeyValueObservation! = nil
        
        private func kvoChangeHandler() {
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
            statusKVO = item.observe(\.status, options: .initial, changeHandler: { [weak self] (_, _) in
                self?.kvoChangeHandler()
            })
            if #available(iOS 10.0, *) {
                timeControlKVO = player.observe(\.timeControlStatus, options: .initial, changeHandler: { [weak self] (_, _) in
                    self?.kvoChangeHandler()
                })
            } else {
                bufferKVO = item.observe(\.isPlaybackBufferEmpty, options: .initial, changeHandler: { [weak self] (_, _) in
                    self?.kvoChangeHandler()
                })
            }
            
            timer = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: .main) { [weak self] (time) in
                guard let this = self else { return }
                guard time != CMTime.zero else { return }
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
            statusKVO = nil
            timeControlKVO = nil
            bufferKVO = nil
            
            timer = nil
        }
        
        // MARK: - Player interaction
        
        public func play() {
            isPlaying = true
            self.player.play()
        }
        
        public func stop() {
            isPlaying = false
            self.player.seek(to: CMTime.zero)
            self.player.pause()
        }
        
        public func pause() {
            isPlaying = false
            self.player.pause()
        }
        
        public func bufferingStatus() -> Status? {
            guard item.status != .failed else { return .empty }
            if #available(iOS 10.0, *) {
                switch player.timeControlStatus {
                case .waitingToPlayAtSpecifiedRate: return .loading
                case .paused: return item.currentTime() == CMTime.zero ? .stopped : .paused
                case .playing: return .playing
                }
            } else {
                if item.isPlaybackBufferEmpty { // if buffer is empty
                    return .loading
                } else {
                    if isPlaying { // if we want to play video
                        return .playing
                    } else {
                        return item.currentTime() == CMTime.zero ? .stopped : .paused
                    }
                }
            }

        }
        
    }
    
}
