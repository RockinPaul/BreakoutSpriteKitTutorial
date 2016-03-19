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

let BallCategory   : UInt32 = 0x1 << 0 // 00000000000000000000000000000001
let BottomCategory : UInt32 = 0x1 << 1 // 00000000000000000000000000000010
let BlockCategory  : UInt32 = 0x1 << 2 // 00000000000000000000000000000100
let PaddleCategory : UInt32 = 0x1 << 3 // 00000000000000000000000000001000

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        // 1. Create a physics body that borders the screen
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        // 2. Set the friction of that physicsBody to 0
        borderBody.friction = 0
        // 3. Set physicsBody of scene to borderBody
        self.physicsBody = borderBody
        
        physicsWorld.gravity = CGVectorMake(0, 0) // Removing gravity, 'cause we no need gravity in this game
        physicsWorld.contactDelegate = self
        
        let ball: SKSpriteNode = childNodeWithName(BallCategoryName) as! SKSpriteNode // We need to set sprite name in GameScene.sks or we get error. Tutorial issue detected.
        ball.physicsBody!.applyImpulse(CGVectorMake(10, -10))
        
        let bottomRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
        addChild(bottom)
        
        let paddle = childNodeWithName(PaddleCategoryName) as! SKSpriteNode
        
        bottom.physicsBody!.categoryBitMask = BottomCategory
        ball.physicsBody!.categoryBitMask = BallCategory
        paddle.physicsBody!.categoryBitMask = PaddleCategory
        
        ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory
        
        // 1. Store some useful constants
        let numberOfBlocks = 8
        
        let blockWidth = SKSpriteNode(imageNamed: "block.png").size.width
        let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
        
        let padding: CGFloat = 10.0
        let totalPadding = padding * CGFloat(numberOfBlocks - 1)
        
        // 2. Calculate the xOffset
        let xOffset = (CGRectGetWidth(frame) - totalBlocksWidth - totalPadding) / 2
        
        // 3. Create the blocks and add them to the scene
        for i in 0..<numberOfBlocks {
            let block = SKSpriteNode(imageNamed: "block.png")
            block.position = CGPointMake(xOffset + CGFloat(CGFloat(i) + 0.5)*blockWidth + CGFloat(i-1)*padding, CGRectGetHeight(frame) * 0.8)
            block.physicsBody = SKPhysicsBody(rectangleOfSize: block.frame.size)
            block.physicsBody!.allowsRotation = false
            block.physicsBody!.friction = 0.0
            block.physicsBody!.affectedByGravity = false
            block.name = BlockCategoryName
            block.zPosition = 1
            block.physicsBody!.categoryBitMask = BlockCategory
            addChild(block)
        }
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
    
    // This ensures that when the player takes their finger off the screen and then taps it again, the paddle does not jump around to the previous touch location.
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // 1. Create local variables for two physics bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2. Assign the two physics bodies so that the one with the lower category is always stored in firstBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 3. react to the contact between ball and bottom
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
            guard let mainView = view,
                  let gameOverScene = GameOverScene(fileNamed: "GameOverScene")
                else {
                    return
                }
            gameOverScene.gameWon = false
            gameOverScene.scaleMode = .AspectFill
            mainView.presentScene(gameOverScene)
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
            secondBody.node!.removeFromParent()
            //TODO: check if the game has been won
        }
        
        if isGameWon() {
            guard let mainView = view,
                  let gameOverScene = GameOverScene(fileNamed: "GameOverScene")
                else {
                    return
            }
            gameOverScene.gameWon = true
            mainView.presentScene(gameOverScene)
        }
    }
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        self.enumerateChildNodesWithName(BlockCategoryName) {
            node, stop in
            numberOfBricks = numberOfBricks + 1
        }
        return numberOfBricks == 0
    }
    
    override func update(currentTime: NSTimeInterval) {
        let ball = self.childNodeWithName(BallCategoryName) as! SKSpriteNode
        
        let maxSpeed: CGFloat = 1000.0
        let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
        
        if speed > maxSpeed {
            ball.physicsBody!.linearDamping = 0.4
        }
        else {
            ball.physicsBody!.linearDamping = 0.0
        }
    }

}