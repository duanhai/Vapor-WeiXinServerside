//
//  Mconfig.swift
//  App
//
//  Created by duanhai on 2018/10/16.
//

import Foundation
import MongoKitten

let db = try! MongoKitten.Database("mongodb://localhost/myapp")
let myCollection = db["users"]

