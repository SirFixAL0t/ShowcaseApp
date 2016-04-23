//
//  RoundedCorners.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/22/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import UIKit

class RoundedCorners: UIImageView {


    override func awakeFromNib() {
        layer.cornerRadius = 0.2
        clipsToBounds = true
    }

}
