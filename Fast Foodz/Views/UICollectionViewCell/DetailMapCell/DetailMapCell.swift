//
//  DetailMapCell.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/10/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import MapKit



/**
 Abstract: UICollectionViewCell
 */
class DetailMapCell: UICollectionViewCell {
    
    // MARK: - Class Vars
    
    /// CGSize of this cell class
    static var size: CGSize {
        get {
            return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - DetailHeaderView.size.height)
        }
    }
    
    // MARK: - Place
    var place: Place!

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    /// Update the contents of this view class
    /// - Parameter place: A Place object
    /// - Parameter routes: An array of MKRoute objects
    func updateContent(place: Place, routes: [MKRoute] = []) {
        // MARK: - Place
        self.place = place
        
        if let location = place.location {
            // Get the center
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            // MARK: - MKCoordinateRegion
            let region = MKCoordinateRegion(center: center, latitudinalMeters: CLLocationDistance(1_000), longitudinalMeters: CLLocationDistance(1_000))
            // MARK: - MKPointAnnotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = place.location?.coordinate ?? location.coordinate

            // Execute in the main thread
            DispatchQueue.main.async {
                // MARK: - MKMapView
                self.mapView.setRegion(region, animated: false)
                self.mapView.addAnnotation(annotation)
            }
            
            // Determine if we've already received the routes
            switch routes.isEmpty {
            case true:
                // MARK: - MKDirections.Request
                let request = MKDirections.Request()
                request.source = MKMapItem.forCurrentLocation()
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), addressDictionary: nil))
                request.requestsAlternateRoutes = false
                request.transportType = .automobile
                
                // MARK: - MKDirections
                let directions = MKDirections(request: request)
                directions.calculate { (response: MKDirections.Response?, error: Error?) in
                    if error == nil {
                        guard let routes = response?.routes else {
                            return
                        }
                        
                        // Draw the directions
                        for route in routes {
                            DispatchQueue.main.async {
                                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: false)
                            }
                        }
                    } else {
                        print("\(#file)/\(#line) - Error: \(error?.localizedDescription as Any)")
                    }
                }
            case false:
                // Draw the directions
                for route in routes {
                    DispatchQueue.main.async {
                        self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: false)
                    }
                }
            }
        }
    }
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // MARK: - MKMapView
        mapView.showsUserLocation = true
        mapView.layer.cornerRadius = 16.0
        mapView.clipsToBounds = true
        mapView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}



// MARK: - MKMapViewDelegate
extension DetailMapCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Identifier
        let identifier = "Pin"

        // Don't show the annotation for the user's location
        if annotation is MKUserLocation {
            return nil
        }

        // MARK: - MKAnnotationView
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "pin")
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        polylineRenderer.strokeColor = UIColor.bluCepheus
        polylineRenderer.lineWidth = 4.0
        polylineRenderer.lineCap = .round
        return polylineRenderer
    }
}
