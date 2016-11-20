//
//  ViewController.swift
//  TableView4
//
//  Created by Sanchit Garg on 07/10/16.
//  Copyright © 2016 Sanchit Garg. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIViewControllerPreviewingDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var species:Array<StarWarsSpecies>?
    var speciesWrapper:SpeciesWrapper? // holds the last wrapper that we've loaded
    var isLoadingSpecies = false
    

    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if( traitCollection.forceTouchCapability == .available){
            
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: tableview)
            
        }
        //Dynamic quick action
//        let shortcut = UIApplicationShortcutItem(type: "com.tutsplus.Introducing-3D-Touch.add-item", localizedTitle: "Add Item", localizedSubtitle: "Dynamic Action", icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
//        UIApplication.shared.shortcutItems = [shortcut]
        
        self.loadFirstSpecies()
    }
    
    func loadFirstSpecies() {
        isLoadingSpecies = true
        StarWarsSpecies.getSpecies { wrapper, error in
            guard error == nil else {
                // TODO: improved error handling
                self.isLoadingSpecies = false
                let alert = UIAlertController(title: "Error",
                                              message: "Could not load first species \(error?.localizedDescription)",
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.addSpeciesFromWrapper(wrapper: wrapper)
            self.isLoadingSpecies = false
            self.tableview?.reloadData()
        }
        
    }
    
    func loadMoreSpecies()
    {
        self.isLoadingSpecies = true
        guard let species = self.species, let wrapper = self.speciesWrapper , species.count < wrapper.count! else {
            // no more species to fetch
            return
        }
        // there are more species out there!
        StarWarsSpecies.getMoreSpecies(wrapper: self.speciesWrapper, completionHandler: { (moreWrapper, error) in
            guard error == nil else {
                // TODO: improved error handling
                self.isLoadingSpecies = false
                let alert = UIAlertController(title: "Error",
                                              message: "Could not load more species \(error?.localizedDescription)",
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
//            print("got more!")
            self.addSpeciesFromWrapper(wrapper: moreWrapper)
            self.isLoadingSpecies = false
            self.tableview?.reloadData()
        })
    }
    
    func addSpeciesFromWrapper(wrapper: SpeciesWrapper?) {
        self.speciesWrapper = wrapper
        if self.species == nil {
            self.species = self.speciesWrapper?.species
        } else if let newSpecies = self.speciesWrapper?.species, let currentSpecies = self.species {
            self.species = currentSpecies + newSpecies
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Table data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let species = self.species else {
            return 0
        }
        return species.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let numberOfSpecies = self.species?.count , numberOfSpecies >= indexPath.row {
            if let species = self.species?[indexPath.row] {
                cell.textLabel?.text = species.name
                cell.detailTextLabel?.text = species.classification
            }
            
            // See if we need to load more species
            let rowsToLoadFromBottom = 5;
            if !self.isLoadingSpecies && indexPath.row >= (numberOfSpecies - rowsToLoadFromBottom) {
                if let totalSpeciesCount = self.speciesWrapper?.count , totalSpeciesCount - numberOfSpecies > 0 {
                    self.loadMoreSpecies()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("details")
        super.prepare(for: segue, sender: sender)
        if let speciesDetailVC = segue.destination as? SpeciesDetailViewController {
            if let indexPath = self.tableview?.indexPathForSelectedRow {
                speciesDetailVC.species = self.species?[indexPath.row]
            }
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = self.tableview?.indexPathForRow(at: location) else { return nil }
        
        guard let cell = self.tableview?.cellForRow(at: indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "SpeciesDetailViewController") as? SpeciesDetailViewController else { return nil }
        
        detailVC.species = self.species?[indexPath.row]
        
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
        
    }
    
}

