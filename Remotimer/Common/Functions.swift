//
//  Functions.swift
//  Remotimer
//
//  Created by iamchiwon on 2018. 7. 5..
//  Copyright © 2018년 ncode. All rights reserved.
//

import Foundation
import UIKit

func timeToMinute(_ time: TimeInterval) -> Int {
    let minute = Int(time / 60)
    return minute
}

func timeToSecond(_ time: TimeInterval) -> Int {
    let minute = timeToMinute(time)
    let second = Int(time - Double(minute) * 60.0)
    return second
}

func timeToString(_ time: TimeInterval) -> String {
    let minute = timeToMinute(time)
    let second = timeToSecond(time)
    return String(format: "%02d:%02d", minute, second)
}

func sign(_ f: CGFloat) -> Int {
    if f == 0 { return 0 }
    if f < 0 { return -1 }
    return 1
}

func bypass<T>(_ t: T) -> T { return t }
