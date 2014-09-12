//
//  GameSceneiOSExtensions.swift
//  SKSpeedRunJAS1
//
//  Created by Jim on 8/23/14.
//  Copyright (c) 2014 mutualmobile.com. All rights reserved.
//

import Foundation
import UIKit

extension GameScene {
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch : UITouch = touches.anyObject() as UITouch
        let x = touch.locationInNode(self).x
//        println("x: \(x), y:\(touch.locationInNode(self).y)")
        switch x {
        case 0 ..< 256:
            currentShipMovement = ShipMovement.Left
        case 512 ..< 768:
            currentShipMovement = ShipMovement.Right
        default:
            self.fireLaser()
        }

    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent!)  {
        let touch : UITouch = touches.anyObject() as UITouch
        let x = touch.locationInNode(self).x
        switch x {
        case 0 ..< 256, 512 ..< 768:
            currentShipMovement = ShipMovement.None
        default:
            break
        }

    }

}
