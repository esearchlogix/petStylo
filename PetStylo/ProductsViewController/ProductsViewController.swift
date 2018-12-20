//
//  ProductsViewController.swift
//  Ribbons
//
//  Created by Alekh Verma on 28/06/18.
//  Copyright © 2018 Alekh Verma. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData

var allArray : NSMutableArray? = []
class ProductsViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    @IBOutlet var noProductLabel : UILabel?
    @IBOutlet var filterButton : UIButton?
    @IBOutlet var tfSorting : UITextField?
    @IBOutlet var productsCollectionView : UICollectionView?
    
    
    

    var productsArray : NSMutableArray? = []
    var isSearch : Bool?
    var searchString : String?
    var viewTitle : String? 
    var isFilter : Bool?
    var collectionID : Int?
    var isRequest :  Bool?
    var isGrid : Bool? = true
    var tblView :  UITableView? = UITableView()
    var productSearchArray : NSArray? = []
    var arraySize :  NSMutableArray? = []
    var arrayColour : NSMutableArray = []
    var dictAllColourFilter : [String : NSMutableArray?] = [String : NSMutableArray?]()
     var dictAllSizeFilter : [String : NSMutableArray?] = [String : NSMutableArray?]()
  
   
    override func viewDidLoad() {
        
      //Set navigation Bar
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            self.methodToSetNavigationBarWithoutLogoImage(title: viewTitle ?? kAppName, badgeNumber: result.count)
        }catch{
            print("failed")
            self.methodToSetNavigationBarWithoutLogoImage(title: viewTitle ?? kAppName, badgeNumber: 0)

        }
       

        self.methodNavigationBarBackGroundColor()
    

        if isRequest == true{
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            let ObjServer = Server()
            ObjServer.delegate = self
            ObjServer.hitGetRequest(url: ProductsUrl + "\(collectionID ?? 0)", inputIsJson: false, parametresJsonDic:nil, parametresJsonArray: nil,callingViewController:nil, completion: {_,_,_ in })
        }else{
          
            if isSearch == true{
                DispatchQueue.main.async {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                }
                let ObjServer = Server()
                ObjServer.delegate = self
                ObjServer.hitGetRequest(url: ProductsSearchUrl + "\(self.searchString ?? "")", inputIsJson: false, parametresJsonDic:nil, parametresJsonArray: nil,callingViewController:nil, completion: {_,_,_ in })
            }else{
          productSearchArray = productsArray
            if isFilter != true{
            var itemCount :  Int = 0
            for item in productsArray! {
                let dict : NSDictionary? = item as? NSDictionary
                var dictTobeChange : [String:Any] = productsArray?.object(at: itemCount)  as! [String : Any]
                dictTobeChange["price"] = ((dict?.object(forKey: "variants") as? NSArray)?.object(at: 0) as? NSDictionary)?.object(forKey: "price") as? Int
                productsArray![itemCount] = dictTobeChange
//                let tagString : String = (dict?.object(forKey: "tags") as? String)!
//                let tagArr = tagString.components(separatedBy: ", ")
//                for value in tagArr{
//                    let tagArray = value.components(separatedBy: "_")
//                    if tagArray.contains("Color"){
//                        arrayColour.add(tagArray[1])
//                        if let arrayColor = dictAllColourFilter[tagArray[1]] {
//
//                            arrayColor?.add(dictTobeChange)
//                            dictAllColourFilter[tagArray[1]] = arrayColor
//                            // println(x)
//
//                        } else {
//                            let arrayColor : NSMutableArray? = []
//                            arrayColor?.add(dictTobeChange)
//                            dictAllColourFilter[tagArray[1]] = arrayColor
//                            // println("key is not present in dict")
//                        }
//
//                    }else if tagArray.contains("size"){
//                        arraySize?.add(tagArray[1])
//
//                        if let sizeArray = dictAllSizeFilter[tagArray[1]] {
//
//                            sizeArray?.add(dictTobeChange)
//                            dictAllSizeFilter[tagArray[1]] = sizeArray
//                            // println(x)
//
//                        } else {
//                            let sizeArray : NSMutableArray? = []
//                            sizeArray?.add(dictTobeChange)
//                            dictAllSizeFilter[tagArray[1]] = sizeArray
//                            // println("key is not present in dict")
//                        }
//                    }
//                }


                itemCount = itemCount + 1
            }

//            let setColour = NSSet(array: arrayColour as! [Any])
//            arrayColour =  NSMutableArray(array: setColour.allObjects)
//            let setSize = NSSet(array: arraySize as! [Any])
//            arraySize = NSMutableArray(array: setSize.allObjects)

            productSearchArray = productsArray
             allArray = productsArray
            }
        }
        
    }
        
       productsCollectionView?.register(UINib(nibName: "ProductsListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "productsCell")
        // textField padding
        let arrow = UIImageView(image: UIImage(named: "bottamArrow"))
        if let size = arrow.image?.size {
            arrow.frame = CGRect(x: 0.0, y: 8.0, width: 34.0, height: 34.0)
        }
        arrow.contentMode = UIViewContentMode.center
        tfSorting?.rightView = arrow
        tfSorting?.rightViewMode = UITextFieldViewMode.always
        
        
       
        Utility.giveBorderToView(view: tfSorting!, colour: .gray)
        Utility.giveBorderToView(view: tfSorting!, colour: .black)
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @objc func clickFilterView(touch: UITouch) {
        let destinationViewController = FilterViewController(nibName: "FilterViewController", bundle: nil)
        destinationViewController.colorFilter = arrayColour
        destinationViewController.sizeFilter = arraySize
        destinationViewController.dictAllProductForColour = dictAllColourFilter
        destinationViewController.dictAllProductForSize = dictAllSizeFilter
        if isFilter == true{
            
        }else{
            destinationViewController.allProductArray = productsArray
        }
       
        Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
    }
    
    // MARK: - recieve API data
    func didReceiveResponse(dataDic: NSDictionary?, response:URLResponse?) {
        let productArray : [Any] = dataDic?.object(forKey: "products") as! [Any]
        productsArray?.addObjects(from: productArray)
           productSearchArray = productArray as NSArray
        var itemCount :  Int = 0
        if productArray.count > 0{
             DispatchQueue.main.async {
            self.noProductLabel?.isHidden = true
            self.productsCollectionView?.isHidden = false
            }
        for item in productsArray! {
            let dict : NSDictionary? = item as? NSDictionary
            var dictTobeChange : [String:Any] = productsArray?.object(at: itemCount)  as! [String : Any]
            dictTobeChange["price"] = (((dict?.object(forKey: "variants") as? NSArray)?.object(at: 0) as? NSDictionary)?.object(forKey: "price") as? NSString)?.floatValue
            productsArray![itemCount] = dictTobeChange
//            let tagString : String = (dict?.object(forKey: "tags") as? String)!
//            let tagArr = tagString.components(separatedBy: ", ")
//            for value in tagArr{
//             let tagArray = value.components(separatedBy: "_")
//                if tagArray.contains("Color"){
//                    arrayColour.add(tagArray[1])
//                    if let arrayColor = dictAllColourFilter[tagArray[1]] {
//
//                        arrayColor?.add(dictTobeChange)
//                            dictAllColourFilter[tagArray[1]] = arrayColor
//                           // println(x)
//
//                    } else {
//                        let arrayColor : NSMutableArray? = []
//                        arrayColor?.add(dictTobeChange)
//                        dictAllColourFilter[tagArray[1]] = arrayColor
//                       // println("key is not present in dict")
//                    }
//
//                }else if tagArray.contains("size"){
//                    arraySize?.add(tagArray[1])
//
//                    if let sizeArray = dictAllSizeFilter[tagArray[1]] {
//
//                        sizeArray?.add(dictTobeChange)
//                        dictAllSizeFilter[tagArray[1]] = sizeArray
//                        // println(x)
//
//                    } else {
//                        let sizeArray : NSMutableArray? = []
//                        sizeArray?.add(dictTobeChange)
//                        dictAllSizeFilter[tagArray[1]] = sizeArray
//                        // println("key is not present in dict")
//                    }
//                }
//            }


            itemCount = itemCount + 1
        }
    
//        let setColour = NSSet(array: arrayColour as! [Any])
//        arrayColour =  NSMutableArray(array: setColour.allObjects)
//        let setSize = NSSet(array: arraySize as! [Any])
//        arraySize = NSMutableArray(array: setSize.allObjects)
       
        productSearchArray = productsArray
        allArray = productsArray
                DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                self.productsCollectionView?.reloadData()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
            }
        }else{
             DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)

                self.noProductLabel?.isHidden = false
          self.productsCollectionView?.isHidden = true
            }
        }
        }
    

   func didFailWithError(error: String) {
    
    let alertController = UIAlertController(title:kAppName, message:error , preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
        if self.productSearchArray?.count == 0{
        self.navigationController?.popViewController(animated: true)
        }
        
    })
    
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion: nil)

}

    //#MARK:- UITextField Dlegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfSorting{
            maketableView(textField: textField)
            return false
        }else{
     
            return true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
     
        removeTableView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
     
        return true
    }

    
     // MARK: - method for remove tableView
    func removeTableView(){

        tblView?.removeFromSuperview()
        tblView = UITableView()

    }
    
     // MARK: - make table View
    func maketableView(textField : UITextField){
      
        tblView?.frame = CGRect(x: (textField.frame.origin.x), y: textField.frame.origin.y + textField.frame.size.height + 2, width: (textField.frame.size.width), height: 250)
        tblView?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tblView?.backgroundColor = UIColor.init(red: 247.0/255.0, green:166.0/255.0, blue: 28.0/255.0, alpha: 1.0)

        if textField == tfSorting{
            tblView?.tag = 2
        }else{
        tblView?.tag = 1
        }
        tblView?.dataSource = self
        tblView?.delegate = self
        
        self.view.addSubview(tblView!)
        
    }
    
    // MARK: - tableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 2{
            return sortingArray.count
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 2{
            let cell = tblView?.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell?.textLabel?.text = sortingArray.object(at: indexPath.row) as? String
            cell?.textLabel?.font = UIFont(name: appFont, size: 15.0)
            cell?.textLabel?.textColor = UIColor.darkGray
            
            Utility.giveBorderToView(view: cell!, colour: .black)
         cell?.backgroundColor = UIColor.white
            return cell!
            
        }else{
            let cell = tblView?.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell?.textLabel?.text = sortingArray.object(at: indexPath.row) as? String
            
            return cell!
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if tableView.tag == 2{
            tfSorting?.text = cell?.textLabel?.text
            
            if indexPath.row == 0{
                productSearchArray = productsArray
            }
            else if indexPath.row == 1{
                let brandDescriptor : NSSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
                let  sortDescriptors = [brandDescriptor]
                productSearchArray = productSearchArray!.sortedArray(using: sortDescriptors) as NSArray
                }
            else if indexPath.row == 2{

                let brandDescriptor : NSSortDescriptor = NSSortDescriptor(key: "title", ascending: false)
                let  sortDescriptors = [brandDescriptor]
                productSearchArray = productSearchArray!.sortedArray(using: sortDescriptors) as NSArray
            }else if indexPath.row == 3{
                let brandDescriptor : NSSortDescriptor = NSSortDescriptor(key: "price", ascending: true)
                let  sortDescriptors = [brandDescriptor]
                productSearchArray = productSearchArray!.sortedArray(using: sortDescriptors) as NSArray
            }else{
                let brandDescriptor : NSSortDescriptor = NSSortDescriptor(key: "price", ascending: false )
                let  sortDescriptors = [brandDescriptor]
                productSearchArray = productSearchArray!.sortedArray(using: sortDescriptors) as NSArray
            }
         productsCollectionView?.reloadData()
        }
        
        removeTableView()
}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
// MARK: - Collection View Delegate
extension ProductsViewController {
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        
  
