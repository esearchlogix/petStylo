//
//  SideMenuTable.swift
//  VistarApp
//
//  Created by thinksysuser on 06/12/16.
//  Copyright © 2016 thinksysuser. All rights reserved.
//

import UIKit
import CoreData

class SideMenuTable: UIView,UITableViewDataSource,UITableViewDelegate {
    var controller : HomeViewController? = HomeViewController()
    var menuTable = UITableView()
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        menuTable = UITableView(frame: CGRect(x:-20,y:0,width:self.frame.size.width,height:screenheight-64 ), style: .grouped)

        menuTable.register(UITableViewCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
        menuTable.separatorStyle = .none
       
        self.addSubview(menuTable)
        // here we are adding tableview on a subview
        menuTable.backgroundColor = UIColor.darkGray
        menuTable.delegate = self
        menuTable.dataSource = self
        self.addSubview(menuTable)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
            return 0
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
 
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = UIColor.init(red: 247.0/255.0, green:166.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return sideMenuDataSection1.count
        }else if section == 1{
            return sideMenuDataSection2.count
        }
        else{
          return sideMenuDataSection3.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath)
        tableCell.backgroundColor = UIColor.darkGray
        tableCell.subviews.forEach({$0.removeFromSuperview()})
        
        let labelForTableItems = UILabel.init(frame: CGRect(x:40,y:7,width:tableCell.frame.size.width,height:30))
        labelForTableItems.textAlignment = .left
        labelForTableItems.textColor = UIColor.white
        labelForTableItems.font = UIFont.init(name: appFont, size: 17)
        if indexPath.section == 0{
        labelForTableItems.text = sideMenuDataSection1.object(at: indexPath.item) as? String
        }else if indexPath.section == 1{
            labelForTableItems.text = sideMenuDataSection2.object(at: indexPath.item) as? String

        }else{
            labelForTableItems.text = sideMenuDataSection3.object(at: indexPath.item) as? String

        }
        
        tableCell.addSubview(labelForTableItems)
        // labelForTableItems.sizeToFit()
        //  if tableView.numberOfRows(inSection: 0) == 11
        // {

        
        
        
        return tableCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController: mainViewController)
        window?.rootViewController = navigationController
        if indexPath.section == 0{
        switch indexPath.row {
            
        case 0:
           // controller?.navigationController?.popToRootViewController(animated: true)
            navigationController.popToRootViewController(animated: true)
            
        case 1:
            let destinationViewController = SubCategoryViewController(nibName: "SubCategoryViewController", bundle: nil)
            destinationViewController.viewTitle = arrayCategoryName.object(at: 0) as? String
            destinationViewController.sections = dogSections
            navigationController.pushViewController(destinationViewController, animated: true)
   
        case 2:
            let destinationViewController = SubCategoryViewController(nibName: "SubCategoryViewController", bundle: nil)
            destinationViewController.viewTitle = arrayCategoryName.object(at: 1) as? String
            destinationViewController.sections = catSections
            navigationController.pushViewController(destinationViewController, animated: true)
            
        case 3:
            let destinationViewController = SubCategoryViewController(nibName: "SubCategoryViewController", bundle: nil)
            destinationViewController.viewTitle = arrayCategoryName.object(at: 2) as? String
            destinationViewController.sections = fishSections
            navigationController.pushViewController(destinationViewController, animated: true)

        case 4:
            let destinationViewController = SubCategoryViewController(nibName: "SubCategoryViewController", bundle: nil)
            destinationViewController.viewTitle = arrayCategoryName.object(at: 3) as? String
            destinationViewController.sections = birdSections
            navigationController.pushViewController(destinationViewController, animated: true)

        case 5:
            let isLogIn = UserDefaults.standard.bool(forKey: keyIsLogIN)
            if isLogIn == true{
                let tokenActiveDate = UserDefaults.standard.object(forKey: keyValidDateToken) as! Date
                if tokenActiveDate > Date(){
                    let destinationViewController = OrderHistoryViewController(nibName: "OrderHistoryViewController", bundle: nil)
                    navigationController.pushViewController(destinationViewController, animated: true)
                    
                }else{
                    let destinationViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
                    UserDefaults.standard.set("", forKey: keyToken)
                    UserDefaults.standard.set("", forKey: keyValidDateToken)
                    UserDefaults.standard.set(false, forKey: keyIsLogIN)
                    ModalViewController.showAlert(alertTitle: "Session Expire", andMessage: "Your session is Expire,Please LogIn Again", withController: destinationViewController)
                    
                    navigationController.pushViewController(destinationViewController, animated: true)
                    
                }
                
            }else{
                let destinationViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
                navigationController.pushViewController(destinationViewController, animated: true)
                
            }
            
            
        case 6:
            let destinationViewController = CartViewController(nibName: "CartViewController", bundle: nil)
            navigationController.pushViewController(destinationViewController, animated: true)

        case 7:
            let isLogIn = UserDefaults.standard.bool(forKey: keyIsLogIN)
            if isLogIn == true{
                let tokenActiveDate = UserDefaults.standard.object(forKey: keyValidDateToken) as! Date
                if tokenActiveDate > Date(){
                    let destinationViewController = AddressViewController(nibName: "AddressViewController", bundle: nil)
                    navigationController.pushViewController(destinationViewController, animated: true)
                    
                }else{
                    let destinationViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
                    UserDefaults.standard.set("", forKey: keyToken)
                    UserDefaults.standard.set("", forKey: keyValidDateToken)
                    UserDefaults.standard.set(false, forKey: keyIsLogIN)
                    ModalViewController.showAlert(alertTitle: "Session Expire", andMessage: "Your session is Expire,Please LogIn Again", withController: destinationViewController)
                    
                    navigationController.pushViewController(destinationViewController, animated: true)
                    
                }
                
            }else{
                let destinationViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
                navigationController.pushViewController(destinationViewController, animated: true)
                
            }
        case 8:
            let destinationViewController = NotificationViewController(nibName: "NotificationViewController", bundle: nil)
            navigationController.pushViewController(destinationViewController, animated: true)
            

        default:
            print("")
        }
        }
        else if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                // controller?.navigationController?.popToRootViewController(animated: true)
                Utility.SocialPromotionAction(urlString: keyRefundPolicyURL)

