//
//  Error.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 04/03/2019.
//

import Foundation

// MARK: - Quick errors for VideoLibrary

extension NSError {
    
    /// Returns unknown error of video loading process
    static var unknown: NSError {
        return NSError(domain: "com.filmgrail.videolibrary", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "An error has occurred"
        ])
    }
    
}
