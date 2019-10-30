//
//  Controller.swift
//  SampleServer
//
//  Created by Volkov Alexander on 10/12/19.
//

import Foundation
import PerfectHTTP
import PerfectLib
import SwiftyJSON

/// The example controller for handling Model objects
class Controller {
    
    /// CRUD handler for Model object
    static func handler(request: HTTPRequest, response: HTTPResponse) throws {
        switch request.method {
            
        // GET handler
        case .get:
            let items = try Service.shared.selectAll()
            try response.response(items)
            
        // POST handler
        case .post:
            guard let body = request.json() else { response.completed(status: .badRequest); return }
            guard let object: Model = try? body.decodeIt() else { response.completed(status: .badRequest); return }
            let newObject = try Service.shared.create(object)
            try response.response(newObject)
            response.status = .created

        // PUT handler
        case .put:
            guard let object: Model = (try request.body()) else { response.completed(status: .badRequest); return }

            /// Reset ID to the ID provided in the URL
            let id = try request.getID()
            _ = try Service.shared.select(byId: id)

            try Service.shared.update(object, byId: id)
            try response.response(object)

        // DELETE handler
        case .delete:
            let id = try request.getID()
            _ = try Service.shared.select(byId: id) // check if object exists
            try Service.shared.delete(id: id)
            
        // Other methods handler
        default:
            response.status = .methodNotAllowed
        }
        response.completed()
    }
    
}