            case 1:
                Utility.SocialPromotionAction(urlString: keyTermsURL)

                
            case 2:
                Utility.SocialPromotionAction(urlString: keyPrivacyPolicyURL)

                
 
                
            default:
                print("")
            }
            
        }else if indexPath.section == 2 {
            let isLogIn = UserDefaults.standard.bool(forKey: keyIsLogIN)
            if isLogIn == true{
                let tokenActiveDate = UserDefaults.standard.object(forKey: keyValidDateToken) as! Date
                if tokenActiveDate > Date(){
                    Utility.clearAllData()
                    
                    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                    
                    do {
                        try context.execute(deleteRequest)
                        try context.save()
                        navigationController.popToRootViewController(animated: true)
                    } catch {
                        print ("There was an error")
                    }
                    
                }else{
                    let destinationViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
                    UserDefaults.standard.set("", forKey: keyToken)
                    UserDefaults.standard.set("", forKey: keyValidDateToken)
                    UserDefaults.standard.set(false, forKey: keyIsLogIN)
                    ModalViewController.showAlert(alertTitle: "Session Expire", andMessage: "Your session is Expire,Please LogIn Again", withController: destinationViewController)
                    
                    navigationController.pushViewController(destinationViewController, animated: true)
                    
                }
                
            }else{
                let destinationViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
                navigationController.pushViewController(destinationViewController, animated: true)
                
            }
            
        }
        
    }
    
 
    
}
