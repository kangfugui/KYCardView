//
//  ViewController.swift
//  KYCardViewDemo
//
//  Created by KangYang on 16/1/22.
//  Copyright © 2016年 KangYang. All rights reserved.
//

import UIKit

class ViewController: UIViewController,KYCardViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.whiteColor();
        
        let cardView = KYCardView(frame: self.view.bounds);
        cardView.delegate = self;
        self.view.addSubview(cardView);
        cardView.reload();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cardView(cardView: KYCardView, itemSizeAtIndex index: Int) -> CGSize {
        
        let length = self.view.bounds.width - 40;
        return CGSizeMake(length, length);
    }
    
    func numberOfCardsInCardView(cardView: KYCardView) -> Int {
        
        return 5;
    }
    
    func cardView(cardView: KYCardView, willDisplayItem item: KYCardItem, atIndex index: Int) {
        
        
    }
    
    func cardView(cardView: KYCardView, didTapAtIndex index: Int) {
        
    }
    
    func cardView(cardView: KYCardView, didRemoveItemAtIndex index: Int) {
        
    }
}

