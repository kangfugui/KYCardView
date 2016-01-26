//
//  KYCardItem.swift
//  KYCardViewDemo
//
//  Created by KangYang on 16/1/22.
//  Copyright © 2016年 KangYang. All rights reserved.
//

import UIKit

class KYCardItem: UIView {
    
    var index: Int?;
    var canDrag: Bool?;
    
    let imageView: UIImageView! = UIImageView();
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.canDrag = false;
        self.backgroundColor = UIColor.whiteColor();
        self.layer.borderColor = UIColor.grayColor().CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.masksToBounds = true;
        self.layer.cornerRadius = 4;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }

}
