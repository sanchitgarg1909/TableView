//
//  StringArrayConvertible.swift
//  TableView4
//
//  Created by Sanchit Garg on 08/10/16.
//  Copyright © 2016 Sanchit Garg. All rights reserved.
//

import Foundation

extension String {
    func splitStringToArray() -> Array<String> {
        var outputArray = Array<String>()
        
        let components = self.components(separatedBy: ",")
        for component in components {
            let trimmedComponent = component.trimmingCharacters(in: NSCharacterSet.whitespaces)
            outputArray.append(trimmedComponent)
        }
        
        return outputArray
    }
}
