//
//  GameSceneOSXExtensions.swift
//  SKSpeedRunJAS1
//
//  Created by Jim on 8/24/14.
//  Copyright (c) 2014 mutualmobile.com. All rights reserved.
//

import Cocoa

extension GameScene {

    override func keyDown(theEvent: NSEvent!)  {
        let keyCode = theEvent.keyCode
        switch keyCode {
        case 123:
            currentShipMovement = ShipMovement.Left
        case 124:
            currentShipMovement = ShipMovement.Right
        default:
            fireLaser()
        }

    }

    override  func keyUp(theEvent: NSEvent!)   {
        let keyCode = theEvent.keyCode
        switch keyCode {
        case 123, 124:
            currentShipMovement = ShipMovement.None
        default:
            break
        }
    }
}