//
//  Mconfig.swift
//  App
//
//  Created by duanhai on 2018/10/16.
//

import Foundation
import MongoKitten

let db = try! MongoKitten.Database("mongodb://35.185.190.141:27000/myapp")
let myCollection = db["users"]

