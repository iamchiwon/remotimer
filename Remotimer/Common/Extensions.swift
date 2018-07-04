//
//  Extensions.swift
//  Remotimer
//
//  Created by iamchiwon on 2018. 7. 5..
//  Copyright © 2018년 ncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {

    public var isShown: Binder<Bool> {
        return Binder(self.base) { view, visible in
            view.isHidden = !visible
        }
    }

    public var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            view.backgroundColor = color
        }
    }

    public func tapped(count: Int = 1) -> Driver<UITapGestureRecognizer> {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = count

        base.isUserInteractionEnabled = true
        base.addGestureRecognizer(tapGestureRecognizer)

        return tapGestureRecognizer.rx.event.asDriver()
    }
}

extension String {
    var isNotEmpty: Bool { return !self.isEmpty }
}

extension Array {
    var isNotEmpty: Bool { return self.count > 0 }
}
