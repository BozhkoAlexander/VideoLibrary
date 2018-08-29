//
//  Cache.swift
//  Video Library
//
//  Created by Alexander Bozhko on 29/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import Foundation

class Cache {
    
    internal init() {}

    static let videos = NSCache<NSString, Video.Container>()
    
}

