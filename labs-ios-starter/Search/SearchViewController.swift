//
//  SearchViewController.swift
//  labs-ios-starter
//
//  Created by Jarren Campos on 1/27/21.
//  Copyright © 2021 Spencer Curtis. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController {
    
    var searchResponse = Map()
    var network = NetworkClient()
    var city = ""
    var state = ""
    
    // MARK: Outlets
    @IBOutlet weak var backgroundGradient: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackgroundColor()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Background gradient
    
    /// Sets the gradient colors for the background view
    func setGradientBackgroundColor() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(named: "LightBlue")!.cgColor, UIColor(named: "MedBlue")!.cgColor ]
        gradientLayer.shouldRasterize = true
        backgroundGradient.layer.addSublayer(gradientLayer)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }
    
    func createStringURL(_ input: String) {
        var address = input
        address = address.replacingOccurrences(of: ",", with: "")
        for char in address {
            if char == " " {
                address = address.replacingOccurrences(of: " ", with: "")
                address = address.replacingOccurrences(of: city, with: "")
                state = address
                return
            } else {
                city.append(char)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap" {
            let vc = segue.destination as! MapScreenViewController
            vc.searchItem = searchResponse
            
            network.getWalkability(city: city, state: state) { (walkability, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        vc.performSegue(withIdentifier: "unwindToSearch", sender: self)
                    }
                    return
                }
                DispatchQueue.main.async {
                    vc.walkability = walkability
                    vc.setUpViews()
                    vc.counterForBlurView -= 1
                    vc.checkCounter()
                }
            }
            network.getRentals(city: city, state: state, type: "single_familiy", limit: 4) { (forRent, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        vc.performSegue(withIdentifier: "unwindToSearch", sender: self)
                    }
                    return
                }
                DispatchQueue.main.async {
                    vc.forRentObjects = forRent!
                    vc.forRentals()
                    vc.counterForBlurView -= 1
                    vc.checkCounter()
                }
            }
            network.getForSale(city: city, state: state, type: "single_familiy", limit: 4) { (forSale, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        vc.performSegue(withIdentifier: "unwindToSearch", sender: self)
                    }
                    return
                }
                DispatchQueue.main.async {
                    vc.forSaleObjects = forSale!
                    vc.forSale()
                    vc.counterForBlurView -= 1
                    vc.checkCounter()
                }
            }
        }
    }
}
    
    extension SearchViewController: UISearchBarDelegate {
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            let searchRequest = MKLocalSearch.Request()
            
            searchRequest.naturalLanguageQuery = searchBar.text
            let activeSearch = MKLocalSearch(request: searchRequest)
            
            activeSearch.start { (response, error) in
                if response == nil {
                    Alert.showBasicAlert(on: self, with: "Invalid Input", message: "Please use the format of \"City, State\"")
                } else {
                    self.searchResponse.long = (response?.boundingRegion.center.longitude)!
                    self.searchResponse.lat = (response?.boundingRegion.center.latitude)!
                    self.searchResponse.cityName = searchBar.text!
                    self.createStringURL(searchBar.text!)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.performSegue(withIdentifier: "toMap", sender: self)                    }
                }
            }
        }
    }
