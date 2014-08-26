# Sprite Kit Speed Run Speaker Notes

* (These notes are designed to be used with Jonathan Penn's excellent [KeyGrip](https://github.com/rubbercitywizards/KeyGrip) utility.)

* Pro tips
 - Have finder window open with assets
 - get rid of the GameScene.sks its a lie in b5, b6
 - Cut this into the flow...

         class GameViewController: UIViewController {

            override func viewDidLoad() {
                super.viewDidLoad()

                /* Pick a size for the scene */
                //let scene = GameScene(fileNamed:"GameScene")  
                let scene = GameScene(size: CGSizeMake(768, 1024));
                ...



## Introduction

Welcome to "Speed Run: Build a [Galaxian](http://en.wikipedia.org/wiki/Galaxian) Clone in 45 Minutes"! Thanks for coming out.

I'm Jim Stewart. I work for Mutual Mobile in Austin, Texas. We are an agency that specializes in emerging technology and mobile, with large clients like Google, Audi, Isis, Pearson Education, Lynda.com, and more. It's a great company in a great city in a great state, and if you'd like to hear more about any of them, catch me around the conference sometime and I'll be happy to chat about MM.

Let me tell you a little about what this talk is:

- A death-defying exercise in which I will build a functional game right before your eyes! (Disclaimer: code will be copied and pasted. Sound and graphic assets prepared in advance. Before beginning any strenuous coding exercise, please consult with your physician.)
- A quick practical tour of many of the major features of Sprite Kit.
- A demo of how Sprite Kit code can be used across platforms.

What this talk isn't:

- A 100% faithful recreation of Galaxian; in some cases I sacrifice fidelity for the sake of demoing SpriteKit features (and to get done in 45 minutes). Also, extreme pedants will note that some of the sound effects are actually from Galaga. If you have a problem with this, seek me out afterward for fisticuffs.
- A demonstration of good coding practices. I litter the code with magic numbers and do other reprehensible things for the sake of expediency. If you do these things in a real project, I will find you and break your coffee grinder.  
- I am also doing a bit of Yoda practice.. in order to hide some of the functionality I'm nesting methods, which can look a bit odd.  I'm still trying to get an aesthetic feel for Swift coding

With all those disclaimers out of the way, let's get started.

## Create New Project, Strip Template Code

* In Xcode, select New -> Project -> iOS Application -> Game
* Name it *SKSpeedRun*, Language *Swift*, set devices to iPad. Hit Next. Complete project creation.
* In the Deployment panel, Check Portrait, Upside-Down for Device Orientation.
* Run it to show what it does.

* Show **GameScene.swift**. 
  * *A scene in sprite kit is pretty much what is sounds like: a given environment for a game. You can have as many scenes as you like in your game, and each scene can contain a bunch of sprites. For this game, we'll only be creating a single scene.*
* *Let's strip out the sample code that Apple has provided us so that we'll have a clean slate to start with.*
  * In **GameScene.swift**, remove code under *didMoveToView* and delete *touchesBegan*
  * *Remove GameScene.sks -> we'll just code up our scene in the view controller by replacing the reference to GameScene with:*

        let scene = GameScene(size: CGSizeMake(768, 1024))
        scene.physicsWorld.gravity = CGVectorMake(0.0, -1)

because... beta.  

* *With Xcode 6, Apple has also provided a really cool visual Sprite Kit editor. We've not going to make a ton of use of the editor here because we're all coders, but we'll at least set a few initial parameters for our scene. 
I have had mixed results with it in beta 5/6 so I'll have a code backup ready!*

## Create Star Field

*A GameScene can contain hundreds of SKNodes. SKNodes come in all kinds of flavors; the one we're going to look at first is a particle emitter. Particle emitters basically spew out a bunch of particles according to the parameters that you set up. SpriteKit includes a super-fun editor for creating these, so we'll use that to create a star field for the background of our game.*

* Choose New -> File -> Resource -> SpriteKit Particle File
* Use Spark template, name it *Starfield*. Pull up Emitter editor.
* Discuss emitters. Mention that they have lots of properties, many (but not all) of which can be set in Xcode.
* Work through properties settings:  pull up starfield.png

NB: may not work in beta 5 or 6, have a code file ready, demo this anyway  

* In **GameScene.swift** *didMoveToView*, since we're going to adding several nodes, lets create a setUpNodes instance method, and call it in the executions section (Yoda remember):

        self.setupNodes()

While we're here, if the background isn't dark, add:

        self.backgroundColor = SKColor.blackColor()

because... beta

Then add implementation, has to be above the execution code in the `setupNodes()` method: 
### sks version

        func setupStarfield() {
            // local funcs
            func starfield() -> SKEmitterNode {
                let starfieldPath = NSBundle.mainBundle().pathForResource("Starfield", ofType: "sks")
                let node = NSKeyedUnarchiver.unarchiveObjectWithFile(starfieldPath!) as SKEmitterNode
                return node!
            }
            // execution
            let starfieldNode = starfield()
            starfieldNode.position = CGPointMake( CGRectGetMidX(self.frame), CGRectGetHeight(self.frame))
            starfieldNode.particleColorSequence = nil
            starfieldNode.particleColor = SKColor.redColor()
            starfieldNode.particleColorBlueRange = 255.0
            starfieldNode.particleColorGreenRange = 255.0
            
            self.addChild(starfieldNode)
        }

### coded starfield version
   Replace `func starfield()` with:

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
        }

Add `spark.png` to taste
 
We have to call our `setupStarfield()` method in the execution section of `setupNodes()`

## Add Ship

Ok, now we need a spaceship for you to fly! Let's drag all of the image and sound assets I've already prepared into the project so that we can use them. -- (pull the xcasset files vs the individual files, faster)

Now, let's add some code. Our scene needs a property to keep track of the ship node:

    	var shipNode = SKSpriteNode(imageNamed: "ship")

*Oh, yes, SKSpriteNode. This is going to be the type of node you see most in SpriteKit. (Hence the name.) A sprite node is a node that displays a bitmap sprite. They're super-flexible, and can do all kinds of hardware-accelerated wonders with that bitmap, but at its heart, it's all about putting bitmaps on screen.*
# TODO: link to resource to pull up if questions

Then we add some code to set up the ship node and add it to the scene:

        func setupShipNode() {
            // local funcs
            
            // execution...
            shipNode.position = CGPointMake( CGRectGetMidX(self.frame), 50)
            shipNode.size = CGSizeMake( CGRectGetWidth( shipNode.frame ) * 2, CGRectGetHeight( shipNode.frame ) * 2 )
            
            self.addChild(shipNode)
        }

And finally, we call the new method in the execution section of `setupNodes()`:

		setupShipNode()
		
## Move The Ship

Let's get our ship moving. Our control scheme for the game will be simple: touch on the left to move left, touch on the right to move right. We'll need a bit of abstraction between the touches and the actual movement state, so let's create an enum for the various possible movement states (at the top of the class, after the var declarations):

    	enum ShipMovement {
    		case Left, Right, None;
    	}

And, of course, a property to keep track of the ship's movement state (at the top of the class):

    	var currentShipMovement = ShipMovement.None

Now, let's add the good stuff. We're going to put our touch handling into an extension to the GameScene class. Because we want the main GameScene file to be platform-agnostic -- we *should* be able to compile it on Mac too. UITouches aren't a Mac thing, so we'll put them in an extension that we can include only for our iOS target:

* Create new swift file called **GameSceneiOSExtensions**
* Paste in the following.

----

    	import UIKit
    	
    	extension GameScene {
    		override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    			let touch : UITouch = touches.anyObject() as UITouch
    			let x = touch.locationInNode(self).x
    			switch x {
    			case 0 ..< 256:
    				currentShipMovement = ShipMovement.Left
    			case 512 ..< 768:
    				currentShipMovement = ShipMovement.Right
    			default:
    				break // TODO: Fire weapons
    			}
    	
    		}
    	
    		override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)  {
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

----

*Now, back in the GameScene.swift file, let's add code to actually move the ship.*

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
            // execution...
        	updateShipPosition()
        }
    

    

*We know our scene is 768 pixels wide, so we just split it into three 256-pixel chunks and respond accordingly. The update method gets called once for every frame in our game, so it's the right place to put our logic that has to happen repeatedly.*

Run the code and demo. Show the ship moving off the edge of the screen.

## Constraining the Ship

Looks like we've got a problem! The ship will float right off the edge of the screen, which isn't the behavior we want. Now we could check the value of X before incrementing or decrementing it like some kind of caveman, but instead let's use an SKConstraint. Constraints are what they sound like: a way to limit an SKNode's movement in some way. They can make sure a node doesn't get too far from another node, cause a node to always rotate to face another node, or simply limit a node's movement, as we'll do here.

Let's add the constraint to the shipNode right before we add the shipNode to our scene.

		let shipRange = SKRange(lowerLimit: 50.0, upperLimit: 718.0)
        let shipConstraint = SKConstraint.positionX( shipRange )
        shipNode.constraints = [shipConstraint!]

Run and demo. Problem solved!

## Firing Weapons

Alright, we've got us a spaceship, but so far it's a sitting duck. Let's make it shoot. You may remember that Galaxian, like many games of its era, only allowed one shot to be in the air at a time. So let's create a property for that shot:

    	var playerShot: SKNode?

And we'll need to replace the placeholder comment from our earlier *touchesBegan* code with a call to the method to fire the lasers:

		fireLaser()

Now we need to write the code that fires the lasers. Before we do so, however, let's talk about actions. Actions allow you to give instructions to the nodes in your sprite kit scene: move around, play a sound, animate textures, lots of stuff. There are a couple of really cool things about them. One is that they're pretty much fire-and-forget. You can tell a node to do something and it will do it; you don't have to micromanage it with every turn of the event loop. Another nice feature is that they're composable: you can combine many simple actions to make a more complicated action, either simultaneously or sequentially. In our case we want our laser to appear just above our ship, play a sound effect, move to the top of the screen, and then to vanish. Let's take a look at how we can do that. (Walk through code.)

    	func fireLaser()->Void {
            // local funcs

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
                            
                self.addChild(playerShot)
                self.playerShot = playerShot
                playerShot.runAction(compoundAction!)
            }
        }



