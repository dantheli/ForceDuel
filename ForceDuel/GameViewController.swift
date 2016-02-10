//
//  GameViewController.swift
//  ForceDuel
//
//  Created by Daniel Li on 10/13/15.
//  Copyright © 2015 DLG. All rights reserved.
//

import UIKit

var bangStartTime: NSDate!

class GameViewController: UIViewController {

    @IBOutlet weak var playerTwoLabel: UILabel!
    @IBOutlet weak var playerTwoMessageLabel: UILabel!
    @IBOutlet weak var playerTwoView: PlayerView!
    
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBAction func playAgainButton(sender: UIButton) {
        setup()
    }
    
    @IBOutlet weak var playerOneMessageLabel: UILabel!
    @IBOutlet weak var playerOneView: PlayerView!
    
    @IBAction func mainMenuButton(sender: UIButton) {
        let alertController = UIAlertController(title: "Really Quit To Main Menu?", message: "Game will be lost.", preferredStyle: .Alert)
        
        let quitAction = UIAlertAction(title: "Quit", style: .Destructive) { action in
            self.performSegueWithIdentifier("returnToMainMenu", sender: self)
        }
        alertController.addAction(quitAction)
        
        let cancelAction = UIAlertAction(title: "Resume", style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    enum GameState {
        case Placing
        case Readying
        case Prebanging
        case Banging
        case GameOver
    }
    
    let greenColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
    
    var playerOneIn = false
    var playerTwoIn = false
    
    var gameState: GameState = .Placing
    
    var playerOneTime: Int!
    var playerTwoTime: Int!
    
    var playerOneBanged = false
    var playerTwoBanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerOneView.playerNumber = 1
        playerTwoView.playerNumber = 2
        
        for subview in view.subviews {
            subview.alpha = 0
        }
        
        playerTwoLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        playerTwoMessageLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        view.multipleTouchEnabled = true
        
        setup()
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "updateForce:", name: "updateForce", object: nil)
        nc.addObserver(self, selector: "appBecameActive:", name: "UIApplicationDidBecomeActiveNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: {
            for subview in self.view.subviews {
                subview.alpha = 1
            }
            }, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func appBecameActive(notification: NSNotification) {
        setup()
    }
    
    func playerEntered(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! Dictionary<String, Int>
        let player = userInfo["player"]!
        
        if gameState == .Placing {
            if player == 1 {
                playerOneIn = true
                if playerOneIn && playerTwoIn {
                    beginGameAnimations()
                } else {
                    playerOneMessageLabel.text = "Good. Waiting on other player."
                }
            }
            if player == 2 {
                playerTwoIn = true
                if playerOneIn && playerTwoIn {
                    beginGameAnimations()
                } else {
                    playerTwoMessageLabel.text = "Good. Waiting on other player."
                }
            }
        }
    }
    
    func playerExited(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! Dictionary<String, Int>
        let player = userInfo["player"]!
        
        if gameState == .Placing {
            if player == 1 {
                playerOneIn = false
                playerOneMessageLabel.textColor = UIColor.darkTextColor()
                playerOneMessageLabel.text = "Place finger on your start tile."
            }
            if player == 2 {
                playerTwoIn = false
                playerTwoMessageLabel.textColor = UIColor.darkTextColor()
                playerTwoMessageLabel.text = "Place finger on your start tile."
            }
        }
        if gameState == .Prebanging {
            
            playerOneMessageLabel.alpha = 1
            playerTwoMessageLabel.alpha = 1
            
            if player == 1 {
                playerOneMessageLabel.text = "You left."
                playerTwoMessageLabel.text = "Player 1 left."
                declareVictory(2)
            } else if player == 2 {
                playerOneMessageLabel.text = "Player 2 left."
                playerTwoMessageLabel.text = "You left."
                declareVictory(1)
            }
        }
    }
    
    func playerBanged(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! Dictionary<String, Int>
        let player = userInfo["player"]!
        
        if gameState == .Readying {
            
            playerOneMessageLabel.alpha = 1
            playerTwoMessageLabel.alpha = 1
            
            if player == 1 {
                playerOneMessageLabel.text = "You were too early."
                playerTwoMessageLabel.text = "Player 1 was too early."
                declareVictory(2)
            } else if player == 2 {
                playerOneMessageLabel.text = "Player 2 was too early."
                playerTwoMessageLabel.text = "You were too early."
                declareVictory(1)
            }
        }
        
        if gameState == .Banging {
            if playerOneBanged && playerTwoBanged {
                
                playerOneMessageLabel.alpha = 1
                playerOneMessageLabel.text = "\(playerOneTime) ms"
                playerTwoMessageLabel.alpha = 1
                playerTwoMessageLabel.text = "\(playerTwoTime) ms"
                
                if playerOneTime < playerTwoTime {
                    declareVictory(1)
                } else {
                    declareVictory(2)
                }
            }
            
            if player == 1 && !playerOneBanged {
                playerOneBanged = true
                playerOneTime = Int(round(-bangStartTime.timeIntervalSinceNow*1000))
            } else if player == 2 && !playerTwoBanged {
                playerTwoBanged = true
                playerTwoTime = Int(round(-bangStartTime.timeIntervalSinceNow*1000))
            }
        }
    }
    
    func setup() {
        self.gameLabel.font = UIFont.systemFontOfSize(17.0)
        self.gameLabel.text = ""
        
        gameState = .Placing
        
        playerOneIn = false
        playerTwoIn = false
        playerOneBanged = false
        playerTwoBanged = false
        
        playAgainButton.hidden = true
        playAgainButton.userInteractionEnabled = false
        
        playerOneMessageLabel.alpha = 1
        playerTwoMessageLabel.alpha = 1
        playerOneMessageLabel.textColor = UIColor.darkTextColor()
        playerTwoMessageLabel.textColor = UIColor.darkTextColor()
        playerOneMessageLabel.text = "Place finger on your start tile."
        playerTwoMessageLabel.text = "Place finger on your start tile."
        
        let nc = NSNotificationCenter.defaultCenter()
        
        nc.addObserver(self, selector: "playerEntered:", name:"playerEntered", object: nil)
        nc.addObserver(self, selector: "playerExited:", name:"playerExited", object: nil)
    }
    
    func beginGameAnimations() {
        
        gameState = .Readying
        
//        let nc = NSNotificationCenter.defaultCenter()
//        nc.removeObserver(self, name: "playerEntered", object: nil)
//        nc.removeObserver(self, name: "playerExited", object: nil)
        
        playerOneMessageLabel.text = "Good"
        playerOneMessageLabel.textColor = greenColor
        playerTwoMessageLabel.text = "Good"
        playerTwoMessageLabel.textColor = greenColor
        
        UIView.animateWithDuration(0.5, delay: 2.0, options: [UIViewAnimationOptions.CurveLinear], animations: {
            
            self.playerOneMessageLabel.alpha = 0
            self.playerTwoMessageLabel.alpha = 0
            
            }, completion: { finished in
                if self.gameState != .GameOver {
                    self.beginGame()
                }
        })
    }
    
    func beginGame() {
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "playerBanged:", name:"playerBanged", object: nil)
        
        gameLabel.alpha = 0
        
        displayReady()
    }
    
