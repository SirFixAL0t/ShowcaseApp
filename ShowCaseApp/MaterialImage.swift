//
//  MaterialImage.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/21/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import UIKit

class MaterialImage: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = frame.size.width / 2
        clipsToBounds = true
    }

}