        return productSearchArray!.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        
        return 30
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10,10,100,10)
        
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
      
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productsCell", for: indexPath) as? ProductsListCollectionViewCell
            
            let imageStr = ((productSearchArray?.object(at: indexPath.item) as? NSDictionary)?.object(forKey: "image") as? NSDictionary)?.object(forKey: "src")
            cell?.productimage?.sd_setImage(with: URL(string: imageStr as! String ))
            
            cell?.productName?.text = (productSearchArray?.object(at: indexPath.item) as? NSDictionary)?.object(forKey: "title") as? String
            cell?.productRate?.text = ((((productSearchArray?.object(at: indexPath.item ) as? NSDictionary)?.object(forKey: "variants") as? NSArray)?.object(at: 0) as? NSDictionary)?.object(forKey: "price") as? String)! + "$"
            let count = (((productSearchArray?.object(at: indexPath.item ) as? NSDictionary)?.object(forKey: "variants") as? NSArray)?.object(at: 0) as? NSDictionary)?.object(forKey: "inventory_quantity") as? Int
       
        if count! < 1 {
            cell?.productAvailableLabel?.text = "SOLD OUT"
            cell?.productAvailableLabel?.backgroundColor = UIColor.init(red: 197.0/255.0, green: 19.0/255.0, blue: 43.0/255.0, alpha: 1)
        }else{
            cell?.productAvailableLabel?.text = "SALE"
            cell?.productAvailableLabel?.backgroundColor = UIColor.init(red: 65.0/255.0, green: 117.0/255.0, blue: 8.0/255.0, alpha: 1)
        }
            
        cell?.productShadowView?.layer.borderColor = UIColor.lightGray.cgColor
        
        Utility.giveShadowEffectToView(view: (cell?.productShadowView)!)
            return cell!

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
     
            return  CGSize(width: (screenWidth-40)/3, height: 203)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destinationViewController = ProductDetailViewController(nibName: "ProductDetailViewController", bundle: nil)
        destinationViewController.productDetailDict = productSearchArray?.object(at: indexPath.item) as? NSDictionary
        Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
    }
    
    
}

