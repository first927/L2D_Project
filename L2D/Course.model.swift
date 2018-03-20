//
//  Course.model.swift
//  L2D
//
//  Created by Watcharagorn mayomthong on 7/27/2560 BE.
//  Copyright © 2560 Watcharagorn mayomthong. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Course : NSObject{
    var id : Int
    var name:String
    var owner:String
    var img:String
    var categoryId : Int
    var detail : String
    var createdDate : Float
    var key : String
    var section : [Section_model]?
    var rating : Double
    
    init(id:Int ,categoryId:Int ,detail:String ,createdDate:Float ,key:String ,name:String ,owner:String, img:String , section : [Section_model], rating: Double) {
        self.id = id
        self.categoryId = categoryId
        self.detail = detail
        self.createdDate = createdDate
        self.key = key
        self.name = name
        self.owner = owner
        self.img = img
        self.section = section
        self.rating = rating
    }
    
    init(id:Int ,categoryId:Int ,detail:String ,createdDate:Float ,key:String ,name:String ,owner:String, img:String, rating:Double) {
        self.id = id
        self.categoryId = categoryId
        self.detail = detail
        self.createdDate = createdDate
        self.key = key
        self.name = name
        self.owner = owner
        self.img = img
        self.rating = rating
    }
    
    func Register(completion : @escaping (Bool) -> ()){
        let user_id = AppDelegate.userData?.idmember
        let user_id_str = user_id != nil ? "\(user_id!)" : ""
        if(self.id == 0 || user_id_str == ""){
            print("L2D Warning : coursr id or user id is null")
            completion(false)
            return
        }
        let url = "\(Network.IP_Address_Master)/course/addRegis"
        let parameters: Parameters = ["courseId" : self.id,"memberId" : user_id_str ]
        Alamofire.request(url,method : .post ,parameters : parameters, encoding: JSONEncoding.default)
            .responseJSON{
                
                response in switch response.result{
                case .success(let value):
                    print(value)
                    completion(true)
                    
                    
                //                        let array = json[0]["name"].rawString()
                case .failure(let error):
                    print(error)
                    completion(false)
                }
        }
    }
    
    func UnRegister(completion : @escaping (Bool) -> ()){
        let user_id = AppDelegate.userData?.idmember
        let user_id_str = user_id != nil ? "\(user_id!)" : ""
        if(self.id == 0 || user_id_str == ""){
            print("L2D Warning : coursr id or user id is null")
            completion(false)
            return
        }
        let url = "\(Network.IP_Address_Master)/course/unenroll"
        let parameters: Parameters = ["courseId" : self.id,"memberId" : user_id_str ]
        Alamofire.request(url,method : .post ,parameters : parameters, encoding: JSONEncoding.default)
            .responseJSON{
                
                response in switch response.result{
                case .success(let value):
                    print(value)
                    completion(true)
                    
                    
                //                        let array = json[0]["name"].rawString()
                case .failure(let error):
                    print(error)
                    completion(false)
                }
        }
    }
    
    class func generateModelArray() -> [Course]{
        var course = [Course]()
        course.append(Course(id:1, categoryId:1, detail:"detail", createdDate:12221.13, key:"key", name: "Basic Prograamming",owner: "mit",img:"keyboard",rating: 0))
        course.append(Course(id:1, categoryId:1, detail:"detail", createdDate:12221.13, key:"key", name: "Basic Prograamming",owner: "mit",img:"keyboard",rating: 1))
        course.append(Course(id:1, categoryId:1, detail:"detail", createdDate:12221.13, key:"key", name: "Basic Prograamming",owner: "mit",img:"keyboard",rating: 2))
        course.append(Course(id:1, categoryId:1, detail:"detail", createdDate:12221.13, key:"key", name: "Basic Prograamming",owner: "mit",img:"keyboard",rating: 3))
        course.append(Course(id:1, categoryId:1, detail:"detail", createdDate:12221.13, key:"key", name: "Basic Prograamming",owner: "mit",img:"keyboard",rating: 4))
        course.append(Course(id:1, categoryId:1, detail:"detail", createdDate:12221.13, key:"key", name: "Basic Prograamming",owner: "mit",img:"keyboard",rating: 5))

        return course
    }
    
    class func fetchImg( img : String, completion : @escaping ( _ image : UIImage) -> ()){
        if(img != "download"){
            Course.getfile(key: img, completion: { (path, error) in
                if(error == nil){
                    
                    let url = URL(string: "http://158.108.207.7:8080/\(path ?? "")")
                    
                    let session = URLSession(configuration: .default)
                    
                    //creating a dataTask
                    let getImageFromUrl = session.dataTask(with: url!) { (data, response, error) in
                        
                        //if there is any error
                        if let e = error {
                            //displaying the message
                            print("Error Occurred: \(e)")
                            
                        } else {
                            //in case of now error, checking wheather the response is nil or not
                            if (response as? HTTPURLResponse) != nil {
                                
                                //checking if the response contains an image
                                if let imageData = data {
                                    
                                    //getting the image
                                    let myImg = UIImage(data: imageData)
                                    completion(myImg!)
                                    
                                } else {
                                    print("Image file is currupted")
                                }
                            } else {
                                print("No response from server")
                            }
                        }
                    }
                    
                    //starting the download task
                    getImageFromUrl.resume()
                    
                    
                }else{
                    print(error!)
                }
                
            })
        }else{
            completion(UIImage(named: img)!)
        }
    }
    
    class func getTopCourse(amount : Int, completion : @escaping (_ course:[Course]?, _ errorMessage:String?) -> ()){
        let url = "\(Network.IP_Address_Master)/course?top=\(amount)"
        Alamofire.request(url,method: .get,encoding: JSONEncoding.default).responseJSON{
            response in
            var courses : [Course] = []
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                let result = json["response"]
                if(result["status"] == false){
                    print(result["message"])
                    completion(nil,result["message"].stringValue)
                    return
                }
                
                let objCourses = json["courses"]
                for obj in objCourses{
                    let this_course = obj.1
                    
                    //find course picture key
                    let sections = this_course["sectionList"].arrayValue
                    var img = "download"
                    for section in sections{
                        if(section["rank"].intValue == 0){
                            img = section["content"].stringValue
                        }
                    }
                    
                    //add course in model
                    courses.append(Course(
                        id : this_course["id"].intValue,
                        categoryId: this_course["categoryId"].intValue,
                        detail: this_course["detail"].stringValue,
                        createdDate: this_course["createdDate"].floatValue,
                        key: this_course["key"].stringValue,
                        name : this_course["name"].stringValue,
                        owner: this_course["teacher"] != JSON.null ? "\(this_course["teacher"]["name"]) \(this_course["teacher"]["surname"])" : "",
                        img: img,
                        rating: this_course["rating"].doubleValue
                    ))
                }
                
                completion(courses,nil)
            case .failure(let error):
                completion(nil,error.localizedDescription)
                print(error)
            }
            
        }
    }
    
    class func getNewCourse(amount : Int, completion : @escaping (_ course:[Course]?, _ errorMessage:String?) -> ()){
        let url = "\(Network.IP_Address_Master)/course?new=\(amount)"
        Alamofire.request(url,method: .get,encoding: JSONEncoding.default).responseJSON{
            response in
            var courses : [Course] = []
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                let result = json["response"]
                if(result["status"] == false){
                    print(result["message"])
                    completion(nil,result["message"].stringValue)
                    return
                }
                
                let objCourses = json["courses"]
                for obj in objCourses{
                    let this_course = obj.1
                    
                    //find course picture key
                    let sections = this_course["sectionList"].arrayValue
                    var img = "download"
                    for section in sections{
                        if(section["rank"].intValue == 0){
                            img = section["content"].stringValue
                        }
                    }
                    
                    //add course
                    courses.append(Course(
                        id : this_course["id"].intValue,
                        categoryId: this_course["categoryId"].intValue,
                        detail: this_course["detail"].stringValue,
                        createdDate: this_course["createdDate"].floatValue,
                        key: this_course["key"].stringValue,
                        name : this_course["name"].stringValue,
                        owner: this_course["teacher"] != JSON.null ? "\(this_course["teacher"]["name"]) \(this_course["teacher"]["surname"])" : "",
                        img: img,
                        rating: this_course["rating"].doubleValue
                    ))
                }
                
                completion(courses,nil)
            case .failure(let error):
                completion(nil,error.localizedDescription)
                print(error)
            }
            
        }
    }
    
    class func getCoureWithCheckRegis( id:Int , completion : @escaping (_ course: Course?, _ errorMessage:String?, _ isRegis:Bool?, _ rating:Double?) -> ()){
        let urlString = "\(Network.IP_Address_Master)/course/isRegis"
        let user_id = AppDelegate.userData?.idmember
        let user_id_str = user_id != nil ? "\(user_id!)" : "0"
        let parameters: Parameters = ["memberId" : user_id_str,"courseId" : id ]
        
        
        Alamofire.request(urlString, method : .post , parameters : parameters , encoding: JSONEncoding.default )
            .responseJSON{
                
                response in switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    let result = json["response"]
                    let courseJSON = json["course"]
                    let isRegis = json["isRegis"].boolValue
                    let rating = json["rating"]
                    
                    if(result["status"] == false){
                        print(result["message"])
                        completion(nil,result["message"].stringValue,isRegis,nil)
                        return
                    }
                    
                    
                    
                    let course = Course(
                        id :  courseJSON["id"].intValue,
                        categoryId: courseJSON["categoryId"].stringValue == "" ? -1 : courseJSON["categoryId"].intValue,
                        detail: courseJSON["detail"].stringValue,
                        createdDate: courseJSON["createdDate"].stringValue == "" ? -1 : courseJSON["createdDate"].floatValue,
                        key: courseJSON["key"].stringValue,
                        name : courseJSON["name"].stringValue,
                        owner: courseJSON["teacher"] != JSON.null ? "\(courseJSON["teacher"]["name"]) \(courseJSON["teacher"]["surname"])" : "",
                        img: "keyboard",
                        section : [],
                        rating: courseJSON["rating"].doubleValue
                    )
                    
                    let sections = courseJSON["sectionList"].arrayValue.sorted()
                    
                    for section in sections{
                        let thisSection = Section_model(
                            id: section["sectionId"].intValue,
                            name: section["name"].stringValue,
                            rank: section["rank"].intValue,
                            subSection: [])
                        

                        let subSections = section["sub-section"].arrayValue.sorted()
                        
                        for sub in subSections{
                            
                            var type : fileType = .none
                            if (sub["contentType"].stringValue == "VIDEO"){
                                type = .video
                            }else{
                                type = .document
                            }
                            
                            let thisSub = SubSection(id: sub["sectionId"].intValue, name: sub["name"].stringValue, fileKEY: sub["content"].stringValue, rank: section["rank"].intValue , type : type)
                            
                            thisSection.subSection?.append(thisSub)
                            

                        }
                        course.section?.append(thisSection)
                    }
                    
                    completion(course,nil,isRegis,rating != JSON.null ? rating.doubleValue : nil)
                case .failure(let error):
                    print(error)
                    //                    completion(course)
                    completion(nil, error.localizedDescription,false,nil)
                }
        }
    }
    
    class func getCoureById( id:Int , completion : @escaping (_ course: Course?, _ errorMessage:String?) -> ()){
        let urlString = "\(Network.IP_Address_Master)/course?courseId=\(id)"
        Alamofire.request(urlString,method : .get , encoding: JSONEncoding.default)
            .responseJSON{

                response in switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    
                    let result = json["response"]
                    if(result["status"] == false){
                        print(result["message"])
                        completion(nil,result["message"].stringValue)
                        return
                    }
                    
                    let courseJSON = json["course"]
                    
                    let course = Course(
                            id : Int(courseJSON["id"].stringValue)!,
                            categoryId: courseJSON["categoryId"].stringValue == "" ? -1 : Int(courseJSON["categoryId"].stringValue)!,
                            detail: courseJSON["detail"].stringValue,
                            createdDate: courseJSON["createdDate"].stringValue == "" ? -1 : Float(courseJSON["createdDate"].stringValue)!,
                            key: courseJSON["key"].stringValue,
                            name : courseJSON["name"].stringValue,
                            owner: courseJSON["teacher"] != JSON.null ? "\(courseJSON["teacher"]["name"]) \(courseJSON["teacher"]["surname"])" : "",
                            img: "keyboard",
                            section : [],
                            rating: courseJSON["rating"].doubleValue
                        )
                    
                    let sections = courseJSON["sectionList"].arrayValue.sorted()
                    
                    for section in sections{
                        let thisSection = Section_model(
                            id: section["sectionId"].intValue,
                            name: section["name"].stringValue,
                            rank: section["rank"].intValue,
                            subSection: [])
                        
                        let subSections = section["sub-section"].arrayValue.sorted()
                        
                        for sub in subSections{

                            
                            var type : fileType = .none
                            if (sub["contentType"].stringValue == "VIDEO"){
                                type = .video
                            }else{
                                type = .document
                            }
                            
                            let thisSub = SubSection(id: sub["sectionId"].intValue, name: sub["name"].stringValue, fileKEY: sub["content"].stringValue, rank: section["rank"].intValue , type : type)
                            
                            thisSection.subSection?.append(thisSub)
                            
                            
                            
                        }
                        course.section?.append(thisSection)
                    }
                    
                    completion(course,nil)
                case .failure(let error):
                    print(error)
//                    completion(course)
                    completion(nil,error.localizedDescription)
                    }
                }
        }
    
    
    
    
    class func getAllCourse(completion : @escaping ( _ courseList:[Course]? , _ errorMessage:String?) -> Void){
        Alamofire.request(Network.IP_Address_Master+"/course",method : .get , encoding: JSONEncoding.default)
        .responseJSON{
    
                response in switch response.result{
                    case .success(let value):
                        let json = JSON(value)
                        var course = [Course]()
                        
                        let result = json["response"]
                        if(result["status"] == false){
                            print(result["message"])
                            completion(nil,result["message"].stringValue)
                            return
                        }
                        
                        let courses = json["courses"]
    
                        for obj in courses{
                            
                            let this_course = obj.1
//                            var catId = this_course["categoryId"].stringValue == "" ? -1 : Int(this_course["categoryId"].stringValue)
                            course.append(Course(
                                id : Int(this_course["id"].stringValue)!,
                                categoryId: this_course["categoryId"].stringValue == "" ? -1 : Int(this_course["categoryId"].stringValue)!,
                                detail: this_course["detail"].stringValue,
                                createdDate: this_course["createdDate"].stringValue == "" ? -1 : Float(this_course["createdDate"].stringValue)!,
                                key: this_course["key"].stringValue,
                                name : this_course["name"].stringValue,
                                owner: this_course["teacher"] != JSON.null ? "\(this_course["teacher"]["name"]) \(this_course["teacher"]["surname"])" : "",
                                img: "keyboard",
                                rating: this_course["rating"].doubleValue
                            ))
                        }
                    
                    completion(course,nil)
                    
                    
//                        let array = json[0]["name"].rawString()
                case .failure(let error):
                    print(error)
                    var course = [Course]()
                    course.append(Course(
                        id : 0,
                        categoryId: 0,
                        detail: "",
                        createdDate: 0,
                        key: "",
                        name : "error",
                        owner: "",
                        img: "java",
                        rating: 0.0
                    ))
//                    completion(course)
                    completion(nil,error.localizedDescription)
                    
//                        self.alert(text : "ERROR CODE : 500 (sever error) : \(error)")
                }
            }
    }
    
    class func getMyCourse(completion : @escaping ( _ courseList : [Course]? , _ errorMessage:String?) -> Void){
        var course = [Course]()
        
        Alamofire.request(Network.IP_Address_Master+"/course?studentId=\(AppDelegate.userData?.idmember ?? 0)",method: .get,encoding: JSONEncoding.default).responseJSON{
            response in switch response.result{
            case .success(let value):
                let json = JSON(value)
                let result = json["response"]
                if(result["status"] == false){
                    print(result["message"])
                    completion(nil,result["message"].stringValue)
                    return
                }
                
                let courses = json["courses"]
                for obj in courses{
                    let this_course = obj.1
                    course.append(Course(
                        id : Int(this_course["id"].stringValue)!,
                        categoryId: this_course["categoryId"] == JSON.null ? -1 : this_course["categoryId"].intValue,
                        detail: this_course["detail"].stringValue,
                        createdDate: this_course["createdDate"] == JSON.null ? 0.0 : this_course["createdDate"].floatValue ,
                        key: this_course["key"].stringValue,
                        name : this_course["name"].stringValue,
                        owner: this_course["teacher"] != JSON.null ? "\(this_course["teacher"]["name"]) \(this_course["teacher"]["surname"])" : "",
                        img: "java",
                        rating: this_course["rating"].doubleValue
                    ))
                }
                completion(course,nil)
            case .failure(let error):
                completion(nil,error.localizedDescription)
                print(error)
            }
            
        }
        
    }
    
    class func getCourseByCourseId(courseID : Int, completion : @escaping (_ Course:Course? , _ errorMessage:String?) -> Void){
        
        Alamofire.request(Network.IP_Address_Master+"/course?courseId=\(courseID)",method : .get, encoding: JSONEncoding.default)
            .responseJSON{
                
                response in switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    
                    let result = json["response"]
                    if(result["status"] == false){
                        print(result["message"])
                        completion(nil,result["message"].stringValue)
                        return
                    }
                    
                    let this_course = json["course"]
                    
                    print(this_course)
                    completion(Course(
                        id : Int(this_course["id"].stringValue)!,
                        categoryId: Int(this_course["categoryId"].stringValue)!,
                        detail: this_course["detail"].stringValue,
                        createdDate: Float(this_course["createdDate"].stringValue)!,
                        key: this_course["key"].stringValue,
                        name : this_course["name"].stringValue,
                        owner: this_course["teacher"] != JSON.null ? "\(this_course["teacher"]["name"]) \(this_course["teacher"]["surname"])" : "",
                        img: "java",
                        rating: this_course["rating"].doubleValue
                    ),nil)
                case .failure(let error):
                    completion(nil,error.localizedDescription)
                    print(error)
                    
                }
        }
            
    }
    
    class func getCourseByCourseIdList(courseID : [Int], completion : @escaping (_ courseList:[Course]?,_ errorMessage:String?) -> Void){
        var course = [Course]()
        let coursesParameters = courseID.map{String($0)}.joined(separator: ",")
        Alamofire.request(Network.IP_Address_Master+"/course?courseId=\(coursesParameters)",method : .get, encoding: JSONEncoding.default)
            .responseJSON{
                
                response in switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    
                    let result = json["response"]
                    if(result["status"] == false){
                        print(result["message"])
                        completion(nil,result["message"].stringValue)
                        return
                    }
                    
                    let courses = json["courses"]
                    
                    for obj in courses{
                        let this_course = obj.1
                        course.append(Course(
                            id : Int(this_course["id"].stringValue)!,
                            categoryId: this_course["categoryId"] == JSON.null ? -1 : this_course["categoryId"].intValue ,
                            detail: this_course["detail"].stringValue,
                            createdDate: Float(this_course["createdDate"] != JSON.null ? this_course["createdDate"].stringValue : "0")!,
                            key: this_course["key"].stringValue,
                            name : this_course["name"].stringValue,
                            owner: this_course["teacher"] != JSON.null ? "\(this_course["teacher"]["name"]) \(this_course["teacher"]["surname"])" : "",
                            img: "java",
                            rating: this_course["rating"].doubleValue
                        ))
                    }
                    
                    completion(course,nil)
                case .failure(let error):
                    completion(nil,error.localizedDescription)
                    print(error)
                    
                }
        }
        
    }
    
    class func getCourseBySearchName(courseName:String, completion : @escaping (_ courseList:[Course]?, _ errorMessage:String?) -> Void){
        var course = [Course]()
        
        if(courseName == ""){
            return
        }
        
        Alamofire.request(Network.IP_Address_Master+"/course?name=\(courseName)",method: .get,encoding: JSONEncoding.default).responseJSON{
            response in switch response.result{
            case .success(let value):
                let json = JSON(value)
                let result = json["response"]
                if(result["status"] == false){
                    print(result["message"])
                    completion(nil,result["message"].stringValue)
                    return
                }
                
                let courses = json["courses"]
                
                for obj in courses{
                    let this_course = obj.1
                    course.append(Course(
                        id : Int(this_course["id"].stringValue)!,
                        categoryId: this_course["categoryId"] == JSON.null ? -1 : this_course["categoryId"].intValue ,
                        detail: this_course["detail"].stringValue,
                        createdDate: Float(this_course["createdDate"] != JSON.null ? this_course["createdDate"].stringValue : "0")!,
                        key: this_course["key"].stringValue,
                        name : this_course["name"].stringValue,
                        owner: this_course["teacher"] != JSON.null ? "\(this_course["teacher"]["name"]) \(this_course["teacher"]["surname"])" : "",
                        img: "java",
                        rating: this_course["rating"].doubleValue
                    ))
                }
                completion(course,nil)
            case .failure(let error):
                completion(nil,error.localizedDescription)
                print(error)
            }
        }
    }
    
    class func getCourseBySearchInstructor(instructorName:String, completion : @escaping (_ courseList:[Course]?, _ errorMessage:String?)-> Void){
        var course = [Course]()
        let url = "\(Network.IP_Address_Master)/course?teacherName=\(instructorName)"
        if(instructorName == ""){
            return
        }
        Alamofire.request(url,method: .get,encoding: JSONEncoding.default).responseJSON{
            response in switch response.result{
            case.success(let value):
                let json = JSON(value)
                
                let result = json["response"]
                if(result["status"] == false){
                    print(result["message"])
                    completion(nil,result["message"].stringValue)
                    return
                }
                
                let courses = json["courses"]
                for obj in courses{
                    let this_course = obj.1
                    course.append(Course(
                        id : Int(this_course["id"].stringValue)!,
                        categoryId: this_course["categoryId"] == JSON.null ? -1 : this_course["categoryId"].intValue,
                        detail: this_course["detail"].stringValue,
                        createdDate: Float(this_course["createdDate"] != JSON.null ? this_course["createdDate"].stringValue : "0")!,
                        key: this_course["key"].stringValue,
                        name : this_course["name"].stringValue,
                        owner: this_course["teacher"] != JSON.null ? "\(this_course["teacher"]["name"]) \(this_course["teacher"]["surname"])" : "",
                        img: "java",
                        rating: this_course["rating"].doubleValue
                    ))
                }
                completion(course,nil)
            case.failure(let error):
                completion(nil,error.localizedDescription)
                print(error)
            }
        }
        
    }
    
    class func getfile(key : String, completion : @escaping (_ filePath : String? , _ errorMessage:String?) -> Void){
        let url = "\(Network.IP_Address_Course)/api/app?id=\(key)"
        let headers: HTTPHeaders = [
            "token": "key999",
        ]
        
        Alamofire.request(url ,method: .get ,encoding: JSONEncoding.default, headers : headers).responseString{
            response in switch response.result{
            case.success(let value):

                completion(value,nil)
            case.failure(let error):
                
                completion(nil,error.localizedDescription)
                print(error)
            }
        }
    }
    
    class func rateCourse(CourseId : Int, memberId : Int, rating : Double, completion : @escaping ( _ result : Bool)-> Void){
        
        let url = "\(Network.IP_Address_Master)/course/addRating?courseId=\(CourseId)&memberId=\(memberId)"
        
        let parameters: Parameters = [
            "rating" : rating
        ]
        
        Alamofire.request(url ,method: .post ,parameters : parameters,encoding: JSONEncoding.default).responseJSON{
            response in switch response.result{
            case.success(let value):
                let json = JSON(value)
                print(json)
                completion(true)
            case.failure(let error):
                completion(false)
                print(error)
            }
        completion(false)
        }
    }
}

