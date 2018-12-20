//
//  ShipmentViewController.swift
//  Ribbons
//
//  Created by Alekh Verma on 26/07/18.
//  Copyright © 2018 Alekh Verma. All rights reserved.
//

import UIKit
import MBProgressHUD
import  CoreData

class ShipmentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,YourCellDelegate{
    @IBOutlet var labelForAddress : UILabel?
    @IBOutlet var labelForAddressCity : UILabel?
    @IBOutlet var labelForAddressName : UILabel?
    @IBOutlet var labelForAddressCountry : UILabel?
    @IBOutlet var labelForAddressPhone : UILabel?
    @IBOutlet var labelTotal : UILabel?
    @IBOutlet var tableViewShipment : UITableView?
    @IBOutlet var shipmentErrorLabel : UILabel?
    @IBOutlet var viewAddress : UIView?
    var totalCartPrice : Float?
    var shippingPrice : Decimal?
    var stringCheckoutID : String?
    var checkoutViewShipment : CheckoutViewModel?
    var shippingRateArray : [ShippingRateViewModel]?
    var shippingServiceName : NSArray? = ["Flat rate Shipping 5-10 business days","FexEx Express Saver","FexEx 2 days","FexEx Standard Overnight"]
    var shippingRate : NSArray? = [6.95,10.10,15.20,20.05]
    var selectedShipping : NSMutableArray? = [true,false,false,false]
    var cartItemArray : [Any]?
    var defaultAddressDict : NSDictionary = [:]
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
        self.methodToSetBottamNavigationBar(title: "SHIPPING DETAIL")
        self.methodNavigationBarBackGroundColor()
        
       
        
        tableViewShipment?.register(UINib(nibName: "ShippingRateTableViewCell", bundle: nil), forCellReuseIdentifier: "shipmentCell")


