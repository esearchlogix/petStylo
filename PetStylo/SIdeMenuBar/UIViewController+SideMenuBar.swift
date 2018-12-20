//
//  UIViewController+SideMenuBar.swift
//  Ribbons
//
//  Created by Alekh Verma on 15/06/18.
//  Copyright © 2018 Alekh Verma. All rights reserved.
//

import UIKit

var overlayView:UIView! = UIView()
var containerView:UIView! = UIView()
var viewToBeMoved:UIView!
var isPress:Bool = false
var menuButton = UIButton()
var firstX:Float!
var firstY:Float!
var selectedvalue:String = ""
var objmenuTable = SideMenuTable()
var navigationBottamView : UIView? = UIView()


extension UIViewController{
    
    // #MARK: methodToSetButtonInNavigationBar
    
    
    // set side menu
    func methodToSetSideMenuButtonInNavigationBar(title :String,badgeNumber : Int){
        
        let homeButton = UIButton()
        homeButton.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        homeButton.frame = CGRect(x:0,y:0,width:47,height:47)
        homeButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        let navigateSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigateSpacer.width = 0
        
        
        let leftBarButton = UIBarButtonItem()
        // leftBarButton.style = .plain
        leftBarButton.customView = homeButton
        
        self.navigationItem.setLeftBarButtonItems([navigateSpacer,leftBarButton], animated: false)
        
        let titleImage = UIImageView(frame: CGRect(x: 0.0, y: 10.0, width: 100, height: 40))
        titleImage.image = #imageLiteral(resourceName: "logoImage")
       
        self.navigationItem.titleView = titleImage
        self.MethodToSetGesture()
     
        
        let accountButton = UIButton()
        accountButton.setImage(#imageLiteral(resourceName: "accountImage"), for: .normal)
        accountButton.frame = CGRect(x:0,y:0,width:30,height:30)
        accountButton.addTarget(self, action: #selector(self.methodAccountButton), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = accountButton
     
        
        let buttonCart = UIButton()
        buttonCart.setImage(#imageLiteral(resourceName: "cartImage"), for: .normal)
        buttonCart.frame = CGRect(x:0,y:0,width:30,height:30)
        buttonCart.addTarget(self, action: #selector(self.methodCartButton), for: .touchUpInside)
    
        let rightBarButton1 = UIBarButtonItem()
        rightBarButton1.customView = buttonCart
        rightBarButton1.addBadge(number: badgeNumber)
    

        self.navigationItem.setRightBarButtonItems([rightBarButton1,navigateSpacer,rightBarButton], animated: false)
        
    }
    
    func methodToSetSideMenuButtonInNavigationBarWithoutCart(){
        
        
        let backButton = UIButton()
        //   backButton.backgroundColor = .blue
        
        backButton.setImage(#imageLiteral(resourceName: "BackIcon"), for: .normal)
        backButton.frame = CGRect(x:2.0,y:0,width:40,height:30)
        backButton.addTarget(self, action: #selector(backButtonActionPop(sender:)), for: .touchUpInside)
        
        let containerView = UIView(frame: CGRect(x: 3.0, y: 0.0, width: 85, height: 47))
        containerView.addSubview(backButton)
        backButton.center.y = containerView.center.y
        
        let navigateSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigateSpacer.width = -16
        

        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = containerView
        
        self.navigationItem.setLeftBarButtonItems([navigateSpacer,leftBarButton], animated: false)
        
        let titleImage = UIImageView(frame: CGRect(x: 13.0, y: 40.0, width: 100, height: 40))
        titleImage.image = #imageLiteral(resourceName: "logoImage")
        self.navigationItem.titleView = titleImage
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        titleImage.isUserInteractionEnabled = true
        titleImage.addGestureRecognizer(tapGestureRecognizer)
        
        
        self.MethodToSetGesture()
        
      
        
    }
    func methodToSetBottamNavigationBar(title :String){
        
//        let navigationBottamView = UIView()
      
        
        let labelTitle = UILabel()
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            labelTitle.frame = CGRect(x:0,y: 0.0,width:screenWidth,height:60)
        }else{
        labelTitle.frame = CGRect(x:0,y:64,width:screenWidth,height:60)
        }
        
        labelTitle.backgroundColor = UIColor.black
        labelTitle.font = UIFont(name: labelTitle.font.fontName, size: 16)
        labelTitle.font = UIFont.boldSystemFont(ofSize: 16.0)
        labelTitle.textColor = UIColor.white
        labelTitle.text = title
        labelTitle.textAlignment = .center
        
        self.view.addSubview(labelTitle)
        
     
    }
    func methodToSetNavigationBarWithoutLogoImage(title :String , badgeNumber : Int){
        
        
        let backButton = UIButton()
        //   backButton.backgroundColor = .blue
        
        backButton.setImage(#imageLiteral(resourceName: "BackIcon"), for: .normal)
        backButton.frame = CGRect(x:2.0,y:0,width:40,height:30)
        backButton.addTarget(self, action: #selector(backButtonActionPop(sender:)), for: .touchUpInside)
        
        let containerView = UIView(frame: CGRect(x: 3.0, y: 0.0, width: 85, height: 47))
        containerView.addSubview(backButton)
        backButton.center.y = containerView.center.y
        let homeButton = UIButton()
        homeButton.frame = CGRect(x:42,y:0,width:47,height:47)
        homeButton.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        
        homeButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        let navigateSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigateSpacer.width = -16
        
        containerView.addSubview(homeButton)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = containerView
        
        self.navigationItem.setLeftBarButtonItems([navigateSpacer,leftBarButton], animated: false)
        
        let titleLabel = UILabel(frame: CGRect(x: 13.0, y: 40.0, width: 100, height: 40))
       titleLabel.text = title
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        self.navigationItem.titleView = titleLabel
      
  
        
        let accountButton = UIButton()
        accountButton.setImage(#imageLiteral(resourceName: "accountImage"), for: .normal)
        accountButton.frame = CGRect(x:0,y:0,width:30,height:30)
        accountButton.addTarget(self, action: #selector(self.methodAccountButton), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = accountButton
        
        let buttonCart = UIButton()
        buttonCart.setImage(#imageLiteral(resourceName: "cartImage"), for: .normal)
        buttonCart.frame = CGRect(x:0,y:0,width:30,height:30)
        buttonCart.addTarget(self, action: #selector(self.methodCartButton), for: .touchUpInside)
        
        let rightBarButton1 = UIBarButtonItem()
        rightBarButton1.customView = buttonCart
        rightBarButton1.addBadge(number: badgeNumber)
        
        self.navigationItem.setRightBarButtonItems([rightBarButton1,navigateSpacer,rightBarButton], animated: false)
        
        
    }
    //#MARK:- methodToSetSideMenuButtonInNavigationBarWithPopBack
    func methodToSetSideMenuButtonInNavigationBarWithPopBack(badgeNumber : Int){
        
        
        let backButton = UIButton()
        //   backButton.backgroundColor = .blue
        
        backButton.setImage(#imageLiteral(resourceName: "BackIcon"), for: .normal)
        backButton.frame = CGRect(x:2.0,y:0,width:40,height:30)
        backButton.addTarget(self, action: #selector(backButtonActionPop(sender:)), for: .touchUpInside)
      
        let containerView = UIView(frame: CGRect(x: 3.0, y: 0.0, width: 85, height: 47))
        containerView.addSubview(backButton)
        backButton.center.y = containerView.center.y
        let homeButton = UIButton()
        homeButton.frame = CGRect(x:42,y:0,width:47,height:47)
        homeButton.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        
        homeButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        let navigateSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigateSpacer.width = -16
     
        containerView.addSubview(homeButton)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = containerView
        
        self.navigationItem.setLeftBarButtonItems([navigateSpacer,leftBarButton], animated: false)
        
        let titleImage = UIImageView(frame: CGRect(x: 13.0, y: 40.0, width: 100, height: 40))
        titleImage.image = #imageLiteral(resourceName: "logoImage")
        self.navigationItem.titleView = titleImage
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        titleImage.isUserInteractionEnabled = true
        titleImage.addGestureRecognizer(tapGestureRecognizer)
        
        
        self.MethodToSetGesture()
        
        let accountButton = UIButton()
        accountButton.setImage(#imageLiteral(resourceName: "accountImage"), for: .normal)
        accountButton.frame = CGRect(x:0,y:0,width:30,height:30)
        accountButton.addTarget(self, action: #selector(self.methodAccountButton), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = accountButton
        
        let buttonCart = UIButton()
        buttonCart.setImage(#imageLiteral(resourceName: "cartImage"), for: .normal)
        buttonCart.frame = CGRect(x:0,y:0,width:30,height:30)
        buttonCart.addTarget(self, action: #selector(self.methodCartButton), for: .touchUpInside)
        
        let rightBarButton1 = UIBarButtonItem()
        rightBarButton1.customView = buttonCart
        rightBarButton1.addBadge(number: badgeNumber)
        
        self.navigationItem.setRightBarButtonItems([rightBarButton1,navigateSpacer,rightBarButton], animated: false)
        
        
    }
     //#MARK:- LogoImageAction
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    

    //#MARK:- menuButtonAction
    
    @objc func menuButtonAction(sender:UIButton?){
        
        if isPress == false{
            isPress = true
            overlayView = UIView.init()
            
            overlayView.frame = CGRect(x:-self.view.frame.size.width,y:0,width:self.view.frame.size.width-20,height:self.view.frame.size.height + 40)
            
           
            
            objmenuTable = SideMenuTable(frame: overlayView.bounds)
            self.view.addSubview(overlayView)
            self.view.bringSubview(toFront: overlayView)
            overlayView.addSubview(objmenuTable)
            
            self.view.insertSubview(overlayView, aboveSubview: navigationBottamView!)
            // Animate SideMenu
            UIView.animate(withDuration: 0.65, animations: {()-> Void in
                
                overlayView.frame = CGRect(x:0,y:0,width:self.view.frame.size.width-100,height:self.view.frame.size.height + 40)
                
            }, completion:{(finished) in
                
            })
        }else{
            
            isPress = false
            
            UIView.animate(withDuration: 0.8, animations: {()-> Void in
                
                overlayView.frame = CGRect(x:0,y:0,width:self.view.frame.size.width-100,height:self.view.frame.size.height + 0)
                
                
            }, completion: {(finished) in
                
                if finished{
                    overlayView.removeFromSuperview()
                    overlayView = nil
                    
                }
            })
        }
        
    }
    
        func MethodToSetGesture(){
            
            
        containerView = UIView.init(frame:CGRect(x:80-self.view.frame.size.width,y:0,width:self.view.frame.size.width-20,height:self.view.frame.size.height + 40) )
            
            

        self.view.addSubview(containerView)
       
            
                    firstX = 0
                    firstY = 0
            let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(hideSideMenu(touch:)))
            //   tapRecognizer.delegate = self
            tapRecognizer.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tapRecognizer)
           containerView.addGestureRecognizer(tapRecognizer)
    
            let panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(moveSideMenu(sender:)))
            panRecognizer.maximumNumberOfTouches = 1
            panRecognizer.minimumNumberOfTouches = 1
            containerView.addGestureRecognizer(panRecognizer)
    
        }
  
    //#MARK:- hideMenu
    func hideMenu( completion:(() -> Void)?) {
        
        let originX:CGFloat = containerView.center.x
        if originX > 0 {
            
            let threashold:CGFloat = containerView.frame.size.width/2
            let animationDuration: CGFloat = 0.4
            print("the duration is: \(animationDuration)")
            UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, options: .curveEaseOut, animations: {
               containerView.center = CGPoint(x: CGFloat(-threashold+10), y: CGFloat(Float((containerView.center.y))))
                
            }, completion: {
                isDone in
                if isDone{
                    //  CustomTabBarViewController.containerView.backgroundColor = UIColor.init(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
                
                   objmenuTable.isHidden = true
                    
                    if (completion != nil){
                        completion!()
                    }
                }
            })
         
        }
    }
    // #MARK:- hideSideMenu
    @objc func hideSideMenu(touch: UITouch) {
        let location:CGPoint = touch.location(in: touch.view)
        
        if ( !objmenuTable.bounds.contains(location) ) {
            
            self.hideMenu(completion: nil)
            // Point lies inside the bounds.
        }
        
        //        if !touch.view!.isDescendant(of: CustomTabBarViewController.objmenuTable){
        //            self.hideMenu()
        //               }
    }
    
    @objc func moveSideMenu(sender: Any) {
            var objmenuTable = SideMenuTable()
                 //optional public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
          objmenuTable = SideMenuTable(frame: containerView.bounds)
           containerView.addSubview(objmenuTable)
        //   self.view.bringSubview(toFront: ((sender as? UIPanGestureRecognizer)?.view)!)
        
        // CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
        var translatedPoint: CGPoint? = (sender as? UIPanGestureRecognizer)?.translation(in: self.view)
        if  Float((translatedPoint?.x)!)  > 0.0 {
           objmenuTable.isHidden = false
        }
        if (sender as? UIPanGestureRecognizer)?.state == .began {
            firstX = Float((sender as AnyObject).view.center.x)
            firstY = Float((sender as AnyObject).view.center.y)
        }
        // translatedPoint = CGPoint(x: Float(firstX + translatedPoint?.x), y: Float(firstY))
        let xpoint = firstX + Float((translatedPoint?.x)!)
        
        translatedPoint = CGPoint(x: CGFloat(xpoint), y: CGFloat(firstY))
        var x: CGFloat = translatedPoint!.x
        let threashold:CGFloat = containerView.frame.size.width/2
        if( x < -threashold ){
            x = -threashold
        }
        else if (x > threashold) {
            x = threashold
         objmenuTable.isHidden = false
        }
        translatedPoint = CGPoint(x: x, y: CGFloat((translatedPoint?.y)!))
        (sender as AnyObject).view.center = translatedPoint!
        
        if (sender as? UIPanGestureRecognizer)?.state == .ended {
            
            let velocityX: CGFloat? = (0.2 * ((sender as? UIPanGestureRecognizer)?.velocity(in: self.view).x)!)
            var finalX: CGFloat = translatedPoint!.x + velocityX!
            var finalY = CGFloat(firstY)
            // translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
            
            //   if !UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            //            if UIDevice.current.orientation == UIDeviceOrientation.portrait
            //
            //
            //            {
            if finalX < 0 {
                finalX = -threashold+10
                
            }
            else if finalX > 0 {
                finalX = threashold
               objmenuTable.isHidden = false
            }
            if finalY < 0{
                
                finalY = 0
            }
            else if finalY > 1024{
                
                finalY = 1024
            }
            
            let animationDuration: CGFloat = (abs(velocityX!) * 0.0002) + 0.2
            print("the duration is: \(animationDuration)")
     
            UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, options: .curveEaseOut, animations: {
               containerView.center = CGPoint(x: CGFloat(finalX), y: CGFloat(finalY))
            }, completion: {
                isDone in
                if isDone{
                    
                    if containerView.center.x > 0 {
                        
                        //                     CustomTabBarViewController.containerView.backgroundColor = UIColor.init(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
                      
                        objmenuTable.isHidden = false
                    }
                    else{
                        //                        CustomTabBarViewController.containerView.backgroundColor = UIColor.init(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
                      objmenuTable.isHidden = true
                        
                    }
                }
            })
            
        }
    }
    
}
extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.black, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = kCAAlignmentCenter
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
