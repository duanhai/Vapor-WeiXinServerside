import Vapor
import Foundation
import MongoKitten

import SwiftyXMLParser

struct Userpost: Content {
    var username: String
    var email: String
    var locaiton: String
    var phoneNumber: String
//    var id: String? = nil
    func description() -> String {
        return "username \(self.username)"
    }
}

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    
    struct MPToken: Decodable {
        var expires_in: Int?
        var access_token: String?
    }
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> String {
        
        
        
        var times: String = ""
        var noc: String = ""
        var sig: String = ""
        var echo: String = ""
        
        if let signature = try? req.query.get(String.self, at: "signature") {
            print("\(signature)")
            sig = signature
            print("签名 \(sig)")
        } else {
            
        }
        if let timestamp = try? req.query.get(String.self,at: "timestamp"){
            times = timestamp
        } else {
            
        }
        
        if let nonce = try? req.query.get(String.self,at: "nonce"){
            noc = nonce
        } else {
            
        }
        
        if let echostr = try? req.query.get(String.self,at: "echostr"){
            echo = echostr
        } else {
            
        }
        
        var sortArr:[String] = ["pzh189",times,noc]
        sortArr = sortArr.sorted()
        
        let echoString = sortArr.joined(separator: "")
        let sha1 = SHA1.hexString(from: echoString)
        let okstr = sha1!.replacingOccurrences(of: " ", with: "").lowercased()
        if(sig == okstr){
            return echo
        }else {
            return "签名有问题"
        }
        //        return Todo.query(on: req).all()
    }
    
    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap { todo in
            return todo.save(on: req)
        }
    }
    
    func fetch(_ req: Request) throws -> Future<[Todo]> {
        return Todo.query(on: req).all()
    }
    
    func show(_ req: Request) throws -> String {

        //解码
        var post: Userpost? = nil
        try req.content.decode(Userpost.self).map{onePost in
//            print(onePost) 不能在这个里面做太复杂的推断
            post = onePost
        }
        
        if let pp = post {
//            print(pp.username)
//            return pp.description()
            
            let user = User(username: pp.username, phoneNumber: pp.phoneNumber)
//            let user = try User(id: "5bc58007e43ae38d531bc50c")
            
            let code = try User.lookup(name: pp.username)
            
            var responseString: String = ""
            
            for doc in code {
                
                guard let username = doc.dictionaryRepresentation["username"] as? String else{
                    fatalError()
                }
                
                guard let name = doc.dictionaryRepresentation["name"] as? String else{
                    fatalError()
                }
                
                guard let phone = doc.dictionaryRepresentation["phoneNumber"] as? String else{
                    fatalError()
                }
                
                responseString += username
                responseString += name
                responseString += name

                
            }
            
            return "\(code)"
        }
        
        
        return "oooo"
    }
    
    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
            }.transform(to: .ok)
    }
    
    
    func getAccessToken(_ req: Request) throws -> String {
        
        
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let eventLoop = eventLoopGroup.next()
        let httpClient = try HTTPClient.connect(scheme: .https, hostname: "api.weixin.qq.com", on: eventLoop).wait()
        let httpReq = HTTPRequest(method: .GET, url: "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=wx0610b52f18fc2c6b&secret=e48f4d8b5696d82aa3904ba2a4f23008")
        // Send the HTTP request, fetching a response
        let httpRes = try httpClient.send(httpReq).wait()
        print(httpRes)
        let jString = httpRes.body.description;
        let jsonData = jString.data(using: String.Encoding.utf8)!
        
        let decoder = JSONDecoder()
        let tokenModel = try? decoder.decode(MPToken.self, from: jsonData)
        
        if let token = tokenModel?.access_token,let expireTime = tokenModel?.expires_in {
            print(token)
            let userDefault = UserDefaults.standard
            userDefault.set(token, forKey: "accessToken")
            userDefault.set(expireTime, forKey: "expires_in")
        }
        

        
        return "abc"
    }
    // Create an HTTP request: GET /
    
    func handMsg(_ req: Request) throws -> String {
        print(req)
        var spStr:[String] = req.description.components(separatedBy: "close")
        if spStr.count > 1 {
            
            var xmlStr = spStr[1].replacingOccurrences(of: "\n", with: "")
            let xml = try! XML.parse(xmlStr)
            let ToUserName = xml["xml"]["ToUserName"].text!
            let FromUserName = xml["xml"]["FromUserName"].text!
            let CreateTime = xml["xml"]["CreateTime"].text!
            let MsgType = xml["xml"]["MsgType"].text!
            let MsgId = xml["xml"]["MsgId"].text!
            let Content = xml["xml"]["Content"].text!
            var responseString: String = " "

            if Content == "all" {
                let code = try User.lookup()
                
                for doc in code {
                    
                    var userName: String = ""
                    var phoneNumber: String = ""
                    var location: String = ""
                    if let username = doc.dictionaryRepresentation["name"] as? String {
                        userName = username
                    }
                    
                    if let phone = doc.dictionaryRepresentation["phoneNumber"] as? String {
                        phoneNumber = phone
                    }
                    
                    if let location1 = doc.dictionaryRepresentation["location"] as? String {
                        location = location1
                    }
                    
                    responseString += "姓名 \(userName)"
                    responseString += "   "
                    responseString += "手机 \(phoneNumber)"
                    responseString += "   "
                    responseString += "地址 \(location)"
                    
                    
                }
            }else {
                
                let code = try User.lookup(name: Content)
                
                for doc in code {
                    
                    var userName: String = ""
                    var phoneNumber: String = ""
                    var location: String = ""
                    if let username = doc.dictionaryRepresentation["name"] as? String {
                        userName = username
                    }
                    
                    if let phone = doc.dictionaryRepresentation["phoneNumber"] as? String {
                        phoneNumber = phone
                    }
                    
                    if let location1 = doc.dictionaryRepresentation["location"] as? String {
                        location = location1
                    }
                    
                    responseString += "姓名 \(userName)"
                    responseString += "   "
                    responseString += "手机 \(phoneNumber)"
                    responseString += "   "
                    responseString += "地址 \(location)"
                }
            }
           
            let mongoContent = responseString
//            var xmlContent =  "<xml><ToUserName><![CDATA[\(FromUserName)]]></ToUserName>"
//            xmlContent += "<FromUserName><![CDATA[\(ToUserName)]]></FromUserName>"
//            xmlContent += "<CreateTime>\(Date().timeStamp)</CreateTime>"
//            xmlContent += "<MsgType><![CDATA[text]]></MsgType>"
//            xmlContent += "<Content><![CDATA[\(Content)]]></Content></xml>";
            let xmlContent = combineXml(ToUserName, FromUserName, mongoContent)
            if MsgType == "text" {
                return xmlContent
            }
        }
  
        return ""
    }
    
    func combineXml(_ ToUserName:String,_ FromUserName:String,_ Content:String) -> String {
        
        var xmlContent =  "<xml><ToUserName><![CDATA[\(FromUserName)]]></ToUserName>"
        xmlContent += "<FromUserName><![CDATA[\(ToUserName)]]></FromUserName>"
        xmlContent += "<CreateTime>\(Date().timeStamp)</CreateTime>"
        xmlContent += "<MsgType><![CDATA[text]]></MsgType>"
        xmlContent += "<Content><![CDATA[\(Content)]]></Content></xml>"
        return xmlContent
    }
    
}