        // Do any additional setup after loading the view.
    }
    override  func viewWillAppear(_ animated: Bool) {
          MBProgressHUD.showAdded(to: self.view, animated: true)
        
  
        Utility.giveDoubleBorderToView(view: viewAddress!, colour: UIColor.white)
        
        let customerID = UserDefaults.standard.object(forKey: keyCustomerID) as? String
        let ObjServer = Server()
        ObjServer.delegate = self
        ObjServer.hitGetRequest(url:  fetchCustomerDetail + "\(customerID ?? "000000").json", inputIsJson: false, parametresJsonDic:nil, parametresJsonArray: nil,callingViewController:nil, completion: {_,_,_ in })
    }

    // MARK: - recieve API data
    func didReceiveResponse(dataDic: NSDictionary?, response:URLResponse?) {
         DispatchQueue.main.async {
         MBProgressHUD.hide(for: self.view, animated: true)
        }
       let arrayRespose : NSDictionary? = dataDic?.object(forKey: "customer") as? NSDictionary
        
        if let val = arrayRespose!["default_address"] {
            defaultAddressDict = arrayRespose?.object(forKey: "default_address") as! NSDictionary

            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                let address1 = (self.defaultAddressDict.object(forKey: "address1") as? String) ?? ""
                let address2 = "," + (self.defaultAddressDict.object(forKey: "address2") as? String ?? "")
                let address3 = "," + (self.defaultAddressDict.object(forKey: "city") as? String ?? "" )
                let address4 = "," + (self.defaultAddressDict.object(forKey: "province") as? String ?? "" )
                let address5 = "," + (self.defaultAddressDict.object(forKey: "zip") as? String ?? "" )
                let address6 = "," + (self.defaultAddressDict.object(forKey: "country") as? String ?? "" )
                
                self.labelForAddress?.text = address1 + address2 + address3 + address4 +  address5 + address6
                self.labelForAddressName?.text = "\(self.defaultAddressDict.object(forKey: "name") ?? "")"
                self.labelForAddress?.text = (self.defaultAddressDict.object(forKey: "address1") as? String) ?? "" + "," + "\((self.defaultAddressDict.object(forKey: "address2") ?? ""))"
               self.labelForAddressCity?.text = (self.defaultAddressDict.object(forKey: "city") as? String) ?? "" + "," + "\((self.defaultAddressDict.object(forKey: "province") ?? ""))"
                self.labelForAddressCountry?.text = (self.defaultAddressDict.object(forKey: "zip") as? String) ?? "" +  "," + "\((self.defaultAddressDict.object(forKey: "country") ?? ""))"
                self.labelForAddressPhone?.text = (self.defaultAddressDict.object(forKey: "phone") as? String) ?? ""
                self.labelTotal?.text = "Price : $ \(self.totalCartPrice ?? 0.00)"
                Client.shared.updateCheckout(self.stringCheckoutID ?? "0000", updatingCompleteShippingAddress: self.defaultAddressDict, activeViewController: self) { updatedCheckout in
                        guard let _ = updatedCheckout else {
                            
             
                    MBProgressHUD.hide(for: self.view, animated: true)
               
                            return
                        }
                        
                    Client.shared.fetchShippingRatesForCheckout((updatedCheckout?.id) ?? "", activeViewController: self) { result in
                        if let result = result {
                            self.shippingRateArray = result.rates
                            if self.shippingRateArray?.count == 0{
                                MBProgressHUD.hide(for: self.view, animated: true)
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title:kAppName, message:"shipping Rates  not available for this address" , preferredStyle: .alert)
                                    let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
                                        self.shipmentErrorLabel?.isHidden = false
                                        self.tableViewShipment?.isHidden = true
                                    })
                                    
                                    alertController.addAction(OKAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }else{
                                self.shipmentErrorLabel?.isHidden = true
                                self.tableViewShipment?.isHidden = false
                              MBProgressHUD.hide(for: self.view, animated: true)
                            self.tableViewShipment?.reloadData()
                           
                            print("Fetched shipping rates.")
                            }
                            Client.shared.updateCheckout((updatedCheckout?.id) ?? "", updatingEmail: (arrayRespose?.object(forKey: "email") as? String) ?? "", activeViewController: self)  { updatedCheckout in
                           
                            }

                            
                        } else {
                            print("Failed shipping rates.")
                             MBProgressHUD.hide(for: self.view, animated: true)
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title:kAppName, message:"Failed to dispatch shipping rate try after some time" , preferredStyle: .alert)
                                let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
                                  self.navigationController?.popViewController(animated: true)
                                })
                                
                                alertController.addAction(OKAction)
                                self.present(alertController, animated: true, completion: nil)
                        }
                    }
               
            }
            }
        }
        }else{
            DispatchQueue.main.async {
            let alertController = UIAlertController(title:kAppName, message:"We are not able to find any default address for you please add default address" , preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
                let destinationViewController = AddAddressViewController(nibName: "AddAddressViewController", bundle: nil)
                Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
            })
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    func didFailWithError(error: String) {
    
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)

        let alertController = UIAlertController(title:kAppName, message:error , preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
            self.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - tableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return (shippingRateArray?.count) ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return 1
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewShipment?.dequeueReusableCell(withIdentifier: "shipmentCell", for: indexPath) as! ShippingRateTableViewCell
       
        
        cell.shippingServiceName?.text = shippingRateArray?[indexPath.section].title ?? ""
        cell.ShippingServicePrice?.text = "$ \(shippingRateArray?[indexPath.section].price ?? 0.00)"
        
        
     
      cell.shippingServiceSelectButton?.isUserInteractionEnabled = true
        cell.shippingServiceSelectButton?.tag =  indexPath.section
        if selectedShipping?.object(at: indexPath.section) as? Bool == true{
            shippingPrice = shippingRateArray?[indexPath.section].price ?? 0.00
        cell.shippingServiceSelectButton?.image = #imageLiteral(resourceName: "selectMode")
        }else{
            cell.shippingServiceSelectButton?.image = #imageLiteral(resourceName: "unSelectedMode")

        }
       
        cell.cellDelegate = self
        
      
        
        Utility.giveDoubleBorderToView(view: cell.contentView, colour: UIColor.white)
        return cell
        
        
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var headerView : UIView?
        headerView?.backgroundColor = UIColor.white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var index = 0
        for value in selectedShipping!{
            if index == indexPath.section{
                selectedShipping?[index] = true
            }else{
                selectedShipping?[index] = false
            }
            index = index + 1
        }
        tableViewShipment?.reloadData()
    }
    
  // MARK: - Code for apply code
    func promptForDiscountCode(completion: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "Do you have a discount code?", message: "Any valid discount code can be applied to your checkout.", preferredStyle: .alert)
        alert.addTextField { textField in
            
            textField.attributedPlaceholder = NSAttributedString(string: "Discount code")
            textField.resignFirstResponder()
        }
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            completion(nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Yes, apply code", style: .cancel, handler: { [unowned alert] action in
            let code = alert.textFields!.first!.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let code = code, code.count > 0 {
                completion(code)
            } else {
                completion(nil)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    func didPressButton(_ tag: Int) {
       
        
    }

    @IBAction func changeButtonClick(sender: UIButton){
        let destinationViewController = AddAddressViewController(nibName: "AddAddressViewController", bundle: nil)
         destinationViewController.isShipment = true
        Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
    }
    @IBAction func continueButton(sender: UIButton){
        let index = selectedShipping?.index(of: true)
        if shippingRateArray == nil{
           if Utility.isInternetAvailable(){
            self.viewWillAppear(true)
            
            }else{
                ModalViewController.showAlert(alertTitle: kAppName, andMessage: kMessageNoInternetError, withController: self)
            }
        }else{
        
          MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if shippingRateArray?.count == 0{
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            self.promptForDiscountCode { discountCode in
                if let discountCode = discountCode {
                    DispatchQueue.main.async {
                        MBProgressHUD.showAdded(to: self.view, animated: true)
                    }
                    Client.shared.applyDiscount(discountCode, to: self.stringCheckoutID ?? "0000", activeViewController : self)  { checkout in
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        if let checkout = checkout {
                            let destinationViewController = PaymentViewController(nibName: "PaymentViewController", bundle: nil)
                            destinationViewController.paymentCheckoutView = checkout
                            self.navigationController?.pushViewController(destinationViewController, animated: true)
                        } else {
                            ModalViewController.showAlert(alertTitle: kAppName, andMessage: "Failed to apply Code", withController: self)
                        }
                    }
                    DispatchQueue.main.async {
                         MBProgressHUD.hide(for: self.view, animated: true)                    }
                } else {
                
                    let destinationViewController = PaymentViewController(nibName: "PaymentViewController", bundle: nil)
                    destinationViewController.paymentCheckoutView = self.checkoutViewShipment
                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                    
                }
            }
        }else{
        Client.shared.updateCheckout(stringCheckoutID ?? "0000", updatingShippingRate: (shippingRateArray?[index!].handle) ?? "", activeViewController: self){ updatedCheckout in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
          let shippingRate = updatedCheckout?.shippingRate
            if let val = shippingRate {
                self.promptForDiscountCode { discountCode in
                    if let discountCode = discountCode {
                         DispatchQueue.main.async {
                        MBProgressHUD.showAdded(to: self.view, animated: true)
                        }
                        Client.shared.applyDiscount(discountCode, to: (updatedCheckout?.id) ?? "0000", activeViewController: self) { checkout in
                            DispatchQueue.main.async {
                                MBProgressHUD.hide(for: self.view, animated: true)
                            }
                            if let checkout = checkout {
                                let destinationViewController = PaymentViewController(nibName: "PaymentViewController", bundle: nil)
                                destinationViewController.paymentCheckoutView = checkout
                                self.navigationController?.pushViewController(destinationViewController, animated: true)
                            } else {
                               ModalViewController.showAlert(alertTitle: kAppName, andMessage: "Failed to apply Code", withController: self)
                            }
                        }
                        DispatchQueue.main.async {
                               MBProgressHUD.hide(for: self.view, animated: true)                        }
                    } else {
                       
                        let destinationViewController = PaymentViewController(nibName: "PaymentViewController", bundle: nil)
                        destinationViewController.paymentCheckoutView = updatedCheckout
                        self.navigationController?.pushViewController(destinationViewController, animated: true)

                    }
                }
            }
            self.viewWillAppear(true)

          
        }
        }
        }
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
