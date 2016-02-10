//
//  PlayerView.swift
//  ForceDuel
//
//  Created by Daniel Li on 10/13/15.
//  Copyright © 2015 DLG. All rights reserved.
//

import UIKit

class PlayerView: UIView {
    
    var playerNumber = 0
    
    let NecessaryForceDifferential: CGFloat = 0.3
    
    var force: CGFloat = 0.0 {
        didSet {
            forceDifferential = force - oldValue
        }
    }
    
    var forceInt: Int {
        return Int(force*100/6.6667)
    }
    
    var forceDifferential: CGFloat = 0.0 {
        didSet {
            forceDoubleDifferential = forceDifferential - oldValue
        }
    }
    
    var forceDoubleDifferential: CGFloat = 0.0
    
    // so that playerEntere is not posted whenever I move within the box
    var pressed = false
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSNotificationCenter.defaultCenter().postNotificationName("playerEntered", object: nil, userInfo: ["player" : playerNumber])
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            
            if !CGRectContainsPoint(self.frame, touch.locationInView(superview)) {
                pressed = false
                NSNotificationCenter.defaultCenter().postNotificationName("playerExited", object: nil, userInfo: ["player" : playerNumber])
            } else if pressed == false {
                NSNotificationCenter.defaultCenter().postNotificationName("playerEntered", object: nil, userInfo: ["player" : playerNumber])
                pressed = true
            }
            
            force = touch.force
            
            if force == touch.maximumPossibleForce {
                notifyBang()
            } else if forceDifferential > NecessaryForceDifferential {
                notifyBang()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSNotificationCenter.defaultCenter().postNotificationName("playerExited", object: nil, userInfo: ["player" : playerNumber])
    }
    
    func notifyBang() {
        NSNotificationCenter.defaultCenter().postNotificationName("playerBanged", object: nil, userInfo: ["player" : playerNumber])
    }
}
