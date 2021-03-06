//
//  SearchControllerExtension.swift
//  MovieTime
//
//  Created by Brandon Sanchez on 2/8/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import Foundation
import UIKit

extension MoviesViewController {
    
    func initiateSearchController() {
        
        // Initializing with searchResultsController set to nil means that
        // searchController will use this view controller to display the search results
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        // If we are using this same view controller to present the results
        // dimming it out wouldn't make sense. Should probably only set
        // this to yes if using another controller to display the search results.
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        //searchView.addSubview(searchController.searchBar)
        self.navigationController?.navigationBar.topItem?.titleView = searchController.searchBar
        //self.searchView.alpha = 0
        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        
        searchController.searchBar.tintColor = color.secondaryColor?.lighten(byPercentage: 0.5)
        var textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        searchController.searchBar.setSearchColor()
        searchController.searchBar.setSerchTextcolor(color: UIColor.flatWhite)
        
        textFieldInsideSearchBar?.textColor = UIColor.flatWhite
        textFieldInsideSearchBar?.backgroundColor = color.secondaryColor
    }
    
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        guard filteredData != nil else {return}
        
        let data = filteredData
        if let searchText = searchController.searchBar.text {
            
            guard !searchText.isEmpty else {
                return
            }
            
            let titles = movies.flatMap {$0.title}
            
            let options = NSString.CompareOptions.caseInsensitive
            filteredData = movies.filter {
                return $0.title.range(of: searchController.searchBar.text!, options: options) != nil
            }
            //print(filteredData)
            moviesCollectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard movies != nil else {fatalError("onCancel: movies is nil")}
        filteredData = movies
        moviesCollectionView.reloadData()
    }
}

extension WatchLaterViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func initiateSearchController() {
        
        // Initializing with searchResultsController set to nil means that
        // searchController will use this view controller to display the search results
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        // If we are using this same view controller to present the results
        // dimming it out wouldn't make sense. Should probably only set
        // this to yes if using another controller to display the search results.
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        //searchView.addSubview(searchController.searchBar)
        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        
        searchController.searchBar.tintColor = Colors().secondaryColor?.lighten(byPercentage: 0.5)
        var textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        searchController.searchBar.setSearchColor()
        searchController.searchBar.setSerchTextcolor(color: UIColor.flatWhite)
        
        textFieldInsideSearchBar?.textColor = UIColor.flatWhite
        textFieldInsideSearchBar?.backgroundColor = Colors().secondaryColor
    }
    
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        guard watchLaterFiltered != nil else {return}
        
        let data = watchLaterFiltered
        if let searchText = searchController.searchBar.text {
            
            guard !searchText.isEmpty else {
                return
            }
            
            let titles = watchLaterAll.flatMap {$0.title}
            
            let options = NSString.CompareOptions.caseInsensitive
            watchLaterFiltered = watchLaterAll.filter {
                return $0.title.range(of: searchController.searchBar.text!, options: options) != nil
            }
            //print(filteredData)
            watchLaterCollectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard watchLaterAll != nil else {fatalError("onCancel: movies is nil")}
        watchLaterFiltered = watchLaterAll
        watchLaterCollectionView.reloadData()
    }

}

extension UISearchBar {
    public func setSerchTextcolor(color: UIColor) {
        let clrChange = subviews.flatMap { $0.subviews }
        guard let sc = (clrChange.filter { $0 is UITextField }).first as? UITextField else { return }
        sc.textColor = color
        UISearchBar.appearance().setImage(#imageLiteral(resourceName: "searchIcon"), for: UISearchBarIcon.search, state: UIControlState.normal)
    }
    
    func setSearchColor() {
        let placeholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.flatWhite, NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Search Movies", attributes: placeholderAttributes)
        let textFieldPlaceHolder = self.value(forKey: "searchField") as? UITextField
        textFieldPlaceHolder?.attributedPlaceholder = attributedPlaceholder
    }
}
