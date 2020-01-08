//
//  WIndow.swift
//  TrojanX
//
//  Created by Sakurai on 2020/01/04.
//  Copyright © 2020 Sakurai. All rights reserved.
//

import Cocoa


extension NSWindowController {
    
    func shakeWindow(){
        let numberOfShakes = 3
        let durationOfShake = 0.3
        let vigourOfShake : CGFloat = 0.01
        let frame : CGRect = self.window!.frame
        let shakeAnimation :CAKeyframeAnimation  = CAKeyframeAnimation()
        
        let shakePath = CGMutablePath()
        shakePath.move( to: CGPoint(x:NSMinX(frame), y:NSMinY(frame)))
        
        for _ in 0...numberOfShakes-1 {
            shakePath.addLine(to: CGPoint(x:NSMinX(frame) - frame.size.width * vigourOfShake, y:NSMinY(frame)))
            shakePath.addLine(to: CGPoint(x:NSMinX(frame) + frame.size.width * vigourOfShake, y:NSMinY(frame)))
        }
        
        shakePath.closeSubpath()
        shakeAnimation.path = shakePath
        shakeAnimation.duration = durationOfShake
        
        self.window?.animations = ["frameOrigin":shakeAnimation]
        self.window?.animator().setFrameOrigin(self.window!.frame.origin)
    }
}
