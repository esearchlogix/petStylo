//
//  PaymentViewController.swift
//  Ribbons
//
//  Created by Alekh Verma on 09/08/18.
//  Copyright © 2018 Alekh Verma. All rights reserved.
//

import UIKit
import SafariServices
import Pay
import MBProgressHUD
import CoreData


var billingAddress : PayAddress?
class PaymentViewController: UIViewController,YourDelegate,PaySessionDelegate,PayPalPaymentDelegate,SFSafariViewControllerDelegate,UIWebViewDelegate{
    
    
    @IBOutlet var viewDetail : UIView?
    @IBOutlet var buttonShopify : UIButton?
    @IBOutlet var buttonApplePay : UIButton?
    @IBOutlet var buttonPaypal : UIButton?
    
    @IBOutlet var labeShipingDetailCustomerEmail : UILabel?
    @IBOutlet var labelBillingDetailCustomerAddress : UILabel?
    
    @IBOutlet var labelShipingDetailCustomerAddress : UILabel?
    
    @IBOutlet var labelTotalPrice : UILabel?
     var webView: UIWebView? = UIWebView()
    fileprivate var paySession: PaySession?
    
    var paymentCheckoutView : CheckoutViewModel?
    
    var payPalConfig = PayPalConfiguration()
    var tokenizationID = "sandbox_n4hx83mh_3v9g83wwqg2hb27z"
    
    func paySession(_ paySession: PaySession, didRequestShippingRatesFor address: PayPostalAddress, checkout: PayCheckout, provide: @escaping  (PayCheckout?, [PayShippingRate]) -> Void) {
        
        print("Updating checkout with address...")
        Client.shared.updateCheckout(checkout.id, updatingPartialShippingAddress: address, activeViewController: self) { checkout in
            guard let checkout = checkout else {
                print("Update for checkout failed.")
                provide(nil, [])
                return
            }
            
            print("Getting shipping rates...")
            Client.shared.fetchShippingRatesForCheckout(checkout.id, activeViewController: self) { result in
                if let result = result {
                    print("Fetched shipping rates.")
                    provide(result.checkout.payCheckout, result.rates.payShippingRates)
                } else {
                    provide(nil, [])
                }
            }
        }
    }
    
    func paySession(_ paySession: PaySession, didUpdateShippingAddress address: PayPostalAddress, checkout: PayCheckout, provide: @escaping (PayCheckout?) -> Void) {
        
        print("Updating checkout with shipping address for tax estimate...")
        Client.shared.updateCheckout(checkout.id, updatingPartialShippingAddress: address, activeViewController: self){ checkout in            
            if let checkout = checkout {
                provide(checkout.payCheckout)
            } else {
                print("Update for checkout failed.")
                provide(nil)
            }
        }
    }
    
    func paySession(_ paySession: PaySession, didSelectShippingRate shippingRate: PayShippingRate, checkout: PayCheckout, provide: @escaping  (PayCheckout?) -> Void) {
        
        print("Selecting shipping rate...")
        Client.shared.updateCheckout1(checkout.id, updatingShippingRate: shippingRate, activeViewController: self) { updatedCheckout in
            print("Selected shipping rate.")
            provide(updatedCheckout?.payCheckout)
        }
    }
    
