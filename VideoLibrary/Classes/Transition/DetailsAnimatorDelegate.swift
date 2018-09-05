//
//  DetailsAnimatorDelegate.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 05/09/2018.
//

import UIKit

public protocol DetailsAnimatorDelegate {
    
    func prepare(using transitionContext: UIViewControllerContextTransitioning, isPresentation: Bool)
    func animate(using transitionContext: UIViewControllerContextTransitioning, isPresentation: Bool)
    func finish(using transitionContext: UIViewControllerContextTransitioning, isPresentation: Bool)
    
}
