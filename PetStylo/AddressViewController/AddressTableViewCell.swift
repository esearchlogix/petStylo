//
//  AddressTableViewCell.swift
//  Ribbons
//
//  Created by Alekh Verma on 31/07/18.
//  Copyright © 2018 Alekh Verma. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet var name : UILabel?
    @IBOutlet var AddressLabel : UILabel?
    @IBOutlet var AddressCity : UILabel?
    @IBOutlet var AddressCountry : UILabel?
    @IBOutlet var AddressMobile : UILabel?
    @IBOutlet var defaultButton : UIButton?
    @IBOutlet var cancelButton : UIButton?
    @IBOutlet var cellView : UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
