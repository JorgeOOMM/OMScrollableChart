//
//  CALayerHandler.swift
//  Example
//
//  Created by Jorge Ouahbi on 30/08/2020.
//  Copyright © 2020 dsp. All rights reserved.
//

import UIKit
import GUILib

public extension CALayer {
    static var isAnimatingLayers: Int = 0
    func add(_ anim: CAAnimation,
             forKey key: String?,
             withCompletion completion: ((Bool) -> Void)?) {
        CALayer.isAnimatingLayers += 1
        anim.completion = {  complete in
            completion?(complete)
            if complete {
                CALayer.isAnimatingLayers -= 1
            }
        }
        add(anim, forKey: key)
    }
}
