//
//  AppDelegate.swift
//  SKMacSpeedRun
//
//  Created by Jim on 8/24/14.
//  Copyright (c) 2014 mutualmobile.com. All rights reserved.
//


import Cocoa
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        /* Pick a size for the scene */
//        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
        if let scene = scene() {
            self.skView!.presentScene(scene)
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            self.skView!.ignoresSiblingOrder = true
            
            self.skView!.showsFPS = true
            self.skView!.showsNodeCount = true

            let skViewSize = self.skView.bounds.size
            window.minSize = skViewSize
            window.maxSize = skViewSize
        }
    }

    func scene()->GameScene? {
        let scene = GameScene(size: CGSizeMake(768, 1024))
        scene.physicsWorld.gravity = CGVectorMake(0.0, -1)
        scene.scaleMode = .AspectFill
        return scene
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true;
    }
}
