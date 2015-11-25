//
//  ViewController.swift
//  PressureBang
//
//  Created by Daniel Li on 10/13/15.
//  Copyright © 2015 DLG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playView: UIView!
    @IBAction func tappedPlay(sender: UITapGestureRecognizer) {
        startPlayAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playView.alpha = 0
        playView.layer.borderWidth = 1
        playView.layer.borderColor = UIColor.darkGrayColor().CGColor
        playView.layer.cornerRadius = 10
        
        UIView.animateWithDuration(0.5, delay: 1, options: [UIViewAnimationOptions.CurveEaseInOut], animations: {
            
            self.playView.alpha = 1
            
            }, completion: { finished in
                
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startPlayAnimation() {
        UIView.animateWithDuration(0.5, delay: 0, options: [UIViewAnimationOptions.CurveEaseIn], animations: {
            
            let titleTranslateAndScale = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, -300), CGAffineTransformMakeScale(4, 4))
            self.titleLabel.transform = titleTranslateAndScale
            self.titleLabel.alpha = 0

            let playTranslateAndScale = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, 300), CGAffineTransformMakeScale(4, 4))
            self.playView.transform = playTranslateAndScale
            self.playView.alpha = 0
            
            }, completion: { finished in
                self.performSegueWithIdentifier("play", sender: self)
        })
    }
    
    func stopPlayAnimation() {
        UIView.animateWithDuration(1, delay: 0, options: [UIViewAnimationOptions.CurveEaseIn], animations: {
            
            let titleTranslateAndScale = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, 0), CGAffineTransformMakeScale(1, 1))
            self.titleLabel.transform = titleTranslateAndScale
            self.titleLabel.alpha = 1
            
            let playTranslateAndScale = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, 0), CGAffineTransformMakeScale(1, 1))
            self.playView.transform = playTranslateAndScale
            self.playView.alpha = 1
            
            }, completion: { finished in
                
        })
    }
    
    @IBAction func returnToMainMenu(segue: UIStoryboardSegue) {
        stopPlayAnimation()
    }

}

