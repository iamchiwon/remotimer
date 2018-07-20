//
//  UIWheelGestureRecognizer.swift
//  Remotimer
//
//  Created by iamchiwon on 2018. 7. 20..
//  Copyright © 2018년 ncode. All rights reserved.
//
//  Refered from https://github.com/iamchiwon/UIWheelGestureRecognizer
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class UIWheelGestureRecognizer: UIGestureRecognizer {

    typealias UIWheelGestureRecognizerDelegate = (_ recognizer: UIWheelGestureRecognizer) -> (Void)

    enum Direction: String {
        case None = "None"
        case Right = "Right"
        case Left = "Left"
    }

    var lastDirection: Direction = .None
    var direction: Direction = .None
    var angle: Double = 0
    var minDistance: Double = 0
    var maxDistance: Double = 100



    private var eventHandler: UIWheelGestureRecognizerDelegate? = nil

    func setHandler(handler: UIWheelGestureRecognizerDelegate?) {
        eventHandler = handler
    }

    func reportEvent() {
        if let delegate = eventHandler {
            delegate(self)
        }
    }

    override func reset() {
        super.reset()
        state = .possible
        lastDirection = .None
        direction = .None
        angle = 0
        reportEvent()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        guard checkValidate(touches: touches) else {
            state = .failed
            return
        }

        state = .began
        lastAngle = calucateAngle(touch: touches.first!)
        reportEvent()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if state == .failed { return }
        guard checkValidate(touches: touches) else { return }
        state = .changed
        trackingAngle(currentAngle: calucateAngle(touch: touches.first!))
        reportEvent()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        if state == .failed { return }
        state = .ended
        reportEvent()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        if state == .failed { return }
        state = .cancelled
        reportEvent()
    }

    private func checkValidate(touches: Set<UITouch>) -> Bool {
        if view == nil {
            return false
        }

        if touches.count != 1 {
            return false
        }

        let point = touches.first!.location(in: view!)
        let distance = calculateDistance(point: point)

        if distance < minDistance || distance > maxDistance {
            return false
        }

        return true
    }

    private func calculateDistance(point: CGPoint) -> Double {
        let size = view!.frame.size
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let dx = center.x - point.x
        let dy = center.y - point.y
        let distance = Double(sqrt(dx * dx + dy * dy))
        return distance
    }

    private func calucateAngle(touch: UITouch) -> Double {
        let point = touch.location(in: view)
        let size = view!.frame.size
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let dx = center.x - point.x
        let dy = center.y - point.y
        let angle = Double(atan2(dx, dy)).radiansToDegrees
        return angle
    }

    private var lastAngle: Double = 0

    func trackingAngle(currentAngle: Double) {
        let diff = abs(lastAngle - currentAngle)
        
        lastDirection = direction

        if lastAngle > 90 && currentAngle < -90 {
            //왼쪽으로 돌리다가 180도에서 -180도로 변경되는 부분
            direction = .Left
            //angle 계산 skip
        } else if lastAngle < -90 && currentAngle > 90 {
            //오른쪽으로 돌리다가 -180에서 180도로 변경되는 부분
            direction = .Right
            //angle 계산 skip
        } else if lastAngle > currentAngle {
            direction = .Right
            angle += diff
        } else {
            direction = .Left
            angle -= diff
        }

        lastAngle = currentAngle
    }
}

extension Double {
    var degreesToRadians: Double {
        return self * .pi / 180
    }
    var radiansToDegrees: Double {
        return self * 180 / .pi
    }
}

