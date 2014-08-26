//
//  GameScene.swift
//  SKSpeedRunJAS1
//
//  Created by Jim on 8/23/14.
//  Copyright (c) 2014 mutualmobile.com. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var shipNode = SKSpriteNode(imageNamed: "ship")
    var currentShipMovement = ShipMovement.None
    
    enum ShipMovement {
        case Left, Right, None;
    }
    
    var playerShot: SKNode?
    
    var scoreNode = SKLabelNode()
    var score: Int = 0
    
    let alienCount = 30
    
    var aliens: [SKSpriteNode] = []

    var alienOffset = 0
    var gameStartTime :CFTimeInterval?

    enum ColliderType: UInt32 {
        case PlayerShot = 0b0001
        case PlayerShip = 0b0010
        case AlienShot =  0b0100
        case AlienShip =  0b1000
    }

    
//MARK: - Overrides
    
    override func didMoveToView(view: SKView) {
        // local funcs
        let names = [
            "SoundAssets/death.wav",
            "SoundAssets/shot.wav",
            "SoundAssets/enemyDeath.wav",
            "SoundAssets/flying.wav"]
        func preloadSounds() {
            for soundName in names {
                let preloadSoundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: false)
            }
        }
        
        // code execution starts
        self.physicsWorld.contactDelegate = self
//        self.backgroundColor = SKColor.blackColor()
        preloadSounds()
        self.setupNodes()
    }

    var attackingAlienIndex: Int? = nil

    override func update(currentTime: CFTimeInterval) {
        // local funcs
        func updateShipPosition() {
            switch currentShipMovement {
            case .Left:
                shipNode.position.x -= 3
            case .Right:
                shipNode.position.x += 3
            case .None:
                break
            }
        }
        
        func updateAlienPositions(currentTime: CFTimeInterval) {
            if let gameStartTime = self.gameStartTime {
                
                let elapsedTime = (currentTime - gameStartTime)
                let movementPhase = Int( elapsedTime / 2 % 4 )
//                println("phase: \(movementPhase)")
                switch movementPhase {
                case 0:
                    self.alienOffset--
                case 2:
                    self.alienOffset++
                default:
                    break
                }
                
                for (index, alien) in enumerate( self.aliens ) {
                    if index == self.attackingAlienIndex || alien.physicsBody.categoryBitMask == 0 {
                        continue;
                    }
                    alien.position = positionForAlienAtIndex(index)
                }
            } else {
                self.gameStartTime = currentTime
            }
        }
        
        func handleAttacks() {
            // local funcs
            func startAttackRunForAlienAtIndex(i:Int) {
                let alienNode = self.aliens[i]
                if (alienNode.parent != nil) {
                    let isOnLeftSide = alienNode.position.x < ( self.frame.size.width / 2.0 )
                    let rotationAngle = CGFloat( isOnLeftSide ? -3.1415 : 3.1415 )
                    let soundEffectAction = SKAction.playSoundFileNamed("SoundAssets/flying.wav", waitForCompletion: false)
                    let rotateAction = SKAction.rotateByAngle(rotationAngle, duration: 1.0)
                    let compoundAction = SKAction.group([soundEffectAction!, rotateAction!])
                    alienNode.runAction( compoundAction )
                    
                    if let physicsBody = alienNode.physicsBody {
                        physicsBody.affectedByGravity = true
                        physicsBody.velocity = CGVectorMake(0, 100)
                    }
                    
                    self.attackingAlienIndex = i
//                    println("\(alienNode.physicsBody)")
                }
            }
            
            func handleAttackingAlien( attackingAlienIndex: Int ) {
                // local funcs
                func handleAlienShooting(attackingAlienNode: SKSpriteNode) {
                    let alienShotNode = SKSpriteNode(color: SKColor.yellowColor(), size: CGSizeMake(3, 10))
                    alienShotNode.position = CGPointMake(attackingAlienNode.position.x, attackingAlienNode.position.y - 10)
                    
                    alienShotNode.physicsBody = SKPhysicsBody(rectangleOfSize: alienShotNode.size)
                    alienShotNode.physicsBody.categoryBitMask = ColliderType.AlienShot.toRaw()
                    alienShotNode.physicsBody.velocity = CGVectorMake(attackingAlienNode.physicsBody.velocity.dx, -500)
                    alienShotNode.physicsBody.affectedByGravity = false
                    alienShotNode.physicsBody.collisionBitMask = 0
                    
                    self.addChild( alienShotNode )
                }
                
                // execution...
                let attackingAlienNode = self.aliens[attackingAlienIndex]
                
                if ( attackingAlienNode.position.y < 0.0 ) || ( attackingAlienNode.parent == nil ) {
                    // put alien back in formation
                    attackingAlienNode.physicsBody.velocity = CGVectorMake(0, 0)
                    attackingAlienNode.position = self.positionForAlienAtIndex( attackingAlienIndex )
                    attackingAlienNode.physicsBody.affectedByGravity = false
                    attackingAlienNode.zRotation = 0
                    self.attackingAlienIndex = nil
                } else {
                    // apply force toward center of screen
                    let isOnLeftSide = attackingAlienNode.position.x < ( self.frame.size.width / 2.0 )
                    let forceVector = CGVectorMake(isOnLeftSide ? 10: -10, 0)
                    attackingAlienNode.physicsBody.applyForce(forceVector)
                    if ( arc4random() % 100 == 0 ) {
                        handleAlienShooting(attackingAlienNode)
                    }
                }
                
            }
            
            // execution...
            if let attackingAlienIndex = self.attackingAlienIndex {
                handleAttackingAlien(attackingAlienIndex)
            } else {
                var alienIndex = Int( arc4random_uniform( UInt32( alienCount ) ) )
                startAttackRunForAlienAtIndex(alienIndex)
            }
        }
        
        // execution...
        updateShipPosition()
        updateAlienPositions(currentTime)
        handleAttacks()
    }

