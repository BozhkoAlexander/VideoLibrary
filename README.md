# VideoLibrary

[![CI Status](https://img.shields.io/travis/BozhkoAlexander/VideoLibrary.svg?style=flat)](https://travis-ci.org/BozhkoAlexander/VideoLibrary)
[![Version](https://img.shields.io/cocoapods/v/VideoLibrary.svg?style=flat)](https://cocoapods.org/pods/VideoLibrary)
[![License](https://img.shields.io/cocoapods/l/VideoLibrary.svg?style=flat)](https://cocoapods.org/pods/VideoLibrary)
[![Platform](https://img.shields.io/cocoapods/p/VideoLibrary.svg?style=flat)](https://cocoapods.org/pods/VideoLibrary)

The library is served to implement auto playable videos in a list (smth between Instagram and Facebook implementation). The point in this implementation is videos can be auto playable and non-auto playable (usual videos with play button).


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

VideoLibrary is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'VideoLibrary'
```
## Implementation

### Change your **AppDelegate.swift**

Add following code in your app delegate
```Swift
import VideoLibrary

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    ...
    
    func applicationWillResignActive(_ application: UIApplication) {
        Video.shared.resignActive()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Video.shared.didBecomeActive()
    }
    
    ...
}
```

### Implement videos support for UIVIewControll subclass

1. Create **UIViewController** subclass (I recommend to create base **UIViewController** subclass for all controllers which support videos. Smth like **VideoViewController**)
2. Add **VideoViewController** protocol and **videoController** property to your subclass
```Swift
class ViewController: UIViewController, VideoViewController ... {

    let videoController = VideoController()

...
}
```
3. Connect your collection view with video controller in **viewDidLoad** method (or in any other place where you want to enable video support)
```Swift
override func viewDidLoad() {
    super.viewDidLoad()

    videoController.setupCollectionView(self.view.collectionView)
}
```
4. Call sync method at least in **viewDidAppear** method. You should call it on any other place where you need to resync videos in list
```Swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    videoController.sync()
}
```
5. You have to call some methods in your **UICollectionViewDelegate** and **UIScrollViewDelegate**
```Swift
func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    videoController.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
}

func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    videoController.scrollViewDidEndDecelerating(scrollView)
}

func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    videoController.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    videoController.collectionView(collectionView, didSelectItemAt: indexPath)
}
```

## Author

BozhkoAlexander, alexander.bozhko@filmgrail.com

## License

VideoLibrary is available under the MIT license. See the LICENSE file for more info.