    func paySession(_ paySession: PaySession, didAuthorizePayment authorization: PayAuthorization, checkout: PayCheckout, completeTransaction: @escaping (PaySession.TransactionStatus) -> Void) {
        
                guard let email = authorization.shippingAddress.email else {
                    print("Unable to update checkout email. Aborting transaction.")
                    completeTransaction(.failure)
                    return
                }
        
        
                        print("Completing checkout...")
        Client.shared.completeCheckout(checkout, billingAddress: billingAddress!, activeViewController: self, applePayToken: authorization.token, idempotencyToken: paySession.identifier) { payment in
                            if let payment = payment, checkout.paymentDue == payment.amount {
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title:kAppName, message:"Order is created Successfully." , preferredStyle: .alert)
                                    let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
                                        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
                                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                                        do {
                                            try context.execute(deleteRequest)
                                            try context.save()
                                            let destinationViewController = OrderHistoryViewController(nibName: "OrderHistoryViewController", bundle: nil)
                                            self.navigationController?.pushViewController(destinationViewController, animated: true)
                                        } catch {
                                            print ("There was an error")
                                        }
                                    })
                                    alertController.addAction(OKAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                print("Checkout completed successfully.")
                                completeTransaction(.success)
                            } else {
                                print("Checkout failed to complete.")
                                completeTransaction(.failure)
                            }
                        }
        
        
            }
    
 
    
    func paySessionDidFinish(_ paySession: PaySession) {
        print("Payment Complete")
    }
    

    
   
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.methodNavigationBarBackGroundColor()
        self.methodToSetSideMenuButtonInNavigationBarWithoutCart()
        
        var payAddress: PayAddress {
            
            return PayAddress(
                addressLine1: paymentCheckoutView?.shippingAddress?.address1,
                addressLine2: paymentCheckoutView?.shippingAddress?.address2,
                city:         paymentCheckoutView?.shippingAddress?.city,
                country:      paymentCheckoutView?.shippingAddress?.country,
                province:     paymentCheckoutView?.shippingAddress?.province,
                zip:          paymentCheckoutView?.shippingAddress?.zip,
                firstName:    paymentCheckoutView?.shippingAddress?.firstName,
                lastName:     paymentCheckoutView?.shippingAddress?.lastName,
                phone:        paymentCheckoutView?.shippingAddress?.phone,
                email:        paymentCheckoutView?.email
            )
        }
        billingAddress = payAddress
        
        let shippingDetail1 = (paymentCheckoutView?.shippingAddress?.address1) ?? ""
        let shippingDetail2 =  "," + (paymentCheckoutView?.shippingAddress?.address2)!
        let shippingDetail3 =  "," + (paymentCheckoutView?.shippingAddress?.city)!
         let shippingDetail4 =  "," + (paymentCheckoutView?.shippingAddress?.province)!
        let shippingDetail5 =   "," + (paymentCheckoutView?.shippingAddress?.zip)!
        let shippingDetail6 =  "," + (paymentCheckoutView?.shippingAddress?.country)!
        labelShipingDetailCustomerAddress?.text = shippingDetail1 + shippingDetail2 + shippingDetail3 + shippingDetail4 + shippingDetail5 +  shippingDetail6
        
        labeShipingDetailCustomerEmail?.text = paymentCheckoutView?.email
        labelBillingDetailCustomerAddress?.text = shippingDetail1 + shippingDetail2 + shippingDetail3 + shippingDetail4 + shippingDetail5 +  shippingDetail6

        
        
        
        labelTotalPrice?.text = "$\(paymentCheckoutView?.paymentDue ?? 0.00)"
       
        
