//
//  AddressViewController.swift
//  Ribbons
//
//  Created by Alekh Verma on 31/07/18.
//  Copyright © 2018 Alekh Verma. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData

class AddressViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableVieeAddress : UITableView?
    @IBOutlet var emptyLabel : UILabel?
    @IBOutlet var totalAddressCount : UILabel?
    @IBOutlet var buttonAddAddress : UIButton?
    
    var fetchAddressArray : NSMutableArray? = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            self.methodToSetSideMenuButtonInNavigationBar(title: "deepanshu", badgeNumber: result.count)
        }catch{
            print("failed")
        }
        
        
        self.methodNavigationBarBackGroundColor()
        
        tableVieeAddress?.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: "addressCell")
        Utility.giveShadowEffectToView(view: buttonAddAddress!)
     
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let customerID = UserDefaults.standard.value(forKey: keyCustomerID)
        let ObjServer = Server()
        ObjServer.delegate = self
        ObjServer.hitGetRequest(url: "\(fetchCustomerDetail)\(customerID ?? 00000)\(addressUrl)", inputIsJson: false, parametresJsonDic:nil, parametresJsonArray: nil,callingViewController:self, completion: {_,_,_ in })
    }
    
    // MARK: - recieve API data
    func didReceiveResponse(dataDic: NSDictionary?, response:URLResponse?) {
        if let val = dataDic!["addresses"] {
            let arrayRespose : NSArray? = dataDic?.object(forKey: "addresses") as? NSArray
            fetchAddressArray = arrayRespose?.mutableCopy() as? NSMutableArray
            if (fetchAddressArray?.count) ?? 0 > 0{
                DispatchQueue.main.async {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    self.emptyLabel?.isHidden = true
                    self.tableVieeAddress?.isHidden = false
                    self.totalAddressCount?.text = "    \(self.fetchAddressArray?.count ?? 0) More Address"
                    self.tableVieeAddress?.reloadData()
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }else{
                DispatchQueue.main.async {
                    self.emptyLabel?.isHidden = false
                    self.tableVieeAddress?.isHidden = true
                }
            }
        }else{
            let customerID = UserDefaults.standard.value(forKey: keyCustomerID)
            let ObjServer = Server()
            ObjServer.delegate = self
            ObjServer.hitGetRequest(url: "\(fetchCustomerDetail)\(customerID ?? 00000)\(addressUrl)", inputIsJson: false, parametresJsonDic:nil, parametresJsonArray: nil,callingViewController:self, completion: {_,_,_ in })
        }
    }
    func didFailWithError(error: String) {
        
        let alertController = UIAlertController(title:kAppName, message:error , preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
            self.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    // MARK: - tableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return (fetchAddressArray?.count) ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return 1
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableVieeAddress?.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressTableViewCell
        let data = fetchAddressArray![indexPath.section] as? NSDictionary
        
        cell.name?.text = "\(data?.object(forKey: "name") ?? "")"
        cell.AddressLabel?.text = (data?.object(forKey: "address1") as? String) ?? "" + "," + "\((data?.object(forKey: "address2") ?? ""))"
        cell.AddressCity?.text = (data?.object(forKey: "city") as? String) ?? "" + "," + "\((data?.object(forKey: "province") ?? ""))"
        cell.AddressCountry?.text = (data?.object(forKey: "zip") as? String) ?? "" +  "," + "\((data?.object(forKey: "country") ?? ""))"
        cell.AddressMobile?.text = (data?.object(forKey: "phone") as? String) ?? ""
        
        
        if data?.object(forKey: "default") as? Bool == true{
            
            cell.defaultButton?.alpha = 0.5
            cell.defaultButton?.isUserInteractionEnabled = false
            
        }else{
            cell.defaultButton?.alpha = 1.0
            cell.defaultButton?.isUserInteractionEnabled = true
        }
        cell.defaultButton?.tag = 100 + indexPath.section
        cell.cancelButton?.tag = indexPath.section
        cell.defaultButton?.addTarget(self, action: #selector(self.defaultButtonClicked), for: .touchUpInside)
     
        
        
        
        cell.cancelButton?.addTarget(self, action: #selector(self.cancelButtonClicked), for: .touchUpInside)
        cell.selectionStyle = .none
        
        return cell
        
        
        
    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        var headerView : UIView?
//        let footerImage = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 10))
//        footerImage.image = #imageLiteral(resourceName: "shadowImage")
//        headerView?.addSubview(footerImage)
//        //headerView?.backgroundColor = UIColor(red: 244.0/255.0, green:243.0/255.0, blue: 244.0/255.0, alpha: 1.0)
//        return headerView
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 10
//    }
    
    
    // MARK: - button Action
    
    @objc func cancelButtonClicked(sender: UIButton!) {
        let alertController = UIAlertController(title:kAppName, message:"Are you sure to remove an address from the list?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "YES", style: .default, handler:{ action in
            let ObjServer = Server()
            let customerID = UserDefaults.standard.value(forKey: keyCustomerID)
            ObjServer.delegate = self
            ObjServer.hitDeleteRequest(url: "\(fetchCustomerDetail)\(customerID ?? 00000)/addresses/\(((self.fetchAddressArray?.object(at: sender.tag) as? NSDictionary)?.object(forKey: "id") as? Int) ?? 00000).json", inputIsJson: false, callingViewController: self, completion: {_,_,_ in })
        })
        let NoAction = UIAlertAction(title: "NO", style: .default, handler:{ action in
            
        })
        if  self.navigationController != nil || self.presentingViewController != nil{
            alertController.addAction(OKAction)
            alertController.addAction(NoAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    @objc func defaultButtonClicked(sender: UIButton!) {
        let alertController = UIAlertController(title:kAppName, message:"Are you sure you want to set this address as default address?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "YES", style: .default, handler:{ action in
            let ObjServer = Server()
            ObjServer.delegate = self
            let customerID = UserDefaults.standard.value(forKey: keyCustomerID)
            ObjServer.hitPutRequest(url: "\(fetchCustomerDetail)\(customerID ?? 00000)/addresses/\(((self.fetchAddressArray?.object(at: (sender.tag % 100)) as? NSDictionary)?.object(forKey: "id") as? Int) ?? 00000)/default.json", inputIsJson: false, callingViewController: self, completion: {_,_,_ in })
        })
        let NoAction = UIAlertAction(title: "NO", style: .default, handler:{ action in
            
        })
        if  self.navigationController != nil || self.presentingViewController != nil{
            alertController.addAction(OKAction)
            alertController.addAction(NoAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addAddress(sender : UIButton){
        let destinationViewController = AddAddressViewController(nibName: "AddAddressViewController", bundle: nil)
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
