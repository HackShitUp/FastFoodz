//
//  MainNavigationController.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    /// MARK: - Init
    convenience init() {
        self.init(rootViewController: MainViewController())
    }
}
