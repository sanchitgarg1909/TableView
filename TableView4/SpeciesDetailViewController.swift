//
//  SpeciesDetailViewController.swift
//  TableView4
//
//  Created by Sanchit Garg on 08/10/16.
//  Copyright © 2016 Sanchit Garg. All rights reserved.
//

import UIKit

class SpeciesDetailViewController: UIViewController {

    @IBOutlet var descriptionLabel: UILabel!
    var species:StarWarsSpecies?
    
    override var previewActionItems: [UIPreviewActionItem] {
        let action1 = UIPreviewAction(title: "Action One",
                                      style: .destructive,
                                      handler: { previewAction, viewController in
                                        print("Action One Selected")
        })
        
        let action2 = UIPreviewAction(title: "Action Two",
                                      style: .selected,
                                      handler: { previewAction, viewController in
                                        
                                        print("Action Two Selected")
        })
        
        let groupAction1 = UIPreviewAction(title: "Group Action One",
                                           style: .default,
                                           handler: { previewAction, viewController in
                                            print("Group Action One Selected")
        })
        
        let groupAction2 = UIPreviewAction(title: "Group Action Two",
                                           style: .default,
                                           handler: { previewAction, viewController in
                                            print("Group Action Two Selected")
        })
        
        let groupActions = UIPreviewActionGroup(title: "My Action Group...",
                                                style: .default,
                                                actions: [groupAction1, groupAction2])
        
        return [action1, action2, groupActions]
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fill in the label with text from the species
        self.displaySpeciesDetails()
    }
    
    func displaySpeciesDetails() {
        // just in case we don't have a species due to some error, empty out the label's contents
        self.descriptionLabel!.text = ""
        if self.species == nil {
            return
        }
        
        if let name =  self.species!.name {
            self.title = name // set the title for the navigation bar
            // if they have a language, add that first
            if let language = self.species!.language {
                self.descriptionLabel!.text! += "Members of the \(name) species speak \(language). "
            }
            
            // Add their average height if we have one
            if let height = self.species!.averageHeight {
                self.descriptionLabel!.text! += "The \(self.species!.name!) can be identified by their height, typically \(height)cm."
            }
            
            var eyeColors:String?
            if let colors = self.species!.eyeColors {
                eyeColors = colors.joined(separator: ", ")
            }
            var skinColors:String?
            if let colors = self.species!.skinColors {
                skinColors = colors.joined(separator: ", ")
            }
            var hairColors:String?
            if let colors = self.species!.hairColors {
                hairColors = colors.joined(separator: ", ")
            }
            
            if eyeColors != nil && skinColors != nil && hairColors != nil {
                // if any of the colors, tack 'em on
                self.descriptionLabel!.text! += "\n\nTypical coloring includes eyes:\n\t\(eyeColors!)\nhair:\n\t\(hairColors!)\nand skin:\n\t\(skinColors!)"
            }
        }
        
        if self.species?.averageLifespan != nil {
            // some species have numeric lifespans (like 100) and some have lifespans like "indefinite", so we handle both by adding " years" to the numeric ones
            if let lifespan = self.species?.averageLifespan {
                self.descriptionLabel!.text! += "\n\nTheir average lifespan is \(lifespan)"
                let numericLifespan = Int(lifespan)
                if numericLifespan != nil {
                    self.descriptionLabel!.text! += " years."
                } else {
                    self.descriptionLabel!.text! += "."
                }
            }
        }
        self.descriptionLabel!.sizeToFit() // to top-align text
    }

}
