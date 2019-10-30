//
//  Service.swift
//  SampleServer
//
//  Created by Volkov Alexander on 10/12/19.
//

import Foundation
import PerfectHTTP
import PerfectMongoDB
import SwiftyJSON
import SwiftEx

class Service {
    
    /// the client
    private var client: MongoClient!
    /// the database reference
    private var database: MongoDatabase!
    private var lastCollection: MongoCollection!
    
    // shared instance
    static let shared = Service()
    
    func collection() -> MongoCollection {
        self.lastCollection = database.getCollection(name: "Model")!
        return self.lastCollection
    }
    
    deinit {
        database.close()
        client.close()
    }
    
    private func close() {
        lastCollection.close()
    }
    
    // Initializer. Creates connection.
    init() {
        do {
            let client = try MongoClient(uri: "mongodb://\(Configuration.databaseUser):\(Configuration.databasePassword)@\(Configuration.databaseHost)")
            let db = client.getDatabase(name: Configuration.databaseName)
            self.client = client
            self.database = db
            let res = database.createCollection(name: "Model", options: nil)
            if case .success = res {
                
            } else if case .error(_,_,let message) = res { throw message }
        }
        catch let error {
            print("ERROR: \(error)")
        }
    }
    
    /// Create object
    func create(_ object: Model) throws -> Model {
        let collection = self.collection()
        let result = collection.insert(document: try object.bson(), flag: .noValidate)
        if case .success = result {
            return object
        }
        else {
            throw collection.getLastError().asString
        }
    }

    /// Update object
    func update(_ object: Model, byId id: String) throws {
        let collection = self.collection()
        let result = collection.update(update: try object.bson(), selector: selector("_id", id))
        if case .success = result {
            return
        }
        else {
            throw collection.getLastError().asString
        }
    }

    /// Delete by ID
    func delete(id: String) throws {
        let collection = self.collection()
        let result = collection.remove(selector: selector("_id", id))
        if case .success = result {
            return
        }
        else {
            throw collection.getLastError().asString
        }
    }
    
    /// Select all objects
    func selectAll() throws -> [Model]  {
        let collection = self.collection()
        guard let query = collection.find() else { throw collection.getLastError().asString }
        var items = [Model]()
        for item in query {
            let json: JSON = JSON(parseJSON: item.asString)
            guard let object: Model = try? json.decodeIt() else {
                var object = Model.fromJson(json)
                object.handle = "Wrong format: \(json.debugDescription) -> handle: \(json["handle"].stringValue), id: \(json["id"].stringValue)"
                items.append(object)
                continue
            }
            items.append(object)
        }
        defer {
            close()
        }
        return items
    }
    
    /// Select all objects
    func select(byId id: String) throws -> Model  {
        let collection = self.collection()
        guard let query = collection.find(query: selector("_id", id)) else { throw collection.getLastError().asString }
        var items = [Model]()
        for item in query {
            let json: JSON = JSON(parseJSON: item.asString)
            let object = Model.fromJson(json)
            items.append(object)
        }
        guard let item = items.first else { throw HTTPResponseError(status: .notFound, description: "Object with such ID is not found") }
        defer {
            close()
        }
        return item
    }
    
    private func selector(_ key: String, _ value: String) -> BSON {
        return try! BSON(json: "{\"\(key)\": {\"$oid\": \"\(value)\"}}");
    }
}

// Allow to throw strings as errors
extension String: Error { }

extension Encodable {
    
    func bson() throws -> BSON {
        let string = try self.json().rawString() ?? ""
        return try BSON(json: string)
    }
}

extension Decodable {
    
    static func from(bson: BSON) throws -> Self {
        let json: JSON = JSON(parseJSON: bson.asString)
        return try json.decodeIt()
    }
}
