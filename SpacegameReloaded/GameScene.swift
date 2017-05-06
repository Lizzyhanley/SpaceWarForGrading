//
//  GameScene.swift
//  SpacegameReloaded
//
//  Created by Training on 01/10/2016.
//  Copyright © 2016 Training. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    var drag = false
   
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
   
    var gameTimer:Timer!
    
    var possibleAliens = ["alien", "alien2", "alien3"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    var livesArray:[SKSpriteNode]!
    
    var xAcceleration:CGFloat = 0
    
    
    override func didMove(to view: SKView) {
        
        addLives()
    
        starfield = SKEmitterNode(fileNamed: "Starfield")
        //starfield.position = CGPoint(x: 1472, y: 700)
        starfield.position = CGPoint(x: 1000, y: 600)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "plane")
        
       
        player.position = CGPoint(x: 40 , y: self.frame.size.height / 2)
        
        player.size.width = 50
        player.size.height = 50
        
        self.addChild(player)
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        
        scoreLabel.position = CGPoint(x: (self.frame.size.width) / 2, y: self.frame.size.height - 50)
        scoreLabel.fontName = "Avenir Next"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
    
            
            
        self.addChild(scoreLabel)
        
        var timeInterval = 1.5
        
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.9
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)


      
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        for touch in (touches as! Set<UITouch>){
            let location = touch.location(in: self)
            
            if self.atPoint(location) == self.player {
                
                drag = true  //make this true so it will only move when you touch it.
                
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if drag {
            
            let touch = touches.first!
                
                let touchLoc = touch.location(in: self)
                let prevTouchLoc = touch.previousLocation(in: self)
                
                var newYPos = player.position.y + (touchLoc.y - prevTouchLoc.y)
                var newXPos = player.position.x + (touchLoc.x - prevTouchLoc.x)
                
                newYPos = max(newYPos, player.size.height / 2)
                newYPos = min(newYPos, self.size.height - player.size.height / 2)
                
                newXPos = max(newXPos, player.size.width / 2)
                newXPos = min(newXPos, self.size.width - player.size.width / 2)
                
            player.position = CGPoint(x: newXPos, y: newYPos)  //set new X and Y for your sprite.
            }
        }
    

    
    func addLives (){
        
        livesArray = [SKSpriteNode]()
        
        for live in 1 ... 10 {
            let liveNode = SKSpriteNode(imageNamed: "plane")
            liveNode.name = "live\(live)"
            liveNode.position = CGPoint(x: CGFloat(30 * live), y: self.frame.size.height - 60)
            liveNode.size = CGSize(width: 30, height: 30)
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
    }

    
    
//    This will allow you to move you entire soace background, which is trippy, but not what we wanna do
//    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
//        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
//            
//            let translation = gestureRecognizer.translation(in: self.view)
//            // note: 'view' is optional and need to be unwrapped
//            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
//            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
//        }
//    }
//  
    
    
    func addAlien () {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        

        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(self.frame.size.height) - Int(alien.size.height))
        
        
        let position = CGFloat(randomAlienPosition.nextInt())
        
        
        alien.position = CGPoint(x: self.frame.size.width + alien.size.width, y: position)
        
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        
         actionArray.append(SKAction.move(to: CGPoint(x: -alien.size.width , y: position), duration: animationDuration))
        
        actionArray.append(SKAction.run {
            self.run(SKAction.playSoundFileNamed("loose.mp3", waitForCompletion: false))

            
            if self.livesArray.count > 0 {
                
                let liveNode = self.livesArray.first
                liveNode!.removeFromParent()
                self.livesArray.removeFirst()
                
                
//                if self.livesArray.count == 0 {
//                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
//                    let welcomeScene = WelcomeScene(size: self.size)
//                    self.view!.presentScene(welcomeScene, transition: transition)
//                }
                if self.livesArray.count == 0{
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    gameOver.score = self.score
                    self.view?.presentScene(gameOver, transition: transition)
                }

                
            }
            
        })
        
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
        
    }
    

    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
    
    
    func fireTorpedo() {
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.x += 5
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        let animationDuration:TimeInterval = 0.3
        
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: self.frame.size.width + 10, y: player.position.y), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        torpedoNode.run(SKAction.sequence(actionArray))
        
        
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
           torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }     
        
    }
    
    
    func torpedoDidCollideWithAlien (torpedoNode:SKSpriteNode, alienNode:SKSpriteNode) {
    
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        
        self.run(SKAction.wait(forDuration: 2)) { 
            explosion.removeFromParent()
        }
        
        score += 5
        
        
    }
    //what is this doing??
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
    }
    
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
