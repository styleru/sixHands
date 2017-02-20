//
//  ListOfFlatsController.swift
//  sixHands
//
//  Created by Владимир Марков on 16.01.17.
//  Copyright © 2017 Владимир Марков. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class ListOfFlatsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
  let screenSize: CGRect = UIScreen.main.bounds
   
    var flats = [Flat]()
    typealias JSONStandard = [String : AnyObject]
    let refreshControl = UIRefreshControl()
    //let params = "%5B%7B%22key%22%3A%22id%22%2C%22value%22%3A%22307%22%2C%20%22criterion%22%3A%22single%22%7D%5D"
    var offsetInc = 2
    let amount = 2
    
    @IBOutlet weak var filterOutlet: UIButton!
    @IBOutlet weak var listOfFlats: UILabel!
    
    @IBOutlet weak var favouritesOutlet: UIButton!
    @IBOutlet weak var popularOutlet: UIButton!
    @IBOutlet weak var newOutlet: UIButton!
    @IBOutlet weak var listOfFlatsTableView: UITableView!
        
    
    override func viewDidLoad() {
        print(screenSize.width)
        print(screenSize.height)
        update(sorting: "last", parameters: "", amount: Int8(amount), offset: 0)
        
        //gray bar
        let grayBar = UIView()
        grayBar.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 20.0)
        grayBar.backgroundColor = UIColor.black
        grayBar.alpha = 0.37
        self.view.addSubview(grayBar)
        
        listOfFlatsTableView.delegate = self
        listOfFlatsTableView.dataSource = self
        listOfFlatsTableView.beginUpdates()
        listOfFlatsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        listOfFlatsTableView.endUpdates()
        
        
        //CONSTRAINTS:
        favouritesOutlet.bounds = CGRect(x: 0, y: 0, width: screenSize.width * 0.3  , height: screenSize.height * 0.0299 )
        favouritesOutlet.center = CGPoint(x: screenSize.width * 0.836 , y: screenSize.height * 0.16041)
        filterOutlet.bounds = CGRect(x:0, y:0 , width: screenSize.width * 0.0676, height: screenSize.width * 0.0676)
        filterOutlet.center = CGPoint(x: screenSize.width * 0.9, y: screenSize.height * 0.093)
        listOfFlatsTableView.rowHeight = screenSize.height * 0.4
        
        listOfFlats.bounds = CGRect(x:0, y:0 , width: screenSize.width * 0.8, height: screenSize.height * 0.096)
        listOfFlats.center = CGPoint(x: listOfFlats.bounds.width/2 + screenSize.width/2 - screenSize.width * 0.91466 / 2, y: screenSize.height * 0.089955)
        
        popularOutlet.center = CGPoint(x: screenSize.width * 0.448 , y: screenSize.height * 0.16041)
        newOutlet.center = CGPoint(x: screenSize.width * 0.11333 , y: screenSize.height * 0.16041)
        
        popularOutlet.bounds = CGRect(x: 0, y: 0, width: screenSize.width * 0.3, height: screenSize.height * 0.0299 )
        newOutlet.bounds = CGRect(x: 0, y: 0, width: screenSize.width * 0.141333, height: screenSize.height * 0.0299)
        
        listOfFlatsTableView.center = CGPoint(x: screenSize.width/2, y: screenSize.height * 0.564467)
        listOfFlatsTableView.bounds = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height * 0.70614)
        listOfFlatsTableView.separatorInset.left = 15.0
        listOfFlatsTableView.separatorInset.right = 15.0
        
        //pull
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.gray
        refreshControl.addTarget(self, action: #selector(ListOfFlatsController.refresh), for: UIControlEvents.valueChanged)
        self.listOfFlatsTableView?.addSubview(refreshControl)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refresh() {
        print("refresh...")
        flats = []
        update(sorting: "last", parameters: "", amount: Int8(amount), offset: 0)
        offsetInc = amount
        self.listOfFlatsTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == flats.count - 1 {
            print("reached the bottom cell")
            update(sorting: "last", parameters: "", amount: Int8(amount), offset: offsetInc)
            offsetInc += amount
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cell selected code here
        performSegue(withIdentifier:"singleFlat", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlatViewCell", for: indexPath) as! FlatViewCell
        
        
        //CONSTRAINTS
        cell.flatImage.bounds = CGRect(x: 0, y: 0.0, width: screenSize.width * 0.91466 , height: screenSize.height * 0.27436282 )
        cell.flatImage.center = CGPoint(x: cell.bounds.width / 2, y: cell.flatImage.frame.height/2 + 7.0)
        
        cell.mutualFriends.bounds = CGRect(x: 0, y: 0, width: screenSize.width * 0.3 , height: screenSize.height * 0.03)
        cell.mutualFriends.center = CGPoint(x:cell.flatImage.frame.minX+cell.mutualFriends.frame.width/2 + 4, y: cell.bounds.height-cell.mutualFriends.frame.height)
        
        cell.price.bounds = CGRect(x: 0, y: 0, width:screenSize.width * 0.25066 , height: screenSize.height * 0.05997)
        cell.price.center = CGPoint(x:cell.flatImage.frame.maxX-cell.price.frame.width/2, y:cell.flatImage.frame.height * 0.7)
        
        cell.subway.bounds = CGRect(x: 0, y: 0, width:screenSize.width * 0.3 , height: screenSize.height * 0.02698)
        cell.subway.center = CGPoint(x:cell.flatImage.frame.minX+cell.subway.frame.width/2 + 4, y: cell.flatImage.frame.maxY + cell.subway.frame.height )
        
        /* cell.dot.bounds = CGRect(x: 0, y: 0,width: 4, height: 4)
         cell.dot.center = CGPoint(x:cell.subway.frame.maxX+5, y: cell.flatImage.frame.maxY + cell.subway.frame.height )*/
        
        cell.numberOfRooms.bounds = CGRect(x: 0, y: 0, width:screenSize.width * 0.3, height: screenSize.height * 0.02698)
        cell.numberOfRooms.center = CGPoint(x:cell.subway.frame.maxX+10+cell.numberOfRooms.frame.width/2, y:cell.flatImage.frame.maxY + cell.subway.frame.height )
        
        
        //cell.dot.layer.cornerRadius = cell.dot.frame.size.width / 2
        cell.avatar.bounds = CGRect(x: 0, y: 0, width:screenSize.width * 0.11733 , height: screenSize.width * 0.11733)
        cell.avatar.center = CGPoint(x:cell.flatImage.frame.maxX-cell.avatar.frame.width/2 - 8,y:cell.bounds.height-(cell.bounds.height-cell.flatImage.frame.maxY)/2)
        cell.avatar.layer.masksToBounds = false
        cell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2
        cell.avatar.clipsToBounds = true
        cell.avatar.contentMode = .scaleAspectFill
        cell.flatImage.contentMode = .scaleAspectFill
        cell.flatImage.clipsToBounds = true
        //END OF CONSTRAINTS
        
        cell.subway.text = "м. Арбатская"
        cell.mutualFriends.text = "5 общих друзей"
        cell.numberOfRooms.text = "\(flats[indexPath.row].numberOfRoomsInFlat)-комн."
        cell.price.text = "\(flats[indexPath.row].flatPrice) ₽"
        cell.avatar.sd_setImage(with: URL(string : flats[indexPath.row].avatarImage))
        
        if flats[indexPath.row].imageOfFlat.isEmpty{
            cell.flatImage.image = #imageLiteral(resourceName: "no-thumb")
        }else {cell.flatImage.sd_setImage(with: URL(string : flats[indexPath.row].imageOfFlat[0]))}
        
        cell.flatImage.sd_setImage(with: URL(string : flats[indexPath.row].imageOfFlat[0]))
        
        
        return cell
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return flats.count
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "singleFlat"{
            let VC = segue.destination as! FlatViewController
            let indexPath = self.listOfFlatsTableView.indexPathForSelectedRow
            VC.flat_id = flats[(indexPath?.row)!].flat_id
        }
    }

    
    func update(sorting:String,parameters:String,amount:Int8,offset:Int) {
        
        Alamofire.request("http://6hands.styleru.net/flats/filter?select=\(sorting)&offset=\(offset)&amount=\(amount)&parameters=\(parameters)").responseJSON { response in
            var jsondata = JSON(data:response.data!)
            let array = jsondata.array
            print(jsondata)
            
            if (array?.count) != nil {
                for i in 0..<array!.count{
                    let flat = Flat()
                    flat.avatarImage = jsondata[i]["owner"]["avatar"].string!
                    flat.flatPrice = jsondata[i]["parameters"]["30"].string!
                    flat.flatSubway = "Пока нема"
                    flat.flatMutualFriends = "социопат"
                    flat.flat_id = jsondata[i]["id"].string!
                    let arrayOfPhotos = jsondata[i]["photos"].array
                    if arrayOfPhotos?.count != nil {
                        for j in 0..<arrayOfPhotos!.count {
                            flat.imageOfFlat.append(jsondata[i]["photos"][j]["url"].string!)
                        }
                    }

                    flat.numberOfRoomsInFlat = jsondata[i]["parameters"]["31"].string!
                    self.flats.append(flat)
                
                }
            }
            OperationQueue.main.addOperation({()-> Void in
                
                self.listOfFlatsTableView.reloadData()
                
            })
            
        //self.flats = self.parseData(JSONdata: response.data!)
        }
    }

    @IBAction func new(_ sender: UIButton) {
       flats = []
        newOutlet.alpha = 1
        favouritesOutlet.alpha = 0.2
        popularOutlet.alpha = 0.2
        update(sorting: "last", parameters: "", amount: Int8(amount), offset: 0)
    }
    @IBAction func popular(_ sender: UIButton) {
        flats = []
        update(sorting: "popular", parameters: "", amount: Int8(amount), offset: 0)
        newOutlet.alpha = 0.2
        favouritesOutlet.alpha = 0.2
        popularOutlet.alpha = 1
    }
    @IBAction func favourites(_ sender: UIButton) {
        
        newOutlet.alpha = 0.2
        flats = []
        favouritesOutlet.alpha = 1
        popularOutlet.alpha = 0.2
        update(sorting: "favourites", parameters: "", amount: Int8(amount), offset: 0)
    }

    @IBAction func filter(_ sender: UIButton) {
        //performSegue(withIdentifier: "", sender: self)
    }
     @IBAction func fromSingleFlat(segue: UIStoryboardSegue) {}
    
    
    
    
    
    

}




