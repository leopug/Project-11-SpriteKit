//
//  GameScene.swift
//  Project11SpriteKitGame
//
//  Created by Ana Caroline de Souza on 21/01/20.
//  Copyright © 2020 Ana e Leo Corp. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel : SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editLabel: SKLabelNode!
    var editingMode = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var ballsCount = 5 {
        didSet {
            if ballsCount > 0 {
                ballsCountLabel.text = "balls: \(ballsCount)"
            } else {
                ballsCountLabel.text = "Game Finished - No Balls left"
            }
        }
    }
    var ballsCountLabel : SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        ballsCountLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsCountLabel.text = "Balls: 5"
        ballsCountLabel.position = CGPoint(x: 480, y: 700)
        addChild(ballsCountLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: size)
                box.physicsBody?.isDynamic = false
                box.name = "obstacle"
                addChild(box)
            } else {
                if ballsCount > 0 {
                    let ball = SKSpriteNode(imageNamed: getRandomBall())
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2.0)
                    ball.physicsBody?.restitution = 0.4
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                    ball.position = CGPoint(x: location.x, y: 765)
                    ball.name = "ball"
                    ballsCount-=1
                    addChild(ball)
                }
            }

        }
        
    }
 
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2.0)
        bouncer.physicsBody?.isDynamic = false // fix in place forever
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 1)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
        
    }
    
    func colision(between ball: SKNode, object: SKNode){
        if object.name == "good" {
            destroy(ball: ball)
            score+=1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score-=1
        } else if object.name == "obstacle" {
            object.removeFromParent()
        }
    }
    
    func destroy(ball: SKNode){
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        
        if contact.bodyA.node?.name == "ball" {
            colision(between: nodeA, object: nodeB)
        } else if contact.bodyB.node?.name == "ball" {
            colision(between: nodeB, object: nodeA)
        }
        
    }
    
     func getRandomBall()->String {
        let ball = Int.random(in: 0...5)
        switch ball {
        case 0:
            return "ballRed"
        case 1:
            return "ballCyan"
        case 2:
            return "ballGreen"
        case 3:
            return "ballGrey"
        case 4:
            return "ballPurple"
        case 5:
            return "ballYellow"
        default:
            return "ballGray"
        }
    }
}