Note that we already drug the reference sound affect in earlier. 
(Run and demo.)

## Preloading Sound Assets

You'll notice that when we fire our laser for the first time, the whole game grinds to a halt while the sound file gets loaded. Obviously, we don't want that, so let's preload our sounds as part of our setup. Add the following to `didMoveToView()`, local funcs:

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

This creates a play sound file action for each of the filenames we give it, which is enough to cache the audio data:

We'll call `preloadSounds()` in the execution... section
(demo)

## Add Score

A space shooter isn't much fun if you don't get points! Let's add a property to keep track of our score node, and another to actually track our score:

    	var scoreNode = SKLabelNode()
        var score: Int = 0
    
Here you see another new node type: label nodes! Label nodes, as you might guess if you have been programming iOS for more than about 12 minutes, are used for displaying textual content.

Let's add a node for displaying a 1UP label and our score:

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
    
Next, we call it in our `setupNodes()` execution...:

		setupScoreNode()

Last, let's add a convenience method for when we score points. We'll call this later once we start doing some alien-killin':

    	func scorePoints( points: Int ) {
        	self.score += points
        	scoreNode.text = "\(self.score)"
        }

We'll put it after `fireLaser()`



## Time for Aliens

Alright, let's get something to shoot! First off, aliens in this game animate among three different shapes, so we'll need a bitmap for each of them. 