    func displayReady() {
        gameLabel.text = "Ready..."
        if self.gameState != .GameOver {
            UIView.animateWithDuration(0.2, delay: 0.3, options: [UIViewAnimationOptions.CurveEaseOut], animations: {
                self.gameLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                self.gameLabel.alpha = 1
                
                }, completion: { finished in
                    if self.gameState != .GameOver {
                        UIView.animateWithDuration(0.3, delay: 0.5, options: [UIViewAnimationOptions.CurveEaseIn], animations: {
                            
                            self.gameLabel.alpha = 0
                            
                            }, completion: { finished in
                                if self.gameState != .GameOver {
                                    self.displaySteady()
                                }
                        })
                    }
            })
        }
    }
    
    func displaySteady() {
        gameLabel.text = "Steady..."
        
        UIView.animateWithDuration(0.2, delay: 0.3, options: [UIViewAnimationOptions.CurveEaseOut], animations: {
            
            self.gameLabel.transform = CGAffineTransformMakeRotation(0)
            self.gameLabel.alpha = 1
            
            }, completion: { finished in
                if self.gameState != .GameOver {
                    UIView.animateWithDuration(0.3, delay: 0.5, options: [UIViewAnimationOptions.CurveEaseIn], animations: {
                        
                        self.gameLabel.alpha = 0
                        
                        }, completion: { finished in
                            if self.gameState != .GameOver {
                                self.beginBang()
                            }
                    })
                }
        })
    }
    
    func beginBang() {
        
        gameState = .Prebanging
        
        let randomDelay = Double(arc4random_uniform(7000))/1000 + 0.5
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * randomDelay))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            
            if self.gameState == .Prebanging {
                self.gameState = .Banging
                
                self.gameLabel.font = UIFont.boldSystemFontOfSize(30.0)
                self.gameLabel.text = "BANG"
                self.gameLabel.alpha = 1
                bangStartTime = NSDate()
            }
        }
    }
    
    func declareVictory(playerNumber: Int) {
        gameState = .GameOver
        
        for subview in view.subviews {
            subview.layer.removeAllAnimations()
        }
        
        gameLabel.font = UIFont.systemFontOfSize(24.0)
        gameLabel.transform = CGAffineTransformMakeRotation(0)
        gameLabel.alpha = 1
        gameLabel.text = "Player \(playerNumber) Wins."
        
        playAgainButton.hidden = false
        playAgainButton.userInteractionEnabled = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
