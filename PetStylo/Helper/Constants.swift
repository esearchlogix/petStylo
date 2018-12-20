//
//  Constants.swift
//  VistarApp
//
//  Created by thinksysuser on 20/01/17.
//  Copyright © 2017 thinksysuser. All rights reserved.
//


import UIKit

let kRegexEmailValidate = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
let Email_Alert_Message = "Email is not valid."
let kAppName = "petstylo"
let kSupportEmail = "info@feuzy.com"
let kCollectioncellIdentifier = "cell"

let customerChangeNotification = "customerChangeNotification"

let kMessgaeCustThreBlank = "Customer threshold can't be blank."
let kMessageNoInternetError = "Internet Not Available."
let kMessageParametresError = "Parametres Error"
let kMessageNetworkError = "Network Error."
let kMessageServerError = "Internal Server Error, Please retry."
let kMessageInvalidResponseError = "Invalid Response Received from server."


var sideMenuDataSection1:NSArray{
    let array = ["Home","Dog","Cat","Fish","Bird","My Order","My Cart","My Addresses","Notification"]
    

    
    return array as NSArray
    
}
var sideMenuDataSection2:NSArray{
    let array = ["Refund Policy","Terms of Services","Privacy Policy"]
    return array as NSArray
    
}
var sideMenuDataSection3:NSArray{
    let array = ["Log Out"]
    
    
    
    return array as NSArray
    
}









var dogArray:NSArray{
    let array = ["DOG TOYS","DOG ACCESSORIES" ,"DOG BANDANAS","DOG BOW TIES","DOG COLLARS & LEASHES","DOG SCARVES","DOG CLOTHES & APPARELS"]
    
    return array as NSArray
}
var dogIDArray:NSArray{
    let array = [437611023,437611087,437611471,437611727,437613135,437611855,437612303]
    
    return array as NSArray
}

var catArray:NSArray{
    let array = ["CAT CRATES & CAGES","CAT TOYS","CAT COLLARS & LEASHES","CAT ACCESSORIES"]
    
    return array as NSArray
}

var catIDArray:NSArray{
    let array = [437612687,437612751,437613135,437612943]
    
    return array as NSArray
}

var fishArray:NSArray{
    let array = ["GRAVELS & STONES","FISH ACCESSORIES","AQUARIUM PLANTS","AQUARIUM TOYS,","FILTER & PUMPS"]
    
    return array as NSArray
}

var fishIDArray:NSArray{
    let array = [437613455,437613711,437613839,437613583,437614031]
    
    return array as NSArray
}

var birdArray:NSArray{
    let array = ["BIRDS ACCESSORIES","BIRDS CAGES & PLAYPENS","BIRDS TOYS"]
    
    return array as NSArray
}

var birdIDArray:NSArray{
    let array = [239589249,239588289,239587009,239588033,239589185,239589057,239588609,239589505,239589633,239201665,239587777,239587905,239588993,239587713,239588481,239587521,239595329,239597377]
    
    return array as NSArray
}

var sortingArray:NSArray{
    let array = ["Sort By","Alphabetically,A-Z","Alphabetically,Z-A","Price,low to high","Price,high to low"]
    
    return array as NSArray
}

var dogSections = [
    Section(category: "DOG", subCategory:  dogArray as! [String], id:dogIDArray as! [Int], expended: true)
]
var catSections = [
    Section(category: "CAT", subCategory: catArray as! [String], id:catIDArray as! [Int], expended: true),
    

]
var fishSections = [
    Section(category: "FISH", subCategory: fishArray as! [String], id:fishIDArray as! [Int], expended: true),
    
]
var birdSections = [
    Section(category: "BIRD", subCategory: birdArray as! [String], id: birdIDArray as! [Int], expended: true),
    
]



var arrayCategoryName:NSArray{
    let array = ["DOG","CAT","FISH","BIRD"]
    
    return array as NSArray
}
var arrayCategoryImages:NSArray{
    let array = ["dogImage","catImage","fishImage","birdImage"]
    
    return array as NSArray
}

var arraySlideOfferImages:NSArray{
    let array = ["SlideImage1","SlideImage2","SlideImage3"]
   
    return array as NSArray
}

