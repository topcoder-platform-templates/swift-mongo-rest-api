//
//  ServerExtensions.swift
//  SampleServer
//
//  Created by Volkov Alexander on 03.11.2018.
//  Updated by Volkov Alexander on 10/12/2019.
//

import Foundation
import PerfectHTTP
import SwiftyJSON

// Content-Type constant
public let applicationJson = "application/json"

/// Helpful extension for HTTPResponse
extension HTTPResponse {
    
    /// Add message to response
    ///
    /// - Parameter message: the message
    func message(_ message: String) {
        let json = JSON(["message": message])
        appendBody(string: json.rawString() ?? "")
    }
    
    /// Add response
    ///
    /// - Parameter dic: the dictionary
    func response(_ dic: [String: Any]) {
        let json = JSON(dic)
        appendBody(string: json.rawString() ?? "")
    }
    
    /// Add response
    ///
    /// - Parameter array: the array
    public func response(_ array: [Any]) {
        setHeader(.contentType, value: applicationJson)
        let json = JSON(array)
        appendBody(string: json.rawString() ?? "")
    }
    
    /// Set the status and call completed() and add message to response
    ///
    /// - Parameters:
    ///   - status: the status
    ///   - message: the message
    public func completed(status: HTTPResponseStatus, message msg: String) {
        setHeader(.contentType, value: applicationJson)
        self.message(msg)
        self.status = status
        completed()
    }
    
    /// Add response
    ///
    /// - Parameter object: the object
    public func response(_ object: Encodable) throws {
        setHeader(.contentType, value: applicationJson)
        let json = try object.json()
        appendBody(string: json.rawString() ?? "")
    }
}

/// Helpful extension for HTTPRequest
extension HTTPRequest {
    
    /// Get ID from the path
    ///
    /// - Returns: the ID
    /// - Throws: 400 or 404
    public func getID() throws -> String {
        guard let id = self.urlVariables["id"] else {
            throw HTTPResponseError(status: .badRequest, description: "ID is not provided")
        }
        return id
    }
    
    /// Parse JSON body
    ///
    /// - Returns: the JSON
    public func json() -> JSON? {
        let json = JSON(parseJSON: postBodyString ?? "")
        if json == JSON.null {
            return nil
        }
        else {
            return json
        }
    }
    
    /// Parse body and return object
    public func body<T: Decodable>() throws -> T? {
        guard let body = self.json() else { return nil }
        let object: T = try body.decode(T.self)
        return object
    }
}

/// Function which receives request and response objects and generates content.
public typealias ThrowRequestHandler = (HTTPRequest, HTTPResponse) throws -> ()

/// Handler wrapper. Catches server errors
public class HandlerWrapper {
    
    /// the effective handler
    let handler: ThrowRequestHandler
    
    /// Initializer
    ///
    /// - Parameter handler: the handler to wrap
    public init(_ handler: @escaping ThrowRequestHandler) {
        self.handler = handler
    }
    
    /// RequestHandler
    ///
    /// - Parameters:
    ///   - request: the request
    ///   - response: the response
    public func handler(request: HTTPRequest, response: HTTPResponse) {
        do {
            try handler(request, response)
        }
        catch let error { // catch error and return 500 code with error message
            if let error = error as? HTTPResponseError {
                response.completed(status: error.status, message: error.description)
            }
            else {
                response.completed(status: .internalServerError, message: (error as? String) ?? error.localizedDescription)
            }
        }
    }
}

extension Routes {
    
    /// Add the given uri and handler as a route.
    /// This will add the route for all standard methods.
    public mutating func addCRUD(uri: String, handler: @escaping ThrowRequestHandler) {
        add(method: .get, uri: uri, handler: HandlerWrapper(handler).handler)
        add(method: .post, uri: uri, handler: HandlerWrapper(handler).handler)
        add(method: .put, uri: "\(uri)/{id}", handler: HandlerWrapper(handler).handler)
        add(method: .delete, uri: "\(uri)/{id}", handler: HandlerWrapper(handler).handler)
    }
}

extension Encodable {
    
    /// Convert to dictionary (to use as parameters)
    public func dictionary() -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(self)
            let json = try JSON(data: data)
            let dic = json.dictionaryObject ?? [:]
            return dic
        }
        catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Convert object to another type using intermidiate JSON object
    ///
    /// - Returns: the decoded object
    public func convert<T>() -> T where T : Decodable {
        let data = try! JSONEncoder().encode(self)
        let json = try! JSON(data: data)
        let result = try! JSONDecoder().decode(T.self, from: try json.rawData())
        return result
    }
    
    /// Convert object to JSON data
    public func data() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    /// Convert object to JSON
    public func json() throws -> JSON {
        return try JSON(data: data())
    }
}

// MARK: - SwiftyJSON extensions
extension JSON {
    
    /// Decode object of given type from JSON
    /// Created by Volkov Alexander on 18/12/18.
    ///
    /// - Parameter type: the type
    /// - Returns: the decoded object
    /// - Throws: the decoding error
    public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let result = try JSONDecoder().decode(T.self, from: try self.rawData())
        return result
    }
    
    /// Decode object of given type from JSON
    /// Created by Volkov Alexander on 05/02/19.
    ///
    /// - Returns: the decoded object
    /// - Throws: the decoding error
    public func decodeIt<T>() throws -> T where T : Decodable {
        let result = try JSONDecoder().decode(T.self, from: try self.rawData())
        return result
    }
    
    /// Convert to array of objects
    ///
    /// - Returns: the array
    public func toArray<T>() -> [T] where T : Decodable {
        let items: [T] = self.arrayValue.map { try? $0.decode(T.self) }.filter({$0 != nil}) as! [T]
        return items
    }
}

/// Extenstion adds helpful methods to Int
extension Int {
    
    /// Get uniform random value between 0 and maxValue
    ///
    /// - Parameter maxValue: the limit of the random values
    /// - Returns: random Int
    public static func rand(_ maxValue: Int = 1000000) -> Int {
        return Int.random(in: 0...maxValue)
    }
    
    /// Convert to UUID
    ///
    /// - Returns: UUID
    public func toUUID() -> UUID {
        var bytes = [UInt8](repeating: 0, count: 8)
        for i in 0..<8 {
            let byte: UInt8 = UInt8((self >> (i * 8)) & 255)
            bytes[i] = byte
        }
        
        let uuid = UUID(uuid: (UInt8(0),UInt8(0),UInt8(0),UInt8(0),UInt8(0),UInt8(0),UInt8(0),UInt8(0), bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7]))
        return uuid
    }
    
    /// Convert from UUID
    ///
    /// - Parameter uuid: UUID
    /// - Returns: int value
    public static func from(uuid: UUID) -> Int {
        let b1 = uuid.uuid.8
        let b2 = uuid.uuid.9
        let b3 = uuid.uuid.10
        let b4 = uuid.uuid.11
        let b5 = uuid.uuid.12
        let b6 = uuid.uuid.13
        let b7 = uuid.uuid.14
        let b8 = uuid.uuid.15
        var value = 0
        value += Int(b8); value <<= 8
        value += Int(b7); value <<= 8
        value += Int(b6); value <<= 8
        value += Int(b5); value <<= 8
        value += Int(b4); value <<= 8
        value += Int(b3); value <<= 8
        value += Int(b2); value <<= 8
        value += Int(b1);
        return value
    }
}

