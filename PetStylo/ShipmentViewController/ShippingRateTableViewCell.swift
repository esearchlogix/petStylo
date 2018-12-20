//
//  ShippingRateTableViewCell.swift
//  Ribbons
//
//  Created by Alekh Verma on 03/08/18.
//  Copyright © 2018 Alekh Verma. All rights reserved.
//

import UIKit

protocol YourCellDelegate : class {
    func didPressButton(_ tag: Int)
}
class ShippingRateTableViewCell: UITableViewCell {
    @IBOutlet var shippingServiceName : UILabel?
    @IBOutlet var ShippingServicePrice : UILabel?
    @IBOutlet var shippingServiceSelectButton : UIImageView?
    
    weak var cellDelegate: YourCellDelegate?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func buttonPressed(_ sender: UIButton) {
        cellDelegate?.didPressButton(sender.tag)
    }  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
