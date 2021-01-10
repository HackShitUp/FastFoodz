//
//  Place.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import CoreLocation


/**
 Abstract: Class representing a place returned by Yelp
 */
class Place: NSObject {

    // MARK: - Class Vars
    
    /// Initialized String value representing the place's name
    var name: String? = ""
    
    /// Initialized URL value representing the place's image
    var imageURL: URL?
    
    /// Initialized CLLocation value representing the place's coordinates
    var location: CLLocation?
    
    /// Initialized String value representing the place's physical address represented as a string
    var address: String?
    
    /// Initialized String value representing the phone number of the place
    var phone: String?
    
    /// Initialized URL value representing the URL of the place for info
    var url: URL?
    
    /// Initialized String value representing the category of the place
    var category: String?
    
    /// String value representing the pricing range
    var price: String?
    
    /// Returns a UIImage based on the category
    var categoryImage: UIImage? {
        get {
            switch category {
            case let name where name == "pizza": return UIImage(named: "pizza")
            case let name where name == "mexican": return UIImage(named: "mexican")
            case let name where name == "chinese": return UIImage(named: "chinese")
            case let name where name == "burgers": return UIImage(named: "burgers")
            default: return UIImage(named: "logo")
            }
        }
    }
    
    /// MARK: - Init
    /// - Parameter json: An NSDictionary representing a JSON object
    convenience init(json: NSDictionary) {
        self.init()
        
        if let name = json["name"] as? String {
            self.name = name
        }
        
        if let imageURLPath = json["image_url"] as? String, let imageURL = URL(string: imageURLPath) {
            self.imageURL = imageURL
        }
        
        if let coordinates = json["coordinates"] as? NSDictionary,
           let latitude = coordinates["latitude"] as? Double,
           let longitude = coordinates["longitude"] as? Double {
            self.location = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        }
        
        if let location = json["location"] as? NSDictionary,
           let displayAddress = location["display_address"] as? [String], !displayAddress.isEmpty {
            self.address = displayAddress.joined(separator: " ")
        }
        
        if let price = json["price"] as? String {
            self.price = price
        }
        
        if let phone = json["phone"] as? String {
            self.phone = phone
        }
        
        if let urlPath = json["url"] as? String, let url = URL(string: urlPath) {
            self.url = url
        }
        
        if let categories = json["categories"] as? [NSDictionary],
           let firstRelevantCategory = categories.compactMap({ (dictionary: NSDictionary) -> String in
               return dictionary["alias"] as? String ?? ""
           }).filter(["pizza", "mexican", "chinese", "burgers"].contains).first {
            self.category = firstRelevantCategory
        }
    }
}
