 //
//  HomeViewController.swift
//  Ribbons
//
//  Created by Alekh Verma on 18/06/18.
//  Copyright © 2018 Alekh Verma. All rights reserved.
//

import UIKit
import AACarousel
import MBProgressHUD
import SDWebImage
import CoreData
import ImageSlideshow


var featuredProductArray : NSArray? = []

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate{

    

    var  localSource = [ImageSource(imageString: "SlideImage1"),ImageSource(imageString: "SlideImage2"), ImageSource(imageString: "SlideImage3")]
    @IBOutlet var textFieldSearch : UITextField?
    @IBOutlet var superViewSearch : UIView?
    @IBOutlet var slideshow: ImageSlideshow?
    @IBOutlet var scrollViewHome : UIScrollView?
    @IBOutlet var collectionViewCategory : UICollectionView?
    @IBOutlet var collectionViewFeatured : UICollectionView?
    @IBOutlet var featuredSuperView : UIView?
     @IBOutlet var buttonShowAll : UIButton?
    @IBOutlet var imageContact : UIImageView?
    @IBOutlet var categoryTitle : UILabel?
    @IBOutlet var featuredProductTitle : UILabel?
    var tableViewSearch :  UITableView? = UITableView()
    var arraySearch : NSArray?
   
    override func viewDidLoad() {
     
        let ObjServer = Server()
        ObjServer.delegate = self
        ObjServer.hitGetRequest(url: featuredProductUrl, inputIsJson: false, parametresJsonDic:nil, parametresJsonArray: nil,callingViewController:self, completion: {_,_,_ in })
        
        print(imageContact?.bounds)
        print(imageContact?.frame)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
        self.methodToSetSideMenuButtonInNavigationBar(title: "deepanshu",badgeNumber: result.count)
        }catch{
            print("failed")
        }
       self.methodNavigationBarBackGroundColor()
        Utility.giveShadowEffectToView(view: superViewSearch!)
        Utility.giveShadowEffectToView(view: imageContact!)
        slideShow()
  
// code for scroll view
        scrollViewHome?.contentSize = CGSize(width: self.view.frame.size.width, height: 800)
        scrollViewHome?.contentInset=UIEdgeInsetsMake(64.0,0.0,50.0,0.0);
        scrollViewHome?.isExclusiveTouch = false
        scrollViewHome?.delaysContentTouches = false
        
  // code for collection view
   
        collectionViewCategory?.delegate = self
        collectionViewCategory?.showsVerticalScrollIndicator = true
        collectionViewCategory?.dataSource = self
        collectionViewCategory?.register(UINib(nibName: "CategoriesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "categoryCollectionCell")
      
            collectionViewCategory?.reloadData()
    
     
        
        buttonShowAll?.addTarget(self, action: #selector(self.viewAllfeaturedProductAction), for: .touchUpInside)
        collectionViewFeatured?.delegate = self
        collectionViewFeatured?.dataSource = self
        collectionViewFeatured?.register(UINib(nibName: "FeaturedProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "featuredImageCell")
   // code for image view contact Action
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageContact?.isUserInteractionEnabled = true
        imageContact?.addGestureRecognizer(tapGestureRecognizer)
       
        
  
   // code for underline text
        let text = categoryTitle?.text
        let attributedString = NSMutableAttributedString(string: text!, attributes: [NSAttributedStringKey.underlineStyle : true])
        categoryTitle?.attributedText = attributedString
        
        let textFeatured = featuredProductTitle?.text
        let attributedStringFeatured = NSMutableAttributedString(string: textFeatured!, attributes: [NSAttributedStringKey.underlineStyle : true])
        featuredProductTitle?.attributedText = attributedStringFeatured
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
     tableViewSearch?.frame = CGRect(x: (textFieldSearch?.frame.origin.x) ?? 0, y: ((textFieldSearch?.frame.maxY) ?? 0 ) , width: (textFieldSearch?.frame.size.width) ?? 350, height: (tableViewSearch?.contentSize.height) ?? 550)
        tableViewSearch?.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        if (featuredProductArray?.count) ?? 0 > 0{
            collectionViewFeatured?.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        textFieldSearch?.text = ""
        textFieldSearch?.resignFirstResponder()
        arraySearch = arrayAllProducts
        tableViewSearch?.removeFromSuperview()
        tableViewSearch = UITableView()
    }
    
 // MARK: - Slider show
    func slideShow() {
        // code for slider
        slideshow?.slideshowInterval = 5.0
        slideshow?.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow?.contentScaleMode = UIViewContentMode.scaleAspectFill
      //  264310100005127
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        slideshow?.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow?.currentPageChanged = { page in
            print("current page:", page)
        }
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow?.setImageInputs(localSource as! [InputSource])
    }
    
// MARK: - recieve API data
    func didReceiveResponse(dataDic: NSDictionary?, response:URLResponse?) {
        
        featuredProductArray = dataDic?.object(forKey: "products") as? NSArray
        DispatchQueue.main.async {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
            self.collectionViewFeatured?.reloadData()
         MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    func didFailWithError(error: String) {
         
        let alertController = UIAlertController(title:kAppName, message:error , preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
               })
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   // MARK: - Make tableView
    
    func maketableView(textField : UITextField){
        
        
        tableViewSearch?.frame = CGRect(x: (textFieldSearch?.frame.origin.x)!, y: (textFieldSearch?.frame.maxY) ?? 0, width: (textFieldSearch?.frame.size.width)!, height: (tableViewSearch?.contentSize.height)!)
         tableViewSearch?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableViewSearch?.tag = 1
        tableViewSearch?.dataSource = self
        tableViewSearch?.delegate = self
        
        self.view.addSubview(tableViewSearch!)
        
        
    }
    
// MARK: - tableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        
            return 1
   
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
         return UITableViewAutomaticDimension
    
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
   
            return (arraySearch?.count) ?? 0
       
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
            let cell = tableViewSearch?.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell?.textLabel?.text = (arraySearch?.object(at: indexPath.row) as? NSDictionary)?.object(forKey: "title") as? String
            cell?.textLabel?.lineBreakMode = .byWordWrapping
            cell?.textLabel?.numberOfLines = 0;
            cell?.textLabel?.font = UIFont.init(name: appFont, size: 12.0)
            return cell!
            
     
        
    }

    
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
        let destinationViewController = ProductDetailViewController(nibName: "ProductDetailViewController", bundle: nil)
            destinationViewController.productDetailDict = arraySearch?.object(at: indexPath.row) as? NSDictionary
        Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)

    }

    
 // MARK: - textfieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        arraySearch =  arrayAllProducts
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        arraySearch = arrayAllProducts
        tableViewSearch?.removeFromSuperview()
        tableViewSearch = UITableView()
    }

    //#MARK:- UITextField Dlegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        textFieldSearch?.clearButtonMode = .whileEditing
        textFieldSearch?.autocorrectionType = .no
        textFieldSearch?.autocapitalizationType = .none
        
//        doSearching = true
        
        let newString:NSString? =   (textField.text as NSString?)?.replacingCharacters(in:range , with: string) as NSString?
        
        let trimstring = newString?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        let namepredicate:NSPredicate = NSPredicate(format: "(title BEGINSWITH[c] %@) OR (title CONTAINS[c] %@)", trimstring ?? "" , " \(trimstring ?? "")")
        
        let resultArray = arrayAllProducts?.filtered(using: namepredicate)
        
        self.arraySearch = resultArray as NSArray?
        if (textField.text?.count) ?? 0 > 4 {
           maketableView(textField: textField)
        }else{
            tableViewSearch?.removeFromSuperview()
            tableViewSearch = UITableView()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        arraySearch = arrayAllProducts
        tableViewSearch?.removeFromSuperview()
        arraySearch = nil
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        textFieldSearch?.text = ""
        arraySearch = arrayAllProducts
        tableViewSearch?.removeFromSuperview()
        arraySearch = nil
        return true
    }
    
    
    
 // MARK: - button Action
    
 
    override func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let url = URL(string: "tel://500500500"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
     // button Action for social promotion
    @IBAction func socialPromotionAction(sender: UIButton){
        switch sender.tag {
        case 11:
            Utility.SocialPromotionAction(urlString: keyfacbookURL)
        case 22:
            Utility.SocialPromotionAction(urlString: keyGooglURL)
        case 33:
            Utility.SocialPromotionAction(urlString: keyInstagramURL)
        case 44:
            Utility.SocialPromotionAction(urlString: keyPinterestURL)
        default:
            Utility.SocialPromotionAction(urlString: keyTwitterkURL)
        }
    }
    // action for search button
    
    @IBAction func searchButtonAction(sender : UIButton){
        if textFieldSearch?.text == ""{
       textFieldSearch?.becomeFirstResponder()
        }else{
            let destinationViewController = ProductsViewController(nibName: "ProductsViewController", bundle: nil)
            destinationViewController.productsArray = []
            destinationViewController.searchString = textFieldSearch?.text
            destinationViewController.isSearch = true
            destinationViewController.viewTitle = textFieldSearch?.text

            destinationViewController.isRequest = false
            selectedIndexPaths = []
            arraySelectedIndexPath = []
            productArray = []
            Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
        }
        
        
    }
    
    @objc func viewAllfeaturedProductAction(sender : UIButton){
   
            let destinationViewController = ProductsViewController(nibName: "ProductsViewController", bundle: nil)
        destinationViewController.productsArray = []
        destinationViewController.productsArray?.addObjects(from: (featuredProductArray as? [Any]) ?? [])
        destinationViewController.viewTitle = "Featured products"

            destinationViewController.isRequest = false
        selectedIndexPaths = []
        arraySelectedIndexPath = []
        productArray = []
            Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
    }
}
// MARK: - Collection View Delegate
extension HomeViewController {
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
     
        
        if collectionView.tag == 103{
            return 4
        }else if collectionView.tag == 102{
            if  (featuredProductArray?.count) ?? 0 > 0{
                if (featuredProductArray?.count) ?? 0 > 8{
                  return 8
                }else{
                    return (featuredProductArray?.count) ?? 0
                }
            
            }else{
                return 0
            }
        }
        return arraySlideOfferImages.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       
           
        
        if collectionView.tag == 103{
            return UIEdgeInsetsMake(10,10,10,10)
        }
            return UIEdgeInsetsMake(0,10,0,10)
        
    }

    //3
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collCell : UICollectionViewCell? = UICollectionViewCell()
        if collectionView.tag == 102{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredImageCell", for: indexPath) as? FeaturedProductCollectionViewCell
            
            let imageStr = ((featuredProductArray?.object(at: indexPath.item) as? NSDictionary)?.object(forKey: "image") as? NSDictionary)?.object(forKey: "src")
            cell?.productImage?.sd_setImage(with: URL(string: (imageStr as? String) ?? "" ))

            //cell?.productImage?.image = UIImage(named: imageStr as! String)
            cell?.productName?.text = (featuredProductArray?.object(at: indexPath.item ) as? NSDictionary)?.object(forKey: "title") as? String
            Utility.giveShadowEffectToView(view: (cell?.productImage)!)

          
            return cell!
            
            
        }else if collectionView.tag == 103 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCollectionCell", for: indexPath) as? CategoriesCollectionViewCell
            let imageStr = arrayCategoryImages[indexPath.item]
            
        
            cell?.categoryImage?.image = UIImage(named: (imageStr as? String) ?? "dogImage")
            cell?.categoryName?.text = arrayCategoryName.object(at: indexPath.row) as? String
            Utility.giveShadowEffectToView(view: (cell?.categoryImageSuperView)!)
            
            
            
            return cell!
            
        }
        return collCell!
        }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 102{
           return  CGSize(width: 120, height: 150)
        }else{
            if indexPath.item == 4 || indexPath.item == 5 {
                return  CGSize(width: (screenWidth-20), height: 200)

            }
            return  CGSize(width: (screenWidth-30)/2, height: 200)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         if collectionView.tag == 102
        {
        let destinationViewController = ProductDetailViewController(nibName: "ProductDetailViewController", bundle: nil)
        destinationViewController.productDetailDict = featuredProductArray?.object(at: indexPath.item ) as? NSDictionary
        Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
           
        }
        else if collectionView.tag == 103
        {
            switch indexPath.row {
                
                case 0:
                let destinationViewController = SubCategoryViewController(nibName: "SubCategoryViewController", bundle: nil)
                destinationViewController.viewTitle = arrayCategoryName.object(at: 0) as? String
                destinationViewController.sections = dogSections
                Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
                
                case 1:
                    let destinationViewController = SubCategoryViewController(nibName: "SubCategoryViewController", bundle: nil)
                    destinationViewController.viewTitle = arrayCategoryName.object(at: 1) as? String
                    destinationViewController.sections = catSections
                Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
                
                case 2:
                    let destinationViewController = SubCategoryViewController(nibName: "SubCategoryViewController", bundle: nil)
                    destinationViewController.viewTitle = arrayCategoryName.object(at: 2) as? String
                    destinationViewController.sections = fishSections
                    Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
                
                case 3:
                    let destinationViewController = SubCategoryViewController(nibName: "SubCategoryViewController", bundle: nil)
                    destinationViewController.viewTitle = arrayCategoryName.object(at: 3) as? String
                    destinationViewController.sections = birdSections
                    Utility.pushToViewController(callingViewController: self, moveToViewController: destinationViewController)
                
                case 4:
                    
                    let destinationViewController = ProductsViewController(nibName: "ProductsViewController", bundle: nil)
                    destinationViewController.productsArray = []
                    destinationViewController.viewTitle = "MEN"
                    destinationViewController.collectionID = 437717007
                    destinationViewController.isRequest = true
                    selectedIndexPaths = []
                    arraySelectedIndexPath = []
                    productArray = []
                    self.navigationController?.pushViewController(destinationViewController, animated: true)
                
                case 5:
                
                   let destinationViewController = ProductsViewController(nibName: "ProductsViewController", bundle: nil)
                   destinationViewController.productsArray = []
                   destinationViewController.viewTitle = "WOMEN"
                   destinationViewController.collectionID = 437717071
                   destinationViewController.isRequest = true
                   selectedIndexPaths = []
                   arraySelectedIndexPath = []
                   productArray = []
                   self.navigationController?.pushViewController(destinationViewController, animated: true)
                
                default:
                print("")
            }
        }
        
    }
    
    
}
