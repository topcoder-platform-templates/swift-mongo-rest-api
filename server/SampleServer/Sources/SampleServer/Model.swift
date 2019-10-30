//
//  Model.swift
//  SampleServer
//
//  Created by Volkov Alexander on 10/12/19.
//

import Foundation
import SwiftyJSON
import PerfectMongoDB

/// The model object
struct Model: Codable {
    
    /// the fields
    var _id: JSON?
    var handle: String!
 
    static func fromJson(_ json: JSON) -> Model {
        var object = Model()
        object._id = json["id"]
        object.handle = json["handle"].stringValue
        return object
     }
    
}
