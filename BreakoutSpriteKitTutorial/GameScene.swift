//
//  GameScene.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Pavel on 18.03.16.
//  Copyright (c) 2016 Pavel Zarudnev. All rights reserved.
//

import SpriteKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let BlockNodeCategoryName = "blockNode"

var isFingerOnPaddle = false

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        // 1. Create a physics body that borders the screen
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        // 2. Set the friction of that physicsBody to 0
        borderBody.friction = 0
        // 3. Set physicsBody of scene to borderBody
        self.physicsBody = borderBody
        
        physicsWorld.gravity = CGVectorMake(0, 0) // Removing gravity, 'cause we no need gravity in this game
        
        let ball: SKSpriteNode = childNodeWithName(BallCategoryName) as! SKSpriteNode // We need to set sprite name in GameScene.sks or we get error. Tutorial issue detected.
        ball.physicsBody!.applyImpulse(CGVectorMake(10, -10))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch?.locationInNode(self)
        
        guard let unwrappedTouchLocation = touchLocation,
              let body = physicsWorld.bodyAtPoint(unwrappedTouchLocation)
            else {
              return
            }
        if body.node!.name == PaddleCategoryName {
            print("Began touch on paddle")
            isFingerOnPaddle = true
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 1. Check whether user touched the paddle
        if isFingerOnPaddle {
            // 2. Get touch location
            let touch = touches.first
            
            guard let touchLocation = touch?.locationInNode(self),
                  let previousLocation = touch?.previousLocationInNode(self)
                else {
                    return
            }
            // 3. Get node for paddle
            let paddle = childNodeWithName(PaddleCategoryName) as! SKSpriteNode
            // 4. Calculate new position along x for paddle
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            // 5. Limit x so that paddle won't leave screen to left or right
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            // 6. Update paddle position
            paddle.position = CGPointMake(paddleX, paddle.position.y)
        }
    }
}