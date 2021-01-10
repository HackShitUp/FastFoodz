//
//  MapListViewController.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import CoreLocation
import DZNEmptyDataSet
import NavigationTransitionController
import SkeletonView



class MapListViewController: UIViewController {
    
    // MARK: - Class Vars
    
    // MARK: - Refresher
    let refresher = Refresher()
    
    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - View Controller Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Refresher
        refresher.addTarget(self, action: #selector(loadData(_:)), for: .valueChanged)
        collectionView.addSubview(refresher)

        // MARK: - DynamicVerticalLayout
        let layout = DynamicVerticalLayout()
        
        // MARK: - UICollectionView
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.register(UINib(nibName: "MapListCell", bundle: nil), forCellWithReuseIdentifier: "MapListCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
//        // MARK: - DZNEmptyDataSet
//        collectionView.emptyDataSetSource = self
//        collectionView.emptyDataSetDelegate = self
        
        // Load the data
        loadData(self)
    }
    
    /// Load the contents of this class by binding the places data to the interface
    /// - Parameter sender: Any object that calls this method
    @objc func loadData(_ sender: Any) {
        // Determine if we haven't fetched places yet
        switch MainData.nearbyPlaces.isEmpty {
        case true:
            // MARK: - CLLocationManager
            switch CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            case true:
                // Ensure that we have the current user's location
                guard let locationCoordinate = MainData.currentLocation?.coordinate else {
                    // MARK: - UIAlertController
                    let alertController = UIAlertController.init(title: "Something Went Wrong", message: "We couldn't get your location.", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                // MARK: - Refresher
                self.refresher.animate(true)
                
                //  MARK: - YelpFactory
                YelpFactory.getPlaces(coordinates: locationCoordinate) { (error: Error?, places: [Place]?) in
                    if error == nil {
                        // MARK: - Refresher
                        self.refresher.animate(false)
                        
                        // MARK: - MainData
                        MainData.nearbyPlaces = places ?? []

                        // Reload the collection view data
                        DispatchQueue.main.async {
                            self.collectionView.reloadEmptyDataSet()
                            self.collectionView.reloadData()
                        }
                    } else {
                        print("\(#file)/\(#line) - Error: \(error?.localizedDescription as Any)")
                    }
                }
                
            case false:
                // MARK: - UIAlertController
                let alertController = UIAlertController.init(title: "Please Enable Location", message: "You've denied access to your location for Fast Foodz. Change this in the app's settings to discover great fast food places.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action: UIAlertAction) in
                    if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                        // Open the settings
                        UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
                    }
                }))
                present(alertController, animated: true, completion: nil)
            }
            
        case false:
            // MARK: - Refresher
            self.refresher.animate(true)
            
            // Reload the collection view data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // MARK: - Refresher
                self.refresher.animate(false)
                // MARK: - UICollectionView
                self.collectionView.reloadEmptyDataSet()
                self.collectionView.reloadData()
            }
        }
    }
}



// MARK: - UICollectionViewDataSource/UICollectionViewDelegate/UICollectionViewDelegateFlowLayout
extension MapListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MainData.nearbyPlaces.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return MainData.nearbyPlaces.isEmpty ? .zero : collectionView.cachedCellSizes[indexPath] ?? MapListCell.size
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // MARK: - Place
        let places = MainData.nearbyPlaces
        
        // MARK: - MapListCell
        let mapListCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapListCell", for: indexPath) as! MapListCell
        mapListCell.updateContent(place: places[indexPath.item])
        return mapListCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - Place
        let places = MainData.nearbyPlaces
        // MARK: - DetailViewController
        let detailVC = DetailViewController(place: places[indexPath.item])
        // MARK: - NavigationTransitionController
        let navigationTransitionController = NavigationTransitionController(rootViewController: detailVC)
        navigationTransitionController.presentNavigation(self)
    }
}