//MARK: - Must be exposed for both Setup and Update
    
    func positionForAlienAtIndex(i:Int) -> CGPoint {
        let cols = 10
        let x = 200 + i % cols * 47 + self.alienOffset
        let y = 924 - i / cols * 43
        return CGPointMake(CGFloat(x), CGFloat(y))
    }

//MARK: - Setup
    
    func setupNodes() {
        // local funcs
        func setupStarfield() {
            // local funcs
            func starfield() -> SKEmitterNode {
                let node = SKEmitterNode()
                node.particleTexture = SKTexture(imageNamed: "spark.png")
                node.particleBirthRate = 25
                node.particleLifetime = 5
                node.particlePositionRange = CGVector(1000, 0)
                node.emissionAngle = 270.0 * CGFloat(M_PI/180.0)
                node.particleSpeed = 250
                node.particleSpeedRange = 200
                node.particleAlpha = 1
                node.particleScale = 0.1
                node.particleColorBlendFactor = 0.5
                return node
            }            // execution...
            let starfieldNode = starfield()
            starfieldNode.position = CGPointMake( CGRectGetMidX(self.frame), CGRectGetHeight(self.frame))
            
            starfieldNode.particleColorSequence = nil
            starfieldNode.particleColor = SKColor.redColor()
            starfieldNode.particleColorBlueRange = 255.0
            starfieldNode.particleColorGreenRange = 255.0
            
            self.addChild(starfieldNode)
        }
        
        func setupShipNode() {
            // local funcs
            func setupPhysics(shipNode: SKSpriteNode) {
                shipNode.physicsBody = SKPhysicsBody(rectangleOfSize: shipNode.size)
                shipNode.physicsBody.categoryBitMask = ColliderType.PlayerShip.toRaw()
                shipNode.physicsBody.contactTestBitMask = ColliderType.AlienShip.toRaw() | ColliderType.AlienShot.toRaw()
                shipNode.physicsBody.collisionBitMask = 0
                shipNode.physicsBody.affectedByGravity = false
            }
            
            shipNode.position = CGPointMake( CGRectGetMidX(self.frame), 50)
            shipNode.size = CGSizeMake( CGRectGetWidth( shipNode.frame ) * 2, CGRectGetHeight( shipNode.frame ) * 2 )
            
            let shipRange: SKRange = SKRange(lowerLimit: 50.0, upperLimit: 718.0)
            let shipConstraint = SKConstraint.positionX( shipRange )
            shipNode.constraints = [shipConstraint!]
            
            setupPhysics(shipNode)
            
            self.addChild(shipNode)
        }
        
        func setupScoreNode() {
            scoreNode.fontName = "Futura-CondensedExtraBold"
            scoreNode.fontSize = 18
            scoreNode.fontColor = SKColor.redColor()
            scoreNode.position = CGPointMake( 50, CGRectGetMaxY( self.frame ) - 55)
            scoreNode.text = "0"
            self.addChild( scoreNode )
            
            let oneUpNode = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
            oneUpNode.fontSize = 18
            oneUpNode.fontColor = SKColor.whiteColor()
            oneUpNode.position = CGPointMake( 50, CGRectGetMaxY( self.frame ) - 30)
            oneUpNode.text = "1 UP"
            self.addChild( oneUpNode )
        }
        
        func setupAliens() {
            // local funcs
            func setupPhysics(alienSprite: SKSpriteNode) {
                alienSprite.physicsBody = SKPhysicsBody(rectangleOfSize:alienSprite.size)
                alienSprite.physicsBody.categoryBitMask = ColliderType.AlienShip.toRaw()
                alienSprite.physicsBody.contactTestBitMask = ColliderType.PlayerShot.toRaw() | ColliderType.PlayerShip.toRaw()
                alienSprite.physicsBody.collisionBitMask = 0
                alienSprite.physicsBody.affectedByGravity = false
            }
            
            // execution...
            var aliens_ = [SKSpriteNode]()
            
            let textures: [AnyObject]! = [
                SKTexture(imageNamed: "redalien1"),
                SKTexture(imageNamed: "redalien2"),
                SKTexture(imageNamed: "redalien3")]
            
            let animateAction = SKAction.animateWithTextures(textures, timePerFrame: 0.5)
            let animateForeverAction = SKAction.repeatActionForever(animateAction)
            
            for j in 0 ..< alienCount {
                var alienSprite = SKSpriteNode(imageNamed: "redalien1")
                alienSprite.position = positionForAlienAtIndex( j )
                setupPhysics(alienSprite)
                self.addChild(alienSprite)
                alienSprite.runAction(animateForeverAction)
                aliens_.append( alienSprite )
            }
            self.aliens = aliens_
        }
        
        // execution...
        setupStarfield()
        setupShipNode()
        setupScoreNode()
        setupAliens()
    }

