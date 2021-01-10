//
//  MainViewController.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import CoreLocation
import NavigationTransitionController


// MARK: - MainDataDelegate
@objc protocol MainDataDelegate {
    /// Called whenever the MainData updated its CLLocation
    /// - Parameter location: An optional CLLocation
    @objc optional func updatedLocation(_ location: CLLocation?)
}


/// Struct used to make it easier to access data anywhere
struct MainData {
    // MARK: - CLLocation
    static var currentLocation: CLLocation? {
        didSet {
            // MARK: - MainDataDelegate
            self.delegate?.updatedLocation?(self.currentLocation)
        }
    }
    
    // MARK: - Place
    static var nearbyPlaces: [Place] = []
    
    // MARK: - MainDataDelegate
    static var delegate: MainDataDelegate?
}