Now, let's create an array property to keep track of our aliens, and a constant to keep track of how many we'll have:

    	let alienCount = 30
    	var aliens: [SKSpriteNode] = []

From our `setupNodes()` execution section, we'll call the method we'll create to set up the aliens:

    	setupAliens()

And finally, the code to actually do the setup:

        func setupAliens() {
            // local funcs
            
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
                alienSprite.position = positionForAlienAtIndex(j)
                self.addChild(alienSprite)
                alienSprite.runAction(animateForeverAction)
                aliens_.append( alienSprite )
            }
            self.aliens = aliens_
        }

This won't compile because we haven't defined `positionForAlienAtIndex(i:Int)`, let's do that now.  Add this above the `setupNodes()`, it will need to be exposed in the class.
    
        func positionForAlienAtIndex(i:Int) -> CGPoint {
            let cols = 10
            let x = 150 + i % cols * 47
            let y = 924 - i / cols * 43
            return CGPointMake(CGFloat(x), CGFloat(y))
        }


A new thing you'll see here is animation; we load in three frames for the alien, and animate infinitely among them. (Run and demo.) We also created a function for figuring out the position of the aliens, as we'll need it later to put aliens back in formation after they move.

## Making the Aliens Move

Ok, we have aliens! But aliens that don't go anywhere are a little too easy to shoot. Let's have them move back and forth. First, we'll need an offset variable to keep track of how far from their starting position they should be. We'll also add a variable to keep track of when the game started:

    	var alienOffset = 0
    	var gameStartTime :CFTimeInterval?

