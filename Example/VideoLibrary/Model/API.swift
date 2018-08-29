//
//  API.swift
//  video app
//
//  Created by Alexander Bozhko on 10/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit
import AVKit

class API: NSObject {
    
    typealias ImageBlock = (UIImage?, Error?) -> Void
    
    // MARK: - Singletone
    
    internal override init() { super.init() }
    
    private static let shared = API()
    
    // MARK: - Public static methods
    
    public class func loadImage(_ link: String?, completion: ImageBlock?) {
        shared.loadImage(link, completion: completion)
    }
    
    // MARK: - Private methods
    
    private func loadImage(_ link: String?, completion: ImageBlock?) {
        guard let link = link, let url = URL(string: link) else {
            completion?(nil, nil)
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var image: UIImage? = nil
            if let data = data {
                image = UIImage(data: data)
            }
            DispatchQueue.main.async {
                completion?(image, error)
            }
        }
        task.resume()
    }

}
