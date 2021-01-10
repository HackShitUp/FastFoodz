//
//  YelpFactory.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import CoreLocation



/**
 Abstract: Factory class to load restuarant data as Place objects
 */
class YelpFactory {
    
    /// Gets restuarants using Yelp's API related to a given term value near the given location and its radius using Yelp's API
    /// - Parameters:
    ///   - coordinates: A CLLocationCordinate2D object representing the location to query for
    ///   - limit: A UInt value representing the maximum number of places to return in this query
    ///   - radius: A UInt value representing the radius filter for a given location
    ///   - terms: A String array used to query for specific place categories
    ///   - completion: Returns an optional Error object and an optional array of Place objects if the requests fail or succeed respectively
    static func getPlaces(coordinates: CLLocationCoordinate2D, limit: UInt = 20, radius: UInt = 1_000, terms: [String] = ["pizza", "mexican", "chinese", "burgers"], completion: ((_ error: Error?, _ places: [Place]?) -> ())? = nil) {
        // MARK: - URL
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?latitude=\(coordinates.latitude)&longitude=\(coordinates.longitude)&radius=\(radius)&categories=\(terms.joined(separator: ","))") else {
            // Pass the values in the completion handler
            completion?(LocalError(message: "\(#file)/\(#line) - Error formulating URL for request"), nil)
            return
        }
        
        // MARK: - URLRequest
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "GET"

        // MARK: - URLSession
        URLSession.shared.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                do {
                    // MARK: - JSON
                    guard let data = data,
                          let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
                          let businesses = json["businesses"] as? [NSDictionary] else {
                        // Pass the values in the completion
                        completion?(LocalError(message: "\(#file)/\(#line) - Error parsing JSON"), nil)
                        return
                    }
                    
//                    print("JSON: \(businesses)")
                    
                    // MARK: - Place
                    // Map the JSON object to Place objects
                    let places = businesses.map { (business: NSDictionary) -> Place in
                        // MARK: - Place
                        let place = Place(json: business)
                        return place
                    }
                    
                    // Pass the values in the completion
                    completion?(nil, places)
                    
                } catch let error {
                    // Pass the values in the completion
                    completion?(LocalError(message: "\(#file)/\(#line) - Error: \(error.localizedDescription)"), nil)
                }
            } else {
                // Pass the values in the completion
                completion?(LocalError(message: "\(#file)/\(#line) - Error: \(error?.localizedDescription as Any)"), nil)
            }
        }.resume()

    }
}
