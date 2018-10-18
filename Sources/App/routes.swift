import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    


    // n > t > d


    // Example of configuring a controller
    let todoController = TodoController()
    router.get("/", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.get("fetch", use: todoController.fetch)
    router.post("show",use: todoController.show)

    router.delete("todos", Todo.parameter, use: todoController.delete)
    
    router.get("getAccessToken",use: todoController.getAccessToken)
    router.post("/", use: todoController.handMsg)
//    router.post(PathComponentsRepresentable) { (Request) -> ResponseEncodable in
    
    
}
