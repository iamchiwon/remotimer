//
//  NavigationViewController.swift
//  Remotimer
//
//  Created by iamchiwon on 2018. 7. 20..
//  Copyright © 2018년 ncode. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }

}