Let's update the alien position function we wrote to take advantage of our new offset variable:

        func positionForAlienAtIndex(i:Int) -> CGPoint {
            let cols = 10
            let x = 150 + i % cols * 47 + self.alienOffset
            let y = 924 - i / cols * 43
            return CGPointMake(CGFloat(x), CGFloat(y))
        }

Next, let's add code that will adjust the offset and update all the alien's positions as a nested method in the `update()` function:

    	func updateAlienPositions(currentTime: CFTimeInterval) {
        	if let gameStartTime = self.gameStartTime {
        		
        		let elapsedTime = (currentTime - gameStartTime)
        		let movementPhase = Int( elapsedTime / 2 % 4 )
        		switch movementPhase {
        		case 0:
        			self.alienOffset++
        		case 2:
        			self.alienOffset--
        		default:
        			break
        		}
        		
        		for (index, alien) in enumerate( self.aliens ) {
        				alien.position = positionForAlienAtIndex(index)
        		}
        	} else {
        		self.gameStartTime = currentTime
        	}
        }
    
The first time we get a frame update, we just tuck away the currentTime into the gameStartTime property. From then on, figure out the difference between the current time and the start time, and change our movement phase every two seconds: move right, hold position, move left, hold position. Lather, rinse, repeat.

Now, we add a call in the execution seciont of our `update()` method to the function we've just created:

		updateAlienPositions(currentTime)

(Run and demo with shooting.) But what's this? Our shots are passing right through the aliens! Let's fix that!


## Making Aliens Shootable

In a game like this, some things should trigger collisions with other things, and some things should not. For example, when an alien shoots, its shot doesn't hit other aliens (they turned off the friendly fire option when they started *their* game), but it will certainly hit you. In order to tell Sprite Kit what things should hit what other things, we'll need to first set up some categories for the various things we'll have flying around on screen.

        enum ColliderType: UInt32 {
            case PlayerShot = 0b0001
            case PlayerShip = 0b0010
            case AlienShot =  0b0100
            case AlienShip =  0b1000
        }

Add this enum to the top of the class.
	
Since we're using these as bitmasks, we need to make them binary literals (or use powers of two) and specify that their type is UInt32.

In order to provide realistic motion, Sprite Kit runs a physics engine under the covers. This allows various "physics bodies" to have forces applied to them, to be affected by gravity, and -- what we care about right now -- to bump into one another. Sprites have a slot for an associated physics body, but don't come with one by default. Let's set up each of our aliens with a physics body so that the physics engine knows about it. We'll also tell the physics engine what category of thing our alien is and what it can be affected by. (Add to setupAliens() method in local funcs)*.

        func setupPhysics(alienSprite: SKSpriteNode) {
            alienSprite.physicsBody = SKPhysicsBody(rectangleOfSize:alienSprite.size)
            alienSprite.physicsBody.categoryBitMask = ColliderType.AlienShip.toRaw()
            alienSprite.physicsBody.contactTestBitMask = ColliderType.PlayerShot.toRaw() | ColliderType.PlayerShip.toRaw()
            alienSprite.physicsBody.collisionBitMask = 0
            alienSprite.physicsBody.affectedByGravity = false
        }

call 

        setupPhysics(alienSprite)

in the execution section for loop right before `self.addChild(...)`

                				
Next, we'll need to do set up a physics body for the player's shot as well. Let's return to our `fireLaser()` method and add this:

        func setupPhysics(playerShot: SKSpriteNode) {
            playerShot.physicsBody = SKPhysicsBody(rectangleOfSize: playerShot.size)
            playerShot.physicsBody.categoryBitMask = ColliderType.PlayerShot.toRaw()
            playerShot.physicsBody.collisionBitMask = 0
            playerShot.physicsBody.affectedByGravity = false;
        }

