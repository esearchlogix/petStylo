import UIKit
import  MBProgressHUD
import CoreData
import SMFloatingLabelTextField

protocol YourDelegate : class {
    func didPressButton(dictAddress:[String : Any])
}

class AddAddressViewController: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var scrollViewAddress : UIScrollView?
    @IBOutlet var textFieldFirstName : SMFloatingLabelTextField?
    @IBOutlet var textFieldLastName : SMFloatingLabelTextField?
    @IBOutlet var textFieldCompany : SMFloatingLabelTextField?
    @IBOutlet var textFieldAddresss1 : SMFloatingLabelTextField?
    @IBOutlet var textFieldAddress2 : SMFloatingLabelTextField?
    @IBOutlet var textFieldCity : SMFloatingLabelTextField?
    @IBOutlet var textFieldState : SMFloatingLabelTextField?
    @IBOutlet var textFieldCountry : SMFloatingLabelTextField?
    @IBOutlet var textFielZip: SMFloatingLabelTextField?
    @IBOutlet var textFieldPhone : SMFloatingLabelTextField?{
        didSet { textFieldPhone?.addDoneCancelToolbar() }
    }
    
    
    weak var addressdelegate: YourDelegate?
    var picker = UIPickerView()
    var isPayment = false
    var isShipment = false
    var countryArray : NSMutableArray? = []
    var activeTextField : UITextField?
    var stateArray : NSMutableArray? = []
    var countrySearchArray : NSMutableArray? = ["United States","Australia","Canada","United Kingdom"]
    var stateSearchArray : NSMutableArray? = []
    var tblView :  UITableView?
    var textFieldArray : NSArray? = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        scrollViewAddress?.contentSize = CGSize(width: self.view.frame.size.width, height: 500)
        scrollViewAddress?.contentInset=UIEdgeInsetsMake(64.0,0.0,50.0,0.0);
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            self.methodToSetSideMenuButtonInNavigationBarWithPopBack(badgeNumber: result.count)
            
        }catch{
            print("failed")
        }
        
        self.methodToSetBottamNavigationBar(title: "Add Shipping Address")
        self.methodNavigationBarBackGroundColor()
        
        textFieldArray = [textFieldFirstName ?? UITextField(),textFieldLastName ?? UITextField(),textFieldCompany ?? UITextField(),textFieldAddresss1 ?? UITextField(),textFieldAddress2 ?? UITextField(),textFieldCity ?? UITextField(),textFieldState ?? UITextField(),textFieldCountry ?? UITextField(),textFielZip ?? UITextField(),textFieldPhone ?? UITextField()]
        
        for textfld in textFieldArray!{
            (textfld as? UITextField)?.clipsToBounds = true
            (textfld as? UITextField)?.layer.cornerRadius = 10
            Utility.giveDoubleBorderToView(view: (textfld as? UITextField)!, colour: UIColor.white)
            (textfld as? UITextField)?.attributedPlaceholder = NSAttributedString(string: ((textfld as? UITextField)?.placeholder)!,attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: ((textfld as? UITextField)?.frame.size.height)!))
            (textfld as? UITextField)?.leftView = paddingView
            (textfld as? UITextField)?.leftViewMode = .always
        }
        
        let ObjServer = Server()
        ObjServer.delegate = self
        ObjServer.hitGetRequest(url: fetchCountryDetail, inputIsJson: false, parametresJsonDic:nil, parametresJsonArray: nil,callingViewController:self, completion: {_,_,_ in })
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self // This is not required
        self.view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    // MARK: - gesture method and delegate
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        activeTextField?.resignFirstResponder()
        picker.resignFirstResponder()
        tblView?.removeFromSuperview()
        tblView = nil
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: tblView ?? UITableView()))!{
            return false
        }else{
            return true
        }
    }
    
    
    // MARK: - recieve API data
    func didReceiveResponse(dataDic: NSDictionary?, response:URLResponse?) {
        if let val = dataDic!["countries"] {
            let arrayRespose : NSArray? = dataDic?.object(forKey: "countries") as? NSArray
            countryArray = arrayRespose?.mutableCopy() as? NSMutableArray
            DispatchQueue.main.async {
                self.textFieldCountry?.text = "United States"
                
                for arrayCountry in self.countryArray ?? []{
                    if ((arrayCountry as? NSDictionary)?.object(forKey: "name") as? String) == "United States"{
                        let arrayResponse : NSArray = ((arrayCountry as? NSDictionary)?.object(forKey: "provinces") as? NSArray)!
                        self.stateArray = arrayResponse.mutableCopy() as? NSMutableArray
                        if self.stateArray?.count == 0{
                            self.textFieldState?.isUserInteractionEnabled = false
                            self.textFieldState?.alpha = 0.5
                        }else{
                            self.textFieldState?.isUserInteractionEnabled = true
                            self.textFieldState?.alpha = 1.0
                        }
                        self.stateSearchArray = self.stateArray
                        return
                    }
                }
            }
        }else{
            let alertController = UIAlertController(title:kAppName, message:"Address is add successfully." , preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
                self.navigationController?.popViewController(animated: true)
            })
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func didFailWithError(error: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:kAppName, message:error , preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
            })
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        if(textField == textFieldFirstName)
        {
            textFieldLastName?.becomeFirstResponder()
        }
        else if textField == textFieldLastName{
            textFieldCompany?.becomeFirstResponder()
        }else if textField == textFieldCompany{
            textFieldAddresss1?.becomeFirstResponder()
        }else if textField == textFieldAddresss1{
            textFieldAddress2?.becomeFirstResponder()
        }else if textField == textFieldAddress2{
            textFieldCity?.becomeFirstResponder()
        }else if textField == textFieldCity{
            textFieldCountry?.becomeFirstResponder()
        }else if textField == textFieldCountry{
            if stateArray?.count == 0{
                textFieldState?.isUserInteractionEnabled = false
                textFieldState?.alpha = 0.5
            }else{
                textFieldState?.isUserInteractionEnabled = true
                textFieldState?.alpha = 1.0
                textFieldState?.becomeFirstResponder()
            }
            
        }else if textField == textFieldState{
            textFielZip?.becomeFirstResponder()
        }else if textField == textFielZip{
            textFieldPhone?.becomeFirstResponder()
        }
        else
        {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ ")
        if textField ==  textFieldFirstName || textField ==  textFieldLastName {
            if let range = string.rangeOfCharacter(from:set ){
                return true
            }
            else {
                if string == ""{
                    return true
                }
                return false
            }
        }else if textField == textFieldPhone{
            let setMobile = CharacterSet(charactersIn: "1234567890")
            if let range = string.rangeOfCharacter(from:setMobile ){
                return true
            }
            else {
                if string == ""{
                    return true
                }
                return false
            }
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        picker.resignFirstResponder()
        tblView?.removeFromSuperview()
        tblView = nil
        activeTextField = textField
        
        if textField == textFieldState {
            if textFieldCountry?.text == ""{
                ModalViewController.showAlert(alertTitle: kAppName, andMessage: "Please select a country first.", withController: self)
                return false
            }else{
                
                makePickerView(textField: textField, tagValue: 1)
            }
        }else if textField == textFieldCountry{
            textFieldState?.text = ""
            
            makePickerView(textField: textField, tagValue: 2)
            
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textFieldState {
            
            stateSearchArray = stateArray
            
        }else if textField == textFieldCountry{
            
        }
    }
    // MARK: - Make tableView
    
    
    func makePickerView(textField : UITextField, tagValue : Int){
        
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        picker.tag = tagValue
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker(sender:)))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputView = picker
        textField.inputAccessoryView = toolBar
        
        
        
        
    }
    @objc func donePicker(sender:UIButton?) {
        
        activeTextField?.resignFirstResponder()
        
    }
    
    
    // MARK: - pickerView Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 2{
            return (countrySearchArray?.count) ?? 0
        }else{
            return (stateSearchArray?.count) ?? 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1{
            return (stateSearchArray?.object(at: row) as? NSDictionary)?.object(forKey: "name") as? String
            
        }else{
            return countrySearchArray?.object(at: row)  as? String
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        if pickerView.tag == 1{
            textFieldState?.text = (stateSearchArray?.object(at: row) as? NSDictionary)?.object(forKey: "name") as? String
            
        }else{
            
            for arrayCountry in countryArray ?? []{
                if ((arrayCountry as? NSDictionary)?.object(forKey: "name") as? String) == countrySearchArray?.object(at: row)  as? String{
                    let arrayResponse : NSArray = ((arrayCountry as? NSDictionary)?.object(forKey: "provinces") as? NSArray) ?? []
                    stateArray = arrayResponse.mutableCopy() as? NSMutableArray
                    if stateArray?.count == 0{
                        textFieldState?.isUserInteractionEnabled = false
                        textFieldState?.alpha = 0.5
                    }else{
                        textFieldState?.isUserInteractionEnabled = true
                        textFieldState?.alpha = 1.0
                    }
                    stateSearchArray = stateArray
                    
                }
            }
            textFieldCountry?.text = countrySearchArray?.object(at: row)  as? String
            
        }
        
        
        picker.resignFirstResponder()
        
    }
    
    
    // MARK: - ButtonAction
    
    
    @IBAction func addAddress(sender : UIButton){
        if textFieldAddresss1?.text == "" || textFieldFirstName?.text == "" || textFieldCity?.text == "" || textFieldCountry?.text == ""  || textFielZip?.text == ""{
            ModalViewController.showAlert(alertTitle: kAppName, andMessage: "Please fill all mendentory fields.", withController: self)
        }else{
            let dictAdd : NSMutableDictionary? = [:]
            
            
            let headers = [
                "Content-Type": "application/json",
                "Cache-Control": "no-cache"
            ]
            var dict = [
                "first_name": textFieldFirstName?.text ?? "",
                "last_name": textFieldLastName?.text ?? "",
                "zip": textFielZip?.text ?? ""
                ] as [String : Any]
            let dict1 = [
                "city": textFieldCity?.text ?? "",
                "province": textFieldState?.text ?? "",
                "country": textFieldCountry?.text ?? "",
                
                ]
            let dict2 = [
                "company":  textFieldCompany?.text ?? "",
                "address1": textFieldAddresss1?.text ?? "",
                "address2": textFieldAddress2?.text ?? ""
            ]
            let dict3 = [
                
                "phone": textFieldPhone?.text ?? "",
                "name": "\(textFieldFirstName?.text ?? "") \(textFieldLastName?.text ?? "")",
                "country_name": textFieldCountry?.text ?? ""
                
            ]
            let dict4 = [
                "default": true
            ]
            
            
            
            dict.merge(dict: dict1)
            dict.merge(dict: dict2)
            dict.merge(dict: dict3)
            if isShipment == true || sender.tag == 102{
                dict.merge(dict: dict4)
            }
            
            let parameters = ["address": dict] as [String : Any]
            if isPayment == true{
                addressdelegate?.didPressButton(dictAddress: dict)
                self.navigationController?.popViewController(animated: true)
            }
            else{
                do {
                      let customerID = UserDefaults.standard.value(forKey: keyCustomerID)
                    let cstorage = HTTPCookieStorage.shared
                    if let cookies = cstorage.cookies(for: NSURL(string: "https://a74ea1421fb13439b649fe9d44e0f3f6:3b423920ac3190c872a7c1569763da3f@petstylo.myshopify.com/admin/customers/\(customerID ?? 00000)/addresses.json")! as URL) {
                        for cookie in cookies {
                            cstorage.deleteCookie(cookie)
                        }
                    }
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                    // here "jsonData" is the dictionary encoded in JSON data
                  
                   
                
                    let request = NSMutableURLRequest(url: NSURL(string: "https://a74ea1421fb13439b649fe9d44e0f3f6:3b423920ac3190c872a7c1569763da3f@petstylo.myshopify.com/admin/customers/\(customerID ?? 00000)/addresses.json")! as URL)
                    request.timeoutInterval = 10.0
                    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                    request.httpMethod = "POST"
                    request.allHTTPHeaderFields = headers
                    request.httpBody = jsonData as Data
                    
                    let session = URLSession.shared
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
                                DispatchQueue.main.async {
                                    if httpResponse?.statusCode == 201{
                                        
                                        let alertController = UIAlertController(title:kAppName, message:"Address is add successfully." , preferredStyle: .alert)
                                        let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ action in
                                            self.navigationController?.popViewController(animated: true)
                                        })
                                        alertController.addAction(OKAction)
                                        self.present(alertController, animated: true, completion: nil)
                                        
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
extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