//        Utility.giveShadowEffectToView(view: buttonShopify!)
//        Utility.giveShadowEffectToView(view: buttonApplePay!)

       // Utility.giveShadowEffectToView(view: buttonPaypal!)
        
        // Do any additional setup after loading the view.
    }

   
    
    func didPressButton(dictAddress: [String : Any]) {
        let shippingDetail1 = "\(dictAddress["address1"] as? String ?? ""),\(dictAddress["address2"] as? String ?? "")"
        let shippingDetail2 =  "\(dictAddress["city"] as? String ?? ""),\(dictAddress["province"] as? String ?? "")"
        let shippingDetail3 = "\(dictAddress["zip"] as? String ?? ""),\(dictAddress["country"] as? String ?? "")"
        
        labelBillingDetailCustomerAddress?.text = shippingDetail1 + "," + shippingDetail2 +  " " + shippingDetail3
        var billTo : PayAddress{
        return PayAddress(
            addressLine1: dictAddress["address1"] as? String ?? "",
            addressLine2: dictAddress["address2"] as? String ?? "",
            city:         dictAddress["city"] as? String ?? "",
            country:      dictAddress["country"] as? String ?? "",
            province:     dictAddress["province"] as? String ?? "",
            zip:          dictAddress["zip"] as? String ?? "",
            firstName:    dictAddress["firstName"] as? String ?? "",
            lastName:     dictAddress["lastName"] as? String ?? "",
            phone:        dictAddress["phone"] as? String ?? "",
            email:        paymentCheckoutView?.email ?? ""
        )
        }
        billingAddress = billTo
    }
    @IBAction func changeButton(sender: UIButton){
        let destinationViewController = AddAddressViewController(nibName: "AddAddressViewController", bundle: nil)
        destinationViewController.isPayment = true
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    @IBAction func changeEmailButton(sender: UIButton){
        let alert = UIAlertController(title: kAppName, message: "Enter Any valid Email-ID", preferredStyle: .alert)
        alert.addTextField { textField in
            
            textField.attributedPlaceholder = NSAttributedString(string: "Email-id")
            textField.resignFirstResponder()
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Change", style: .cancel, handler: { [unowned alert] action in
            let code = alert.textFields?.first?.text
            if Utility.isValidEmail(testStr: code ?? "") == false{
                 ModalViewController.showAlert(alertTitle: kAppName, andMessage: "Please enter a valid email-ID.", withController: self)
            }else{
                Client.shared.updateCheckout((self.paymentCheckoutView?.id) ?? "0000", updatingEmail: code ?? "", activeViewController: self){ updatedCheckout in
            
                    guard let _ = updatedCheckout else {
            ModalViewController.showAlert(alertTitle: kAppName, andMessage: "Not Able to update Email-id right now", withController: self)
                        return
                    }
                    self.labeShipingDetailCustomerEmail?.text = updatedCheckout?.email
                    self.paymentCheckoutView = updatedCheckout
                    
                }
            }
           
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func shopifyButton(sender: UIButton){
        if labeShipingDetailCustomerEmail?.text == "" || labeShipingDetailCustomerEmail?.text == nil {
          ModalViewController.showAlert(alertTitle: kAppName, andMessage: "Please Enter valid Email Address by change Button", withController: self)
        }else{
            
            self.methodToSetSideMenuButtonInNavigationBarPaymentShopify()
            webView?.frame  = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            webView?.loadRequest((NSURLRequest(url: (paymentCheckoutView?.webURL)!) as URLRequest) as URLRequest)
            webView?.delegate = self;
            self.view.addSubview(webView!)
        }
    }
    func webView(_ webView: UIWebView!, didFailLoadWithError error: Error!) {
        print("Webview fail with error \(error)");
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            //self.showLinksClicked()
            return false
            
        }
        print("urlAfter success---------   \(String(describing: request.url))")
        
        
        if request.url?.absoluteString.range(of: "thank_you") != nil {
            webView.stopLoading()
            DispatchQueue.main.async {
                let alertController = UIAlertController(title:kAppName, message:"Order is created Successfully." , preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
                    webView.removeFromSuperview()
                    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                    do {
                        try context.execute(deleteRequest)
                        try context.save()
                        let destinationViewController = OrderHistoryViewController(nibName: "OrderHistoryViewController", bundle: nil)
                        self.navigationController?.pushViewController(destinationViewController, animated: true)
                    } catch {
                        print ("There was an error")
                    }
                })
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            return false
        }else{
           return true
        }
        
        
        print(request.url?.queryDictionary ?? "NONE")
//        let dictUrl = request.url?.queryDictionary ?? [:]
//        if let val = dictUrl["complete"]{
//           if dictUrl["complete"] == "true" {
//            webView.stopLoading()
//            DispatchQueue.main.async {
//                let alertController = UIAlertController(title:kAppName, message:"Order is created Successfully." , preferredStyle: .alert)
//                let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
//                    webView.removeFromSuperview()
//                    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
//                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
//                    do {
//                        try context.execute(deleteRequest)
//                        try context.save()
//                        let destinationViewController = OrderHistoryViewController(nibName: "OrderHistoryViewController", bundle: nil)
//                        self.navigationController?.pushViewController(destinationViewController, animated: true)
//                    } catch {
//                        print ("There was an error")
//                    }
//                })
//                alertController.addAction(OKAction)
//                self.present(alertController, animated: true, completion: nil)
//            }
//
//            return false
//            }else{
//                return true
//            }
//        }
         return true
    }
   
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Webview started Loading")
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Webview did finish load")
    }
    func showLinksClicked() {
        
        let safariVC = SFSafariViewController(url: (paymentCheckoutView?.webURL)!)
        safariVC.navigationItem.title = "Checkout"
        safariVC.delegate = self
        self.navigationController?.present(safariVC, animated: true, completion: nil)
      
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applePaybutton(sender: UIButton){
        if labeShipingDetailCustomerEmail?.text == "" || labeShipingDetailCustomerEmail?.text == nil {
            ModalViewController.showAlert(alertTitle: kAppName, andMessage: "Please Enter valid Email Address by change Button", withController: self)
        }else{
            let payCurrency = PayCurrency(currencyCode: "USD", countryCode: "US")
            let payItems    = paymentCheckoutView?.lineItems.map { item in
                PayLineItem(price: item.totalPrice, quantity: item.quantity)
            }
            var payAddress: PayAddress {
                
                return PayAddress(
                    addressLine1: paymentCheckoutView?.shippingAddress?.address1,
                    addressLine2: paymentCheckoutView?.shippingAddress?.address2,
                    city:         paymentCheckoutView?.shippingAddress?.city,
                    country:      paymentCheckoutView?.shippingAddress?.country,
                    province:     paymentCheckoutView?.shippingAddress?.province,
                    zip:          paymentCheckoutView?.shippingAddress?.zip,
                    firstName:    paymentCheckoutView?.shippingAddress?.firstName,
                    lastName:     paymentCheckoutView?.shippingAddress?.lastName,
                    phone:        paymentCheckoutView?.shippingAddress?.phone,
                    email:        paymentCheckoutView?.email
                )
            }
            var payShippingRate: PayShippingRate {
                
                return PayShippingRate(
                    handle:        (paymentCheckoutView?.shippingRate?.handle) ?? "",
                    title:         (paymentCheckoutView?.shippingRate?.title) ?? " ",
                    price:         (paymentCheckoutView?.shippingRate?.price) ?? 0 ,
                    deliveryRange: nil
                )
            }
            let payCheckout = PayCheckout(
                id:              (paymentCheckoutView?.id) ?? "",
                lineItems:       payItems ?? [],
                discount:        nil,
                shippingAddress: nil,
                shippingRate:    nil,
                subtotalPrice:   (paymentCheckoutView?.subtotalPrice) ?? 0.00,
                needsShipping:   (paymentCheckoutView?.requiresShipping) ?? false,
                totalTax:        (paymentCheckoutView?.totalTax) ?? 0.00,
                paymentDue:      (paymentCheckoutView?.paymentDue) ?? 0.00
            )
            
            let paySession      = PaySession(shopName: (shopArray?.object(forKey: "name") as? String) ??  "PETSTYLO", checkout: payCheckout, currency: payCurrency, merchantID: Client.merchantID)
            
            paySession.delegate = self
            self.paySession     = paySession
            
            paySession.authorize()
        }
    }
        // MARK: - Pay Delegate
//    func paySession(_ paySession: PaySession, didAuthorizePayment authorization: PayAuthorization, checkout: PayCheckout, completeTransaction: @escaping (PaySession.TransactionStatus) -> Void) {
//
//        guard let email = authorization.shippingAddress.email else {
//            print("Unable to update checkout email. Aborting transaction.")
//            completeTransaction(.failure)
//            return
//        }
//
//
//                print("Completing checkout...")
//        Client.shared.completeCheckout(checkout, billingAddress: billingAddress!, applePayToken: authorization.token, idempotencyToken: paySession.identifier) { payment in
//                    if let payment = payment, checkout.paymentDue == payment.amount {
//                        print("Checkout completed successfully.")
//                        completeTransaction(.success)
//                    } else {
//                        print("Checkout failed to complete.")
//                        completeTransaction(.failure)
//                    }
//                }
//
//
//    }
   
    @IBAction func payPalButton(sender : UIButton){
        
        //Configure the marchant
        
        self.configurePaypal(strMarchantName: "petstylo")
        
       // showDropIn(clientTokenOrTokenizationKey: tokenizationID)

        
        //Set selected product in “PayPalItem” for purchase
        
       // self.setItems(dict.valueForKey("Product") as? String, noOfItem: "1", strPrice: dict.valueForKey("Price") as? String, strCurrency: "USD", strSku: nil)
        
        
        
        //Go for pay in paypal for selected paypal items
        
     self.goforPayNow(shipPrice: "\(paymentCheckoutView?.shippingRate?.price ?? 0.00)", taxPrice: "\(paymentCheckoutView?.totalTax ?? 0.00)", totalAmount: "\(paymentCheckoutView?.subtotalPrice ?? 0.00)", strShortDesc: "Paypal", strCurrency: "USD")
            
            
            
            
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true) { () -> Void in
            print("You just dismissed the login view.")
        }    }
    
    //It will provide access to the card too for the payment.
    
    func acceptCreditCards() -> Bool {
        
        return false
        
    }
    
    
    
    func setAcceptCreditCards(acceptCreditCards: Bool) {
        
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards()
        
    }
    
    
    
    //Set environment connection.
    
    var environment:String = PayPalEnvironmentProduction
    {
        willSet(newEnvironment) {
            if (newEnvironment != environment)
            {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    //Configure paypal and set Marchant Name
    
    func configurePaypal(strMarchantName:String) {
     
        
        // Set up payPalConfig
        
        payPalConfig.acceptCreditCards = self.acceptCreditCards();
        
        payPalConfig.merchantName = strMarchantName
        
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full") as URL?
        
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full") as URL?
        
        
        
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0]
        
        

        payPalConfig.payPalShippingAddressOption = .provided ;
        
        
        
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
        
        PayPalMobile.preconnect(withEnvironment: environment)
        
    }
    
    
    
    //Start Payment for selected shopping items
    
    func goforPayNow(shipPrice:String?, taxPrice:String?, totalAmount:String?, strShortDesc:String?, strCurrency:String?) {
        
        var subtotal : NSDecimalNumber = 0
        
        var shipping : NSDecimalNumber = 0
        
        var tax : NSDecimalNumber = 0
        
      
            
            subtotal = NSDecimalNumber(string: totalAmount)
            
        
        
        
        
        // Optional: include payment details
        
        if (shipPrice != nil) {
            
            shipping = NSDecimalNumber(string: shipPrice)
            
        }
        
        if (taxPrice != nil) {
            
            tax = NSDecimalNumber(string: taxPrice)
            
        }
        
        
        
        var description = strShortDesc
        
        if (description == nil) {
            
            description = ""
            
        }
        
        
        
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let paypalShippingTo = PayPalShippingAddress(recipientName:"\(paymentCheckoutView?.shippingAddress?.firstName ?? "") \(paymentCheckoutView?.shippingAddress?.lastName ?? "")" , withLine1: (paymentCheckoutView?.shippingAddress?.address1) ?? "", withLine2: paymentCheckoutView?.shippingAddress?.address2, withCity: (paymentCheckoutView?.shippingAddress?.city) ?? "", withState: paymentCheckoutView?.shippingAddress?.province, withPostalCode: paymentCheckoutView?.shippingAddress?.zip, withCountryCode: (paymentCheckoutView?.shippingAddress?.countryCode) ?? "")
        
       // let total = subtotal.adding(shipping).adding(tax)
        
        
        
        let payment = PayPalPayment(amount: NSDecimalNumber(string: "\((paymentCheckoutView?.paymentDue) ?? 0.01)"), currencyCode: strCurrency!, shortDescription: description!, intent: .sale)
        
        
        
        payment.shippingAddress = paypalShippingTo
       // payment.paymentDetails = paymentDetails
        
        
        
        self.payPalConfig.acceptCreditCards = self.acceptCreditCards();
        
        
        
        if self.payPalConfig.acceptCreditCards == true {
            
            print("We are able to do the card payment")
            
        }
        
        
        
        if (payment.processable) {
            
            let objVC = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            
            
            
            self.present(objVC!, animated: true, completion: { () -> Void in
                
                print("Paypal Presented")
                
            })
            
        }
            
        else {
            
            print("Payment not processalbe: \(payment)")
            ModalViewController.showAlert(alertTitle: kAppName, andMessage: "Unable to proceed now with paypal.Please try aftre some time.", withController: self)
        }
        
    }

    //PayPalPaymentDelegate methods
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        
        paymentViewController.dismiss(animated: true) { () -> Void in
            
            print("and Dismissed")
            
        }
        
        print("Payment cancel")
        
    }
    
    
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        
        paymentViewController.dismiss(animated: true) { () -> Void in

            print("and done\(completedPayment.confirmation)")

            let arrayLineItem = NSMutableArray()
            var index = 0
            for item in (self.paymentCheckoutView?.lineItems) ?? []{
                let base64Encoded :  String = (self.paymentCheckoutView?.lineItems[index].variantID) ?? ""
                let decodedData = Data(base64Encoded: base64Encoded)!
                let decodedString = String(data: decodedData, encoding: .utf8) ?? ""
                let varientID = decodedString.replacingOccurrences(of: "gid://shopify/ProductVariant/", with: "", options: NSString.CompareOptions.literal, range: nil)
                var varientDict = [
                    "variant_id": varientID ,
                    "quantity": self.paymentCheckoutView?.lineItems[index].quantity ?? 0
                    ] as [String : Any]
                arrayLineItem.add(varientDict)
                index = index + 1
            }
            var dictShippingAddress = [
                "addressLine1": self.paymentCheckoutView?.shippingAddress?.address1 ?? "",
                "addressLine2": self.paymentCheckoutView?.shippingAddress?.address2 ?? "",
                "city":         self.paymentCheckoutView?.shippingAddress?.city ?? ""
            ] as [String : Any]
            let dictShippingAddress1 = [
                "country":      self.paymentCheckoutView?.shippingAddress?.country ?? "",
                "province":     self.paymentCheckoutView?.shippingAddress?.province ?? "",
                "zip":          self.paymentCheckoutView?.shippingAddress?.zip ?? ""
                ] as [String : Any]
            let dictShippingAddress2 = [

                "firstName":    self.paymentCheckoutView?.shippingAddress?.firstName ?? "",
                "lastName":     self.paymentCheckoutView?.shippingAddress?.lastName ?? "",
                "phone":        self.paymentCheckoutView?.shippingAddress?.phone ?? "",
                "email":        self.paymentCheckoutView?.email
                ] as [String : Any]
            dictShippingAddress.merge(dict: dictShippingAddress1)
            dictShippingAddress.merge(dict: dictShippingAddress2)

            let cstorage = HTTPCookieStorage.shared
            if let cookies = cstorage.cookies(for: NSURL(string: "https://a74ea1421fb13439b649fe9d44e0f3f6:3b423920ac3190c872a7c1569763da3f@petstylo.myshopify.com/admin/orders.json")! as URL) {
                for cookie in cookies {
                    cstorage.deleteCookie(cookie)
                }
            }
            
            let headers = [
                "Content-Type": "application/json",
                "Authorization": "Basic YTc0ZWExNDIxZmIxMzQzOWI2NDlmZTlkNDRlMGYzZjY6M2I0MjM5MjBhYzMxOTBjODcyYTdjMTU2OTc2M2RhM2Y=",
                 "Cache-Control": "no-cache"
            ]
            let dict = [
                "email": self.paymentCheckoutView?.email ?? "",
                "fulfillment_status": "fulfilled",
                "send_receipt": true,
                "send_fulfillment_receipt": true,
                "line_items": arrayLineItem,
                "shipping_address": dictShippingAddress,
                "billing_address": dictShippingAddress
                ] as [String : Any]


            let parameters = ["order": dict] as [String : Any]


                do {
//                    DispatchQueue.main.async {
//                                                            let alertController = UIAlertController(title:kAppName, message:"Order is created Successfully." , preferredStyle: .alert)
//                                                            let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
//                                                                self.navigationController?.popToRootViewController(animated: true)
//                                                            })
//                                                            alertController.addAction(OKAction)
//                                                            self.present(alertController, animated: true, completion: nil)
//                                                        }
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                    // here "jsonData" is the dictionary encoded in JSON data
                    let customerID = UserDefaults.standard.value(forKey: keyCustomerID)
                    let request = NSMutableURLRequest(url: NSURL(string: "https://a74ea1421fb13439b649fe9d44e0f3f6:3b423920ac3190c872a7c1569763da3f@petstylo.myshopify.com/admin/orders.json")! as URL)
                    request.timeoutInterval = 10.0
                    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
//                    let request = NSMutableURLRequest(url: NSURL(string: "https://341e9e33ee0e4315acaf0d0f67a4a2c6:835bf757ccfac46ce093174868f7c28e@ribbons-cheap-2.myshopify.com/admin/orders.json")! as URL,
//                                                      cachePolicy: .useProtocolCachePolicy,
//                                                      timeoutInterval: 10.0)
                    request.httpMethod = "POST"
                    request.allHTTPHeaderFields = headers
                    request.httpBody = jsonData as Data

                 
                    
                    let config = URLSessionConfiguration.default
                    config.requestCachePolicy = .reloadIgnoringLocalCacheData
                    config.urlCache = nil
                    let session = URLSession.init(configuration: config)

                    DispatchQueue.main.async {
                        MBProgressHUD.showAdded(to: self.view!, animated: true)
                    }
                    if Utility.isInternetAvailable(){
                    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: self.view!, animated: true)
                        }

                        if (error != nil) {
                            ModalViewController.showAlert(alertTitle: "error", andMessage: kMessageServerError, withController: self)
                        } else {
                            let httpResponse = response as? HTTPURLResponse
                            if httpResponse?.statusCode == 201{
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title:kAppName, message:"Order is created Successfully." , preferredStyle: .alert)
                                    let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
                            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
                            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                                        do {
                                            try context.execute(deleteRequest)
                                            try context.save()
                                            let destinationViewController = OrderHistoryViewController(nibName: "OrderHistoryViewController", bundle: nil)
                                            self.navigationController?.pushViewController(destinationViewController, animated: true)
                                        } catch {
                                            print ("There was an error")
                                        }
                                                              })
                                    alertController.addAction(OKAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }else{
                                do {
                                    if   let parsedData:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                                    {
                                        if let error = parsedData.value(forKey: "errors") as? String
                                        {

                                            ModalViewController.showAlert(alertTitle: "error", andMessage: "Error Received from server - \(error)", withController: self)

                                        }else{
                                            ModalViewController.showAlert(alertTitle: "error", andMessage: kMessageServerError, withController: self)
                                        }

                                    }

                                } catch let error as NSError {


                                    ModalViewController.showAlert(alertTitle: "error", andMessage: "Invalid Response Received from server ", withController: self)

                                    print(error)
                                }
                            }
                            print(httpResponse)
                        }
                    })

                    dataTask.resume()
            }else{
                ModalViewController.showAlert(alertTitle: kAppName, andMessage: kMessageNoInternetError, withController: self)
            }

                    let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    // here "decoded" is of type `Any`, decoded from JSON data

                    // you can now cast it with the right type
                    if let dictFromJSON = decoded as? [String:String] {
                        // use dictFromJSON
                    }
               } catch {
                    print(error.localizedDescription)
                }


        }
        
        print("Payment is going on\(completedPayment.confirmation)")
        
    }
    func methodToSetSideMenuButtonInNavigationBarPaymentShopify(){
        
        let backPaymentButton = UIButton()
        backPaymentButton.setImage(#imageLiteral(resourceName: "BackIcon"), for: .normal)
        backPaymentButton.frame = CGRect(x:0,y:0,width:47,height:47)
        backPaymentButton.addTarget(self, action: #selector(paymentBackButtonAction(sender:)), for: .touchUpInside)
        let navigateSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigateSpacer.width = 0
        
        
        let leftBarButton = UIBarButtonItem()
        // leftBarButton.style = .plain
        leftBarButton.customView = backPaymentButton
        
        self.navigationItem.setLeftBarButtonItems([navigateSpacer,leftBarButton], animated: false)
        
        let titleImage = UIImageView(frame: CGRect(x: 0.0, y: 10.0, width: 100, height: 40))
        titleImage.image = #imageLiteral(resourceName: "logoImage")
        
        self.navigationItem.titleView = titleImage
        self.MethodToSetGesture()
        
        
        
    }

    @objc  func paymentBackButtonAction(sender:UIButton?){
       
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:kAppName, message:"Do you want to close your payment" , preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "YES", style: .default, handler:{ action in
                self.webView?.stopLoading()
                self.webView?.removeFromSuperview()
                
                self.viewDidLoad()
            })
            let CancelAction = UIAlertAction(title: "NO", style: .default, handler:{ action in
                
            })
            alertController.addAction(CancelAction)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
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
extension URL {
    var queryDictionary: [String: String]? {
        guard let query = URLComponents(string: self.absoluteString)?.query else { return [:]}
        if query == ""{
            return [:]
        }else{
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            
            let key = pair.components(separatedBy: "=")[0]
            
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        return queryStrings
        }
    }
}
