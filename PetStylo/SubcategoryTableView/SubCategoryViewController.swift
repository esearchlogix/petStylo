//
//  SubCategoryViewController.swift
//  Ribbons
//
//  Created by Alekh Verma on 04/07/18.
//  Copyright © 2018 Alekh Verma. All rights reserved.
//

import UIKit
import CoreData

class SubCategoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ExpendableTableViewdelegate {
    
    @IBOutlet var tableViewExpend : UITableView?
    var viewTitle : String? 
    
    var selectIndexPath : IndexPath!

    var sections : [Section]?
    
    
    override func viewDidLoad() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            self.methodToSetSideMenuButtonInNavigationBarWithPopBack(badgeNumber: result.count)

        }catch{
            print("failed")
        }
        
        self.methodToSetBottamNavigationBar(title: viewTitle ?? kAppName)
        self.methodNavigationBarBackGroundColor()
        
        selectIndexPath = IndexPath(row: -1, section: -1)
        let nib = UINib(nibName: "SectionHeader", bundle: nil)
        tableViewExpend?.register(nib, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        tableViewExpend?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
       
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sections![section].subCategory?.count)!
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (sections![indexPath.section].expended)!{
            return 44
        }else{
            return 0
            
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableViewExpend?.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as? ExpendableTableView
        
        //        var header : ExpendableTableView?
        
        header?.customInit(title: sections![section].category!, section: section, delegate: self)
        Utility.giveShadowEffectToView(view: header!)
        return header
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        view.backgroundColor = UIColor.white
        return view
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewExpend?.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = sections![indexPath.section].subCategory?[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectIndexPath =  indexPath
        let destinationViewController = ProductsViewController(nibName: "ProductsViewController", bundle: nil)
        destinationViewController.productsArray = []
        destinationViewController.viewTitle = sections![indexPath.section].subCategory?[indexPath.row]
        destinationViewController.collectionID = sections![indexPath.section].Ids?[indexPath.row]
        destinationViewController.isRequest = true
        selectedIndexPaths = []
        arraySelectedIndexPath = []
        productArray = []
        self.navigationController?.pushViewController(destinationViewController, animated: true)
       
        
    }
    func toggleSection(header: ExpendableTableView, section: Int) {
        
        sections![section].expended = !sections![section].expended!
        
        tableViewExpend?.beginUpdates()
        tableViewExpend?.reloadSections([section], with: .automatic)
        tableViewExpend?.endUpdates()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
