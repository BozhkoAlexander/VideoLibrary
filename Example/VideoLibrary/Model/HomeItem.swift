//
//  HomeItem.swift
//  video app
//
//  Created by Alexander Bozhko on 10/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

typealias HomeBlock = (Array<HomeItem>, Error?) -> Void

public class HomeItem: NSObject {
    
    @objc var video: String? = nil
    @objc var image: String? = nil
    @objc var title: String? = nil
    var autoplay: Bool = true
    
    init(video: String?, image: String?, title: String?, autoplay: Bool) {
        super.init()
        
        self.video = video
        self.image = image
        self.title = title
        self.autoplay = autoplay
    }
    
    class func fetchHome(_ completion: HomeBlock?) {
        let results = bank.shuffled()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion?(results, nil)
        }
    }
    
    private static let bank: Array<HomeItem> = [
        HomeItem(
            video: "https://cs531631.vkuservideo.net/9/u141348517/videos/14fb1074ad.720.mp4?extra=qbsmmCQ6MnJUhUo1KdbdAzfFKiYVVqyq10JjIbGLL4xgSgtHthaCxCCf8mCGSxms0cgvJuKr6PyWWECHzKUb88JAyk9vud8_X6yiWGDrBsiKrgvdKtLDD_LSBBLpGYVgFdwca6NreyKgXA",
            image: "https://cdna.artstation.com/p/assets/images/images/006/350/552/large/shawn-kassian-05.jpg",
            title: "Anthem",
            autoplay: true),
        HomeItem(
            video: "http://video.filmweb.no/16107561/18266890/64073bd582b4e2a5187b3846f498aed6/video_medium/alpha-trailer-video.mp4",
            image: "https://imagesdev.filmgrail.com/MovieBySubApp/752554/2/2/030720181144/",
            title: "Alpha",
            autoplay: true),
        HomeItem(
            video: "http://video.filmweb.no/27288169/28158257/23fec936b8eec0388e41dc2800d69ee1/video_medium/the-happytime-murders-1-video.mp4",
            image: "https://imagesdev.filmgrail.com/MovieBySubApp/777178/2/2/030720181144/",
            title: "The happytime murders",
            autoplay: true),
        HomeItem(
            video: "http://video.filmweb.no/27288173/27307404/6db6f581d3ed417cb3ec78465e3f7296/video_medium/de-utrolige-2-trailer-2-norsk-tale-video.mp4",
            image: "https://imagesdev.filmgrail.com/MovieBySubApp/594204/2/2/030720181144/",
            title: "De utrolige 2",
            autoplay: true),
        HomeItem(
            video: "http://video.filmweb.no/9826383/27792573/5da64333c81d275602812580d84ce40f/video_medium/en-affaere-video.mp4",
            image: "https://imagesdev.filmgrail.com/MovieBySubApp/777180/2/2/030720181144/",
            title: "En affaere",
            autoplay: true),
        HomeItem(
            video: "http://video.filmweb.no/27288172/28180999/7c53f66099033e71c246818aca09f0df/video_medium/cinema-paradiso-video.mp4",
            image: "https://imagesdev.filmgrail.com/MovieBySubApp/73/2/2/030720181144/",
            title: "Cinema Paradiso",
            autoplay: true),
        HomeItem(
            video: "http://video.filmweb.no/19476792/21315237/6aca0b64767923d02915f30a6da32df1/video_medium/mission-impossible-fallout-trailer-1-video.mp4",
            image: "https://imagesdev.filmgrail.com/MovieBySubApp/752557/11/2/210620181749/",
            title: "Mission impossible: Fallout",
            autoplay: true),
        HomeItem(
            video: "http://video.filmweb.no/27288169/27606507/661d52f5e7dea92579204e32c68c9ccd/video_medium/skyscraper-trailer-2-video.mp4",
            image: "https://imagesdev.filmgrail.com/MovieBySubApp/753654/11/2/200620180748/",
            title: "Skyscraper",
            autoplay: true)
    ]
    
}
