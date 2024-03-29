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
    
    
    
       
    //FLATS FILTER
    
    func flatsFilter(offset:Int,amount:Int, select:String , parameters: String, completionHandler: @escaping ([Flat])->Void){
        let realm = try! Realm()
        let per = realm.object(ofType: person.self, forPrimaryKey: 1)
        headers = ["Token":(per?.token)!]
        let fullRequest = domain + "/flats/filter?select=\(select)&offset=\(offset)&amount=\(amount)&parameters=\(parameters)"
        
        Alamofire.request(fullRequest, headers : headers).responseJSON { response in
            var flats = [Flat]()
            let jsondata = JSON(data:response.data!)
            let array = jsondata["flats"].array
            if (array?.count) != nil {
                for i in 0..<array!.count{
                    let flat = Flat()
                    flat.avatarImage = jsondata["flats"][i]["owner"]["avatar"].string!
                    flat.flatPrice = jsondata["flats"][i]["price"].string!
                    flat.subwayId = jsondata["flats"][i]["id_underground"].string!
                    let number_of_friends = (jsondata["flats"][i]["mutual_friends"].array?.count)!
                    flat.flatMutualFriends = "\(number_of_friends) общих друзей"
                    flat.flat_id = jsondata["flats"][i]["id"].string!
                    flat.imageOfFlat.append(jsondata["flats"][i]["photos"][0]["url"].string!)
                    flat.numberOfRoomsInFlat = jsondata["flats"][i]["rooms"].string!
                    flats.append(flat)
                }
            }
            completionHandler(flats)
            
        }
    }
    //MUTUAL FRIENDS
    func murualFriends(id:String, completionHandler: @escaping (_ js:JSON)->()){
        let realm = try! Realm()
        let per = realm.object(ofType: person.self, forPrimaryKey: 1)
        headers = ["Token":(per?.token)!]
        let fullRequest = domain + "/flats/single?id_flat=" + id
        Alamofire.request(fullRequest, headers : headers).responseJSON { response in
            var jsondata = JSON(data:response.data!)
            completionHandler(jsondata)
        }
    }
    
    func underground(id:String,completionHandler:@escaping (_ js:Any) ->()){
        let fullRequest = domain + "/underground?id_city=\(id)"
        Alamofire.request(fullRequest).responseJSON { response in
            let jsondata = JSON(data:response.data!)
            completionHandler(jsondata)
        }
    }
    
    
    
    //UNDERGROUND
    func update_subway(){
     
        let fullRequest = domain + "/underground"
        let subway = Subway()

        Alamofire.request(fullRequest).responseJSON { response in
            
            let jsondata = JSON(data:response.data!)
            if !jsondata.isEmpty{
                let stations_array = jsondata["stations"].array?.count
                for i in 0..<stations_array!{
                    let station = Station()
                    station.stationId = jsondata["stations"][i]["id"].string!
                    station.name = jsondata["stations"][i]["name"].string!
                    station.id_underground_line = jsondata["stations"][i]["id_underground_line"].string!
                    subway.subwayStations.append(station)
                }
                let lines_array = jsondata["lines"].array?.count
                for i in 0..<lines_array!{
                    let line = Line()
                    line.lineId = jsondata["lines"][i]["id"].string!
                    line.name = jsondata["lines"][i]["name"].string!
                    line.color = jsondata["lines"][i]["color"].string!
                    subway.subwayLines.append(line)
                }
                DispatchQueue(label: "background2").async {
                    autoreleasepool {
                        let realm = try! Realm()
                        try! realm.write {
                        let line = try! Realm().objects(Line)
                        let station = try! Realm().objects(Station)
                        realm.delete(line)
                        realm.delete(station)
                        realm.add(subway, update: true)
                        }
                    }
                }

            }
            
            
            
        }
        
    }
    
    
    
    //TOKEN CHECK
    func tokenCheck(token:String,completionHandler:@escaping (_ js:Int?) ->()){
        let fullRequest = domain + "/token"
        
        if token != ""{
            headers = ["Token" : token]
        } else {
            headers = ["Token" : ""]
        }
        Alamofire.request(fullRequest, headers: headers).responseJSON { response in
            let jsondata = (response.response?.statusCode)
            completionHandler(jsondata)
        }
        
    }
    
    func upload(photoData: [Data], parameters: [String : String], completionHandler:@escaping (_ js:Any) ->()){
        let realm = try! Realm()
        let per = realm.object(ofType: person.self, forPrimaryKey: 1)
        let fullRequest = domain + "/flats/single"
        let encoded = fullRequest.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        let myUrl = URL(string: encoded!)
        
        //headers = ["Token" : UserDefaults.standard.value(forKey: "Token") as! String]
        headers = ["Token":(per?.token)!]
        
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
    
    func flatSingle(id:String, completionHandler: @escaping (Flat)->Void){
        let fullRequest = domain + "/flats/single?id_flat=" + id
        let realm = try! Realm()
        let per = realm.object(ofType: person.self, forPrimaryKey: 1)
        headers = ["Token":(per?.token)!]
        Alamofire.request(fullRequest, headers : headers).responseJSON { response in
            
            var flat = Flat()
            var jsondata = JSON(data:response.data!)
            flat.avatarImage = jsondata["owner"]["avatar"].string ?? ""
            flat.flatPrice = jsondata["price"].string ?? "-"
            flat.subwayId = jsondata["id_underground"].string ?? "не указано"
            let number_of_friends = jsondata["mutual_friends"].array?.count ?? 0
            flat.flatMutualFriends = "\(number_of_friends)"
            flat.flat_id = jsondata["id"].string ?? "0"
            let photoArray:Int = (jsondata["photos"].array?.count)!
            for i in 0..<photoArray{
                flat.imageOfFlat.append(jsondata["photos"][i]["url"].string!)
            }
            flat.numberOfRoomsInFlat = jsondata["rooms"].string ?? "-"
            if let full = jsondata["update_date"].string{
            flat.time = full.substring(from:full.index(full.startIndex, offsetBy:11))
            flat.update_date = full.substring(to: full.index(full.startIndex, offsetBy:10))
            }
            flat.isFavourite = jsondata["is_favourite"].string ?? "0"
            flat.time_to_subway = jsondata["to_underground"].string ?? "-"
            flat.square = jsondata["square"].string ?? "-"
            flat.floor = jsondata["floor"].string ?? "-"
            flat.floors = jsondata["floors"].string ?? "-"
            flat.ownerName = jsondata["owner"]["first_name"].string ?? "Неопределен"
            flat.address = jsondata["address"].string ?? "Адрес не указан"
            flat.comments = jsondata["description"].string ?? "Описание не указано"
            flat.owner_id = jsondata["owner"]["id"].string ?? "Неопределен"
            let optionsCount = jsondata["options"].array?.count ?? 0
            for i in 0..<optionsCount{
                flat.options.append(jsondata["options"][i].string!)
            }
            
            completionHandler(flat)
        }
        
    }
    
    
    //OPTIONS
    /* func options(options:[String], completionHandler: @escaping ([(name:String,icon:String)])->Void){
        let fullRequest = domain + "/options"
        var returnArray = [(name:String,icon:String)]()
        Alamofire.request(fullRequest).responseJSON { response in
            let jsondata = JSON(data:response.data!)
            for option in options{
                for i in jsondata.array!{
                    if i["id"].string == option{
                        let ret = (name: i["name"].string,icon:i["icon"].string)
                    returnArray.append(ret as! (name: String, icon: String))
                    break
                    }
                }
            }
            completionHandler(returnArray)
        
        }
        
    }*/
    func updateOptions(){
        let fullRequest = domain + "/options"
        Alamofire.request(fullRequest).responseJSON { response in
            let options = Options()
            let jsondata = JSON(data:response.data!)
            print("OPTIONS:\(jsondata)")
            for i in jsondata.array!{
              let option = Option()
                option.id = i["id"].string
                option.name = i["name"].string
                let url = URL(string:i["icon"].string! )
                let data = try? Data(contentsOf: url!)
                let image = UIImage(data: data!)
                let imageFull = UIImagePNGRepresentation(image!) as NSData?
                option.image = imageFull
                options.options.append(option)
            }
            DispatchQueue(label: "background3").async {
                autoreleasepool {
                    let realm = try! Realm()
                    try! realm.write {
                        let option = try! Realm().objects(Option)
                        realm.delete(option)
                        realm.add(options, update: true)
                    }
                }
                
            }
        }
    }
    
    /////////////////////
    func favourite(id:String){
        let realm = try! Realm()
        let per = realm.object(ofType: person.self, forPrimaryKey: 1)
        headers = ["Token":(per?.token)!,"Content-Type":"application/x-www-form-urlencoded"]
        print(headers)
        let fullRequest = domain + "/flats/favourite"
        Alamofire.request(fullRequest, method: .put, parameters: ["id_flat":id],headers : headers).responseJSON { response in
        let jsondata = response.response?.statusCode
            print("STATUS CODE:\(jsondata)")
        }
    }
    
}