//MARK: - Fire the "LASER"
    
    func fireLaser()->Void {
        // local funcs
        var setupPhysics : (playerShot: SKSpriteNode) -> Void
        setupPhysics = {(playerShot: SKSpriteNode) -> Void in
            playerShot.physicsBody = SKPhysicsBody(rectangleOfSize: playerShot.size)
            playerShot.physicsBody.categoryBitMask = ColliderType.PlayerShot.toRaw()
            playerShot.physicsBody.collisionBitMask = 0
            playerShot.physicsBody.affectedByGravity = false;
        }

        // execution...
        if (self.playerShot == nil) && (self.shipNode.parent != nil) {
            let playerShot = SKSpriteNode(color: SKColor.yellowColor(), size: CGSizeMake(3, 10))
            playerShot.position = CGPointMake( shipNode.position.x, shipNode.position.y - 15 )
            
            let moveAction = SKAction.moveBy(CGVectorMake(0, 1000), duration: 1.2)
            let removeBulletAction = SKAction.runBlock() {
                playerShot.removeFromParent()
                self.playerShot = nil
            }
            
            let actionSequence = SKAction.sequence([moveAction!, removeBulletAction!])
            let soundAction = SKAction.playSoundFileNamed("SoundAssets/shot.wav", waitForCompletion: false)
            let compoundAction = SKAction.group([actionSequence!, soundAction!])
            
            setupPhysics(playerShot: playerShot)
            
            self.addChild(playerShot)
            self.playerShot = playerShot
            playerShot.runAction(compoundAction!)
        }
    }

    func scorePoints( points: Int ) {
        self.score += points
        scoreNode.text = "\(self.score)"
    }
    
//MARK: - SKPhysicsContactDelegate
    
    func didBeginContact(contact: SKPhysicsContact!) {
        // local funcs
        func destroyAlien(alienNode: SKNode ) {
            let soundEffectAction = SKAction.playSoundFileNamed("SoundAssets/enemyDeath.wav", waitForCompletion: false)
            let scaleAction = SKAction.scaleBy(0, duration: 1)
            let rotateAction = SKAction.rotateByAngle( -2, duration: 1)
            let fadeAction = SKAction.fadeOutWithDuration(1)
            let removeAction = SKAction.runBlock() {
                alienNode.removeFromParent()
            }
            let rotateAndFadeAction = SKAction.group([rotateAction!, scaleAction!, fadeAction!, soundEffectAction!])
            let completeAction = SKAction.sequence([rotateAndFadeAction!, removeAction!])
            
            alienNode.runAction(completeAction)
            alienNode.physicsBody.affectedByGravity = true
            
            if let playerShot = self.playerShot {
                playerShot.removeFromParent()
                self.playerShot = nil
            }
            
            self.scorePoints(50)
        }
        
        func destroyShip() {
            let explosionSoundAction = SKAction.playSoundFileNamed("SoundAssets/death.wav", waitForCompletion: false)
            let colorAnimationAction = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1, duration: 0.5)
            let fadeAction = SKAction.fadeOutWithDuration(1)
            let compoundAction = SKAction.group([explosionSoundAction!, colorAnimationAction!, fadeAction!])
            let removeAction = SKAction.runBlock() {
                self.shipNode.removeFromParent()
            }
            
            let completeAction = SKAction.sequence([compoundAction!, removeAction!])
            
            shipNode.runAction(completeAction)
//            shipNode.physicsBody.categoryBitMask = 0
            
            let gameOverNode = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
            gameOverNode.position = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            gameOverNode.text = "GAME OVER"
            gameOverNode.alpha = 0
            gameOverNode.runAction(SKAction.fadeInWithDuration(1))
            self.addChild(gameOverNode)
        }
        
        // execution...
        if contact.bodyA.categoryBitMask == ColliderType.AlienShip.toRaw() {
            destroyAlien( contact.bodyA.node )
        } else if contact.bodyB.categoryBitMask == ColliderType.AlienShip.toRaw() {
            destroyAlien( contact.bodyB.node )
        }
        
        if contact.bodyA.categoryBitMask == ColliderType.PlayerShip.toRaw() {
            destroyShip()
        } else if contact.bodyB.categoryBitMask == ColliderType.PlayerShip.toRaw() {
            destroyShip()
        }
    }
    
}


