//
//  GameOverScene.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Pavel on 18.03.16.
//  Copyright © 2016 Pavel Zarudnev. All rights reserved.
//

import SpriteKit

let GameOverLabelCategoryName = "gameOverLabel"

class GameOverScene: SKScene {
    
    var gameWon : Bool = false {
        // 1. The didSet observer attached to the gameWon property is a Swift particularity called Property Observer. With that you can observe changes in the value of a property and react accordingly. There are two property observers: willSet is called just before a property value change occurs, whereas didSet occurs just after.
        didSet {
            let gameOverLabel = childNodeWithName(GameOverLabelCategoryName) as! SKLabelNode
            gameOverLabel.text = gameWon ? "Game Won" : "Game Over"
        }
    }
    
    // Note: Property Observers have a parameter that allows you to check the new value of the property (in willSet) or its old value (in didSet) allowing value changes comparison right when it occurs. These parameters have default names if you do not provide your own, respectively newValue and oldValue.
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let view = view {
            // 2. When the user taps anywhere in the GameOver scene, this code just presents the Game scene again. Note how it instantiates a new GameScene object by unarchiving the Sprite Kit Scene you built with the Visual Editor, referencing it by its name without the .sks extension.
            let gameScene = GameScene(fileNamed: "GameScene")
            gameScene?.scaleMode = .AspectFill
            view.presentScene(gameScene)
        }
    }
}