let tableViewCellIdentifier = "tablecellidentifier"
let screenWidth = UIScreen.main.bounds.size.width
let screenheight = UIScreen.main.bounds.size.height
var labelHeading:UILabel?

import Foundation

// MARK:- Social Promotion web URL
var keyfacbookURL:String {
    return String(format:"https://www.facebook.com/PetStylo-935822639892767/")
}
var keyGooglURL:String {
    return String(format:"https://plus.google.com/110519442366304126211")
}
var keyInstagramURL:String {
    return String(format:"https://www.instagram.com/ribbons.cheap/")
}
var keyPinterestURL:String {
    return String(format:"https://in.pinterest.com/ribbonscheap/")
}
var keyTwitterkURL:String {
    return String(format:"https://twitter.com/Shopify?ref_src=twsrc%5Etfw%7Ctwcamp%5Eembeddedtimeline%7Ctwterm%5Eprofile%3AShopify&ref_url=https%3A%2F%2Fwww.petstylo.com%2F")
}

var keyRefundPolicyURL:String{
    return String(format: "https://www.petstylo.com/pages/refund-policy")
}
var keyTermsURL:String{
    return String(format: "https://www.petstylo.com/pages/terms-of-service")
}
var keyPrivacyPolicyURL:String{
    return String(format: "https://www.petstylo.com/pages/privacy-policy")
}

var keyFresh:String {
    return String(format:"isFresh")
}
var keySessionID:String {
    return String(format:"sessionID")
}
var keyDeviceToken:String {
    return String(format:"deviceToken")
}
var isNotificationReceived:String {
    return String(format:"isNotificationReceived")
}
var keyRepCount:String {
    return String(format: "repCount")
}

//var keyInitialRep:String {
//    return String(format:"initialRep")
//}
var keyCurrentRep:String {
    return String(format:"currentReps")
}
var keyAMname:String {
    return String(format:"amName")
}
var keyEnvironmentType:String {
    return String(format:"environmentType")
}
var keyCustomerDetailDic:String{
    
    return String(format:"selectedCustomerDetailsDic")
}
var keyUserName:String{
    
    return String(format:"userName")
}
var keyUserDisplayName:String{
    
    return String(format:"userDisplayName")
}
var keyUserTitle:String{
    
    return String(format:"userTitle")
}
var keyToken:String{
    
    return String(format:"activeToken")
}
var keyCustomerFirstName:String{
    
    return String(format:"customerFirstName")
}
var keyCustomerLastName:String{
    
    return String(format:"customerLirstName")
}
var keyCustomerID:String{
    
    return String(format:"customerID")
}

var keyValidDateToken:String{
    
    return String(format:"expiryDateToken")
}
var keyIsLogIN:String{
    
    return String(format:"isLogIN")
}

var keyCustomerAccount:String{
    
    return String(format:"customerAccount")
}
var keyCustomerCity:String{
    
    return String(format:"customerCity")
}
var keyCustomerName:String{
    
    return String(format:"customerName")
}
var keyCustomerPlant:String{
    
    return String(format:"customerPlant")
}
var keyCustomerState:String{
    
    return String(format:"customerState")
}


var keyArrayPlots:String{
    
    return String(format:"arrayPlots")
}
var appFont:String{
    
    return String(format:"HelveticaNeue")
}

var appFontBold:String{
    
    return String(format:"HelveticaNeue-Bold")
}

var notificationTypePriceApproval:String{
    
    return String(format:"priceApproval")
}

var notificationTypeQuoteAdded:String{
    
    return String(format:"quoteAdded")
}

var badgeCountUpdateNotification:String{
    
    return String(format:"badgeCountUpdateNotification")
}


var screenRatioWidth:Double
{
    return Double(screenWidth)/375.0
}
enum NotificationType {
    case PriceApproval
    case QuoteAdded
    case NotDefined
}

enum ScrollViewLazy{
    case UP
    case Down
    case None
}

enum DetailType{
    case PriceApprovalOther
    case QuoteDetailOther
    case OrderDetailOther
    case PriceApprovalProduct
    case QuoteDetailProduct
    case OrderDetailProduct
    case PartDetail
    case PartDetailOther
    case PartDetailArray

    case PartDetailOtherArray


}

enum EnvironmentType:String{
    case Production = "Production"
    case Development = "Development"
    
}
