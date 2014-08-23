//
//  GameScene.swift
//  SKSpeedRunJAS1
//
//  Created by Jim on 8/23/14.
//  Copyright (c) 2014 mutualmobile.com. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.blackColor()
        self.setupStarfield()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func setupStarfield() {
        let starfieldPath = NSBundle.mainBundle().pathForResource("Starfield", ofType: "sks")
        let starfieldNode = NSKeyedUnarchiver.unarchiveObjectWithFile(starfieldPath!) as SKEmitterNode
        starfieldNode.position = CGPointMake( CGRectGetMidX(self.frame), CGRectGetHeight(self.frame))
        
        starfieldNode.particleColorSequence = nil
        starfieldNode.particleColor = SKColor.redColor()
        starfieldNode.particleColorBlueRange = 255.0
        starfieldNode.particleColorGreenRange = 255.0
        
        self.addChild(starfieldNode)
    }

}
