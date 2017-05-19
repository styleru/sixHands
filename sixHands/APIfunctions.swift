//
//  APIfunctions.swift
//  sixHands
//
//  Created by Илья on 01.02.17.
//  Copyright © 2017 Владимир Марков. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class API{
    
    var headers:HTTPHeaders = HTTPHeaders()
    
    
    
   func flatsSingle(id:String,completionHandler:@escaping (_ js:Any) ->()){
        let fullRequest = domain + "/flats/single?id_flat=" + id
   
   
        Alamofire.request(fullRequest).responseJSON { response in
            let jsondata = JSON(data:response.data!)
            completionHandler(jsondata)
        }
    }
    
    //FLATS FILTER
    
    func flatsFilter(offset:Int,amount:Int, parameters: String, completionHandler: @escaping ([Flat])->Void){
        let realm = try! Realm()
        let per = realm.object(ofType: person.self, forPrimaryKey: 1)
        headers = ["Token":(per?.token)!]
        let fullRequest = domain + "/flats/filter?select=all&offset=\(offset)&amount=\(amount)\(parameters)"
        
        Alamofire.request(fullRequest, headers : headers).responseJSON { response in
            var flats = [Flat]()
            let jsondata = JSON(data:response.data!)
            let array = jsondata.array
            if (array?.count) != nil {
                for i in 0..<array!.count{
                    let flat = Flat()
                    flat.avatarImage = jsondata[i]["owner"]["avatar"].string!
                    flat.flatPrice = jsondata[i]["price"].string!
                    flat.flatSubway = "Пока нема"
                    let number_of_friends = (jsondata[i]["mutual_friends"].array?.count)!
                    flat.flatMutualFriends = "\(number_of_friends) общих друзей"
                    flat.flat_id = jsondata[i]["id"].string!
                    flat.imageOfFlat.append(jsondata[i]["photos"][0]["url"].string!)
                    flat.numberOfRoomsInFlat = jsondata[i]["rooms"].string!
                    flats.append(flat)
                }
            }
            completionHandler(flats)
            
        }
    }
    
    
    func underground(id:String,completionHandler:@escaping (_ js:Any) ->()){
        let fullRequest = domain + "/underground?id_city=\(id)"
        Alamofire.request(fullRequest).responseJSON { response in
            let jsondata = JSON(data:response.data!)
            completionHandler(jsondata)
        }
    }
    
    func tokenCheck(token:String,completionHandler:@escaping (_ js:Int) ->()){
        let fullRequest = domain + "/token"
        
        if token != ""{
            headers = ["Token" : token]
        } else {
            headers = ["Token" : ""]
        }
        Alamofire.request(fullRequest, headers: headers).responseJSON { response in
            let jsondata = (response.response?.statusCode)!
            completionHandler(jsondata)
        }

    }
    
    func upload(photoData: [Data], parameters: [String : String], completionHandler:@escaping (_ js:Any) ->()){
        let fullRequest = domain + "/flats/single"
        let encoded = fullRequest.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        let myUrl = URL(string: encoded!)
        
        headers = ["Token" : UserDefaults.standard.value(forKey: "Token") as! String]
        
        Alamofire.upload(multipartFormData: { (multipart) in
            
            for (key, value) in parameters {
                multipart.append(value.data(using: String.Encoding.utf8)!, withName: key)
                print("\(key) : \(value)")
            }
            
            var i = 0
            
            for data in photoData {
                multipart.append(data, withName: "photo\(i)", fileName: "photo\(i).jpg", mimeType: "image/jpeg")
                i += 1
            }
            
        }, to: myUrl!, method: .post, headers:headers, encodingCompletion: { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let request, _, _):
                request.response(completionHandler: { (response) in
                    print("kek: \(response.response!)")
                    let json = JSON(data: response.data!)
                    completionHandler(json)
                })
            }
        })
        
    }
    
    class func Single(id:String)->JSON{
        let fullRequest = domain + "/flats/single?id_flat=" + id
        var jsondata = JSON.null
        
        Alamofire.request(fullRequest).responseJSON { response in
            jsondata = JSON(data:response.data!)
        }
        
        return jsondata
    }
    
    
    func user(){
    }
    
}
