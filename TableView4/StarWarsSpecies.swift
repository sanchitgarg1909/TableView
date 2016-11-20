//
//  StarWarsSpecies.swift
//  TableView4
//
//  Created by Sanchit Garg on 07/10/16.
//  Copyright © 2016 Sanchit Garg. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SpeciesWrapper {
    var species: [StarWarsSpecies]?
    var count: Int?
    var next: String?
    var previous: String?
}

enum SpeciesFields: String {
    case Name = "name"
    case Classification = "classification"
    case Designation = "designation"
    case AverageHeight = "average_height"
    case SkinColors = "skin_colors"
    case HairColors = "hair_colors"
    case EyeColors = "eye_colors"
    case AverageLifespan = "average_lifespan"
    case Homeworld = "homeworld"
    case Language = "language"
    case People = "people"
    case Films = "films"
    case Created = "created"
    case Edited = "edited"
    case Url = "url"
}

class StarWarsSpecies {
    var idNumber: Int?
    var name: String?
    var classification: String?
    var designation: String?
    var averageHeight: Int?
    var skinColors: Array<String>?
    var hairColors: Array<String>?
    var eyeColors: Array<String>?
    var averageLifespan: String?
    var homeworld: String?
    var language: String?
    var people: Array<String>?
    var films: Array<String>?
    var created: NSDate?
    var edited: NSDate?
    var url: String?
    
    required init(json: JSON, id: Int?) {
        self.idNumber = id
        
        // strings
        self.name = json[SpeciesFields.Name.rawValue].stringValue
        self.classification = json[SpeciesFields.Classification.rawValue].stringValue
        self.designation = json[SpeciesFields.Designation.rawValue].stringValue
        self.language = json[SpeciesFields.Language.rawValue].stringValue
        // lifespan is sometimes "unknown" or "infinite", so we can't use an int
        self.averageLifespan = json[SpeciesFields.AverageLifespan.rawValue].stringValue
        self.homeworld = json[SpeciesFields.Homeworld.rawValue].stringValue
        self.url = json[SpeciesFields.Url.rawValue].stringValue
        
        // ints
        self.averageHeight = json[SpeciesFields.AverageHeight.rawValue].intValue
        
        // strings to arrays like "a, b, c"
        // SkinColors, HairColors, EyeColors
        if let string = json[SpeciesFields.SkinColors.rawValue].string
        {
            self.skinColors = string.splitStringToArray()
        }
        if let string = json[SpeciesFields.HairColors.rawValue].string
        {
            self.hairColors = string.splitStringToArray()
        }
        if let string = json[SpeciesFields.EyeColors.rawValue].string
        {
            self.eyeColors = string.splitStringToArray()
        }
        
        // arrays
        // People, Films
        // there are arrays of JSON objects, so we need to extract the strings from them
        if let jsonArray = json[SpeciesFields.People.rawValue].array
        {
            self.people = Array<String>()
            for entry in jsonArray
            {
                self.people?.append(entry.stringValue)
            }
        }
        if let jsonArray = json[SpeciesFields.Films.rawValue].array
        {
            self.films = Array<String>()
            for entry in jsonArray
            {
                self.films?.append(entry.stringValue)
            }
        }
        
        // Dates
        // Created, Edited
        let dateFormatter = StarWarsSpecies.dateFormatter()
        if let dateString = json[SpeciesFields.Created.rawValue].string
        {
            self.created = dateFormatter.date(from: dateString) as NSDate?
        }
        if let dateString = json[SpeciesFields.Edited.rawValue].string
        {
            self.edited = dateFormatter.date(from: dateString) as NSDate?
        }
    }
    
    class func dateFormatter() -> DateFormatter {
        // TODO: reuse date formatter, they're expensive!
        let aDateFormatter = DateFormatter()
        aDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        aDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
        aDateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        return aDateFormatter
    }
    
//    // MARK: Endpoints
//    class func endpointForID(id: Int) -> String {
//        return "https://swapi.co/api/species/\(id)"
//    }
    class func endpointForSpecies() -> String {
        return "https://swapi.co/api/species/"
    }
    
//    // MARK: CRUD
//    // GET / Read single species
//    class func speciesByID(id: Int, completionHandler: (StarWarsSpecies?, NSError?) -> Void) {
//        Alamofire.request(.GET, StarWarsSpecies.endpointForID(id))
//            .responseSpecies { (request, response, species, error) in
//                if let anError = error
//                {
//                    completionHandler(nil, error)
//                    return
//                }
//                completionHandler(species, nil)
//        }
//    }
    
    // GET / Read all species
    private class func getSpeciesAtPath(path: String, completionHandler: @escaping (SpeciesWrapper?, NSError?) -> Void) {
        let securePath = path.replacingOccurrences(of: "http://", with: "https://")
        Alamofire.request(securePath)
            .responseSpeciesArray { (response: DataResponse<SpeciesWrapper>) in
                if let result = response.result.value{
                    completionHandler(result, nil)
                }
            }
    }
    
    class func getSpecies(completionHandler: @escaping (SpeciesWrapper?, NSError?) -> Void) {
        getSpeciesAtPath(path: StarWarsSpecies.endpointForSpecies(), completionHandler: completionHandler)
    }
    
    class func getMoreSpecies(wrapper: SpeciesWrapper?, completionHandler: @escaping (SpeciesWrapper?, NSError?) -> Void) {
        if wrapper == nil || wrapper?.next == nil
        {
            completionHandler(nil, nil)
            return
        }
        getSpeciesAtPath(path: wrapper!.next!, completionHandler: completionHandler)
    }
    
}

extension DataRequest {
    func responseSpeciesArray(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<SpeciesWrapper>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<SpeciesWrapper> { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            guard let responseData = data else {
                let failureReason = "Array could not be serialized because input data was nil."
//                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .failure(failureReason as! Error)
            }
            
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, nil)
            
            switch result {
            case .success(let value):
                let json = SwiftyJSON.JSON(value)
                let wrapper = SpeciesWrapper()
                wrapper.next = json["next"].stringValue
                wrapper.previous = json["previous"].stringValue
                wrapper.count = json["count"].intValue
                
                var allSpecies = [StarWarsSpecies]()
//                print(json)
                let results = json["results"]
//                print(results)
                for jsonSpecies in results
                {
//                    print(jsonSpecies.0)
//                    print(jsonSpecies.1)
                    let species = StarWarsSpecies(json: jsonSpecies.1, id: Int(jsonSpecies.0))
                    allSpecies.append(species)
                }
                wrapper.species = allSpecies
                return .success(wrapper)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return response(queue: queue, responseSerializer: responseSerializer,completionHandler: completionHandler)
    }
}


