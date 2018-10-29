//
//  Mconfig.swift
//  App
//
//  Created by duanhai on 2018/10/16.
//

import Foundation
import MongoKitten

let db = try! MongoKitten.Database("mongodb://144.34.175.98:27017/myapp")
let myCollection = db["users"]

