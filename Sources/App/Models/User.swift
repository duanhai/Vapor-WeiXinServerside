//
//  User.swift
//  App
//
//  Created by duanhai on 2018/10/16.
//

import Foundation
import MongoKitten

struct User {
    static let collection = db["user"]
    var id: ObjectId
    var name: String
    var email: String
    var location: String
    var phoneNumber: String
    
    var document: Document {
        return ["_id": self.id,
                "name":self.name,
                "email":self.email,
                "location":self.location,
                "phoneNumber":self.phoneNumber]
        
    }
    
    var documentForSave: Document {
        
        return ["username":self.name,
                "email":self.email,
                "location":self.location,
                "phoneNumber":self.phoneNumber]
    }
    
    init(username: String, email: String? = "", location: String? = "", phoneNumber: String){
        self.id = ObjectId()
        self.name = username
        self.email = email ?? ""
        self.location = location ?? ""
        self.phoneNumber = phoneNumber
    }
    
    init(id: String) throws {
        let objectId = try ObjectId(id)
        let query: Query = "_id" == objectId
        guard let user = try User.collection.findOne(query) else {
            fatalError()
        }
        
        guard let username = user.dictionaryRepresentation["name"] as? String, let email = user.dictionaryRepresentation["email"] as? String, let location = user.dictionaryRepresentation["location"] as? String, let phoneNumber = user.dictionaryRepresentation["phoneNumber"] as? String else {
            fatalError()
        }
        
        self.id = objectId
        self.name = username
        self.location = location
        self.email = email
        self.phoneNumber = phoneNumber
        
    }
    
    func save() throws -> Int{
        let query: Query = "_id" == self.id
        
        let aCode = try User.collection.update(query, to: document, upserting: true, multiple: true)
//        let code =  try User.collection.update(bulk: [(filter: query, to: document , upserting: true, multiple: true)])
        return aCode
    }
    
    
    func delete() throws -> Int {
        let query: Query = "_id" == self.id
       let code =  try User.collection.remove(bulk: [(filter: query, limit:1)])
        return code
    }
    
    func add() throws -> ObjectId {
        let code = try User.collection.insert(document)
        return code as! ObjectId
    }
    
    
    static func lookup(name: String? = nil) throws -> [Document] {
        let query: Query = "name" == name
        var documentArray: [Document]? = []

        if let na = name {
            print("+++++====")

            let result = try User.collection.find(query)
            try result.compactMap({doc in
                //            print(doc.dictionaryRepresentation["username"] as! String)
                //            return doc
                documentArray?.append(doc)
            })
        }else {
            let result = try User.collection.find()
            print("=======\(result)")
            try result.compactMap({doc in
                //            print(doc.dictionaryRepresentation["username"] as! String)
                //            return doc
                documentArray?.append(doc)
            })
        }
        
        

        
        return documentArray!
    }
}
