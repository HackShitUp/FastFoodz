//
//  LocalError.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit


/**
 Abstract: Localizable Error
 */
class LocalError: NSObject, LocalizedError {
    // MARK: - Class Vars
    
    /// String value of the error message
    var message: String = ""
    
    /// Override of LocalizedError object variable
    override var description: String {
        get {
            return message
        }
    }
    
    // MARK: - LocalizedError
    var errorDescription: String? {
        get {
            return description
        }
    }
    
    /// MARK: - Init
    /// - Parameter errorMessage: A String value representing the
    init(message: String) {
        self.message = message
    }
}