We'll call this right before adding the node.
            			                
You'll notice that since we've already told aliens that they can be hit by the player shot, we don't have to set up a symmetrical contactTestBitMask here. Additionally, setting the collisionBitMask to 0 ensure that lasers and aliens don't shove each other around all over the screen. (That was a funny bug while I was writing this.)

Next, we need to tell the physics engine what its delegate should be for handling contacts. Add this to our the top of  execution section of our `didMoveToView()` function:

    	self.physicsWorld.contactDelegate = self

And now the compiler complains, so we add the protocol to reassure it that we know what we're doing:

    	class GameScene: SKScene, SKPhysicsContactDelegate {

And finally, we've got all the groundwork laid, and can actually kill an alien:


    	func didBeginContact(contact: SKPhysicsContact!) {
            // local funcs

            // execution...
        	if contact.bodyA.categoryBitMask == ColliderType.AlienShip.toRaw() {
        		destroyAlien( contact.bodyA.node )
        	} else if contact.bodyB.categoryBitMask == ColliderType.AlienShip.toRaw() {
        		destroyAlien( contact.bodyB.node )
        	}
        }

now we'll flesh out the `destroyAlien()` and add it into the local func section
    	
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


The first thing to note here is that SKPhysicsContacts always involve two bodies, but you don't really know which will be which. Thus, we have to check both bodyA and bodyB to see if they're aliens, and then call destroyAlien on the appropriate one.

We've already seen how to animate textures, so rather than animate an explosion with a bunch of sprites, we'll use a few new actions: rotate, scale, and fade out to make it look like the wounded alien is dropping out of formation.

Whew, that was a lot of work! But now we can finally shoot some aliens out of the sky and get our well-earned points.

(Run and demo.)

## Making an Attack Run

Aliens just moving back and forth and letting you shoot them are boring. We need to make them more aggressive! When they attack, they should no longer be locked into formation, but should instead let gravity pull them down the screen while they thrust back and forth toward the middle of the screen. Let's build the logic for that. This one will be a little long, so hang in with me.

First, we'll need a property to keep track of which alien is currently attacking:

    	var attackingAlienIndex: Int? = nil

Now we'll need to call a method to handle attacks from our *update()* method:

		handleAttacks()

Now let's add the logic:

    	func handleAttacks() {
            // local funcs

            // execution...
            if let attackingAlienIndex = self.attackingAlienIndex {
                handleAttackingAlien(attackingAlienIndex)
            } else {
                var alienIndex = Int( arc4random_uniform( UInt32( alienCount ) ) )
                startAttackRunForAlienAtIndex(alienIndex)
            }
        }

In this first method, we're just checking to see if there's an alien on an attack run. If so, we handle it; if not, we'll start a new attack run with a random alien. 

What happens when we start an attack run? Let's add a local func:

        func startAttackRunForAlienAtIndex(i:Int) {
            let alienNode = self.aliens[i]
            if (alienNode.parent != nil) {
                let isOnLeftSide = alienNode.position.x < ( self.frame.size.width / 2.0 )
                let rotationAngle = CGFloat( isOnLeftSide ? -M_PI : M_PI )
                let soundEffectAction = SKAction.playSoundFileNamed("SoundAssets/flying.wav", waitForCompletion: false)
                let rotateAction = SKAction.rotateByAngle(rotationAngle, duration: 1.0)
                let compoundAction = SKAction.group([soundEffectAction!, rotateAction!])
                alienNode.runAction( compoundAction )
                
                if let physicsBody = alienNode.physicsBody {
                    physicsBody.affectedByGravity = true
                    physicsBody.velocity = CGVectorMake(0, 100)
                }

                self.attackingAlienIndex = i
            }
        }


We check to make sure the alien is still in the scene, and if so create actions to rotate toward the center and play a sound effect. We'll then set an initial velocity on the alien's physics body to start it toward the top of the screen, but also turn on gravity for it so that it will fall down toward the bottom of the screen.

Now, for each frame we also want to have the alien move toward the center of the screen. Let's add the code for that in *local funcs*:


        func handleAttackingAlien( attackingAlienIndex: Int ) {
            // local funcs

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
            }
        }


*You can see that if the alien goes past the bottom of the screen or gets removed from the scene, we'll reset it. If it's still in flight, we simply apply a small force in the physics engine pushing it back toward the center of the screen.*

*Finally, we want our code that sets the alien position to ignore the attacking alien and let the physics engine take care of it for us. Let's add a check to `updateAlienPositions()` at the top of the for loop:*

        if (index == self.attackingAlienIndex) || (alien.physicsBody.categoryBitMask) == 0 {
            continue;
        }

*Whew, that's it! We should have aliens gracefully soaring down the screen towards us.*

(Run and demo.)

## Aliens Should Shoot!

*Ok, we're almost there! Let's give our aliens lasers to make them more formidable opponents. Any attacking alien should fire once in a while, so we'll add a bit of code to our *handleAttackingAlien()* function right after applying force toward the center:*

		if (arc4random() % 100 == 0) {
        	handleAlienShooting(attackingAlienNode)
        }

*We've already laid all the groundwork for our player ship getting hit, so our new `handleAlienShooting` routine will be fairly short and sweet - add it to the local funcs of `handleAttackingAlien()`:*

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

    
*We create a new sprite node, give it an initial position based on where the alien is, give it a velocity to start it toward the player ship, and then leave it up to Sprite Kit to do the right thing. We don't even have to retain a reference to the bullet, as the physics engine will handle the movement, and Sprite Kit will take it out of the scene hierarchy when it moves far enough away. (It's like magic!)*

*Run and demo. Show that the ship isn't yet destructible.*

## Making The Player Ship Vulnerable

*Now we see another problem. Even though our aliens are aggressive, they don't destroy our ship when they run into it. Time to fix that. As you might remember, the physics engine is responsible for determining when one thing hits another, so let's tell it what can blow up the ship. Add this to *setupShipNode() at the top (local funcs)*:*

        func setupPhysics(shipNode: SKSpriteNode) {
            shipNode.physicsBody = SKPhysicsBody(rectangleOfSize: shipNode.size)
            shipNode.physicsBody.categoryBitMask = ColliderType.PlayerShip.toRaw()
            shipNode.physicsBody.contactTestBitMask = ColliderType.AlienShip.toRaw() | ColliderType.AlienShot.toRaw()
            shipNode.physicsBody.collisionBitMask = 0
            shipNode.physicsBody.affectedByGravity = false
        }

and call it in the execution section of `setupShip()` right before `addChild()`.

*That will give the physics engine enough to go on to determine when the ship makes contact with aliens or alien shots. Let's tell it what to do when that happens. Update our *didBeginContact()* method to handle contact with the player's ship:*

        if contact.bodyA.categoryBitMask == ColliderType.PlayerShip.toRaw() {
            destroyShip()
        } else if contact.bodyB.categoryBitMask == ColliderType.PlayerShip.toRaw() {
            destroyShip()
        }

*So now, what happens when the ship is destroyed?*

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
            
            let gameOverNode = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
            gameOverNode.position = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            gameOverNode.text = "GAME OVER"
            gameOverNode.alpha = 0
            gameOverNode.runAction(SKAction.fadeInWithDuration(1))
            self.addChild(gameOverNode)
        }



*You'll see here we play a sound effect, and use another action: colorize, which causes our ship to briefly turn red, and we use a fade out action to make it disappear. We run the actions, and then set the physics body category for the ship to 0 to keep it from interacting further with other objects in the scene. Finally, we throw up a Game Over notice. (Giving your player three lives is left an an exercise to the coder.)*

Run and demo. Show Game Over.

*And that's the fastest game you've ever seen built! 
We could put some icing on the cake and build a Mac version/ SpriteKit is multiplatform, so all we'd really need to rewrite is the code that handles user input. We were clever enough to put the UIResponder code into its own extension to the GameScene earlier.  Alas, it doesn't work with the latest beta... so no icing for you.*

*There is of course more to SpriteKit than what I've shown you. If you'd like to learn more, Apple's docs are excellent, as are the WWDC talks on the topic. If you've got any questions about any of what we've done here, or just want to chat, feel free to catch me afterwards. Here's my contact info:*

    // Jim Stewart
    // Mutual Mobile
    // jim.stewart@mutualmobile.com
    // @jstewuk

*Thanks so much for coming, and enjoy the rest of the conference!*

----
