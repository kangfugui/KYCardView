//
//  KYCardView.swift
//  KYCardViewDemo
//
//  Created by KangYang on 16/1/22.
//  Copyright © 2016年 KangYang. All rights reserved.
//

import UIKit
import Foundation

@objc protocol KYCardViewDelegate: NSObjectProtocol {
    
    func cardView(cardView: KYCardView, itemSizeAtIndex index:Int)-> CGSize;
    func numberOfCardsInCardView(cardView: KYCardView)-> Int;
    func cardView(cardView: KYCardView, willDisplayItem item:KYCardItem, atIndex index:Int);
    optional func cardView(cardView: KYCardView, didTapAtIndex index:Int);
    optional func cardView(cardView: KYCardView, didRemoveItemAtIndex index:Int);
}

class KYCardView: UIView {
    
    var delegate: KYCardViewDelegate?;
    
    private var tempCache = [KYCardItem]();
    private var displayItems = [KYCardItem]();
    private var animator: UIDynamicAnimator!;
    private var originalCenter: CGPoint?;
    private var dragBeganLocation: CGPoint?;
    private var displayedCount: NSInteger!;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        displayedCount = 0;
        animator = UIDynamicAnimator(referenceView: self);
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "panGestureAction:");
        self.addGestureRecognizer(panGesture);
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureAction:");
        self.addGestureRecognizer(tapGesture);
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    func reload() {
        
        let number = self.delegate?.numberOfCardsInCardView(self);
        if number > 0 {
            
            for var i = 0; i < number; i++ {
                
                let zoom = 1 - (CGFloat(i) * 0.05);
                let y = CGRectGetMidY(self.bounds) + CGFloat(i * 16);
                
                let cardItem = self.createCardItem();
                cardItem.center = CGPointMake(CGRectGetMidX(self.bounds), y);
                cardItem.transform = CGAffineTransformMakeScale(zoom, zoom);
                self.insertSubview(cardItem, atIndex: 0);
                self.displayItems.append(cardItem);
                
                if i == 0 { originalCenter = cardItem.center;}
                else if i == 3 { break;}
            }
        }
    }
    
//    MARK: privare method
    
    private func createCardItem() -> KYCardItem {
        
        var cardItem: KYCardItem!;
        if tempCache.count > 0 {
            cardItem = tempCache.first;
            tempCache.removeAtIndex(0);
        } else {
            let size: CGSize! = self.delegate?.cardView(self, itemSizeAtIndex: 0);
            cardItem = KYCardItem(frame: CGRectMake(0, 0, size.width, size.height));
        }
        
        cardItem.index = Int(displayedCount);
        
        displayedCount = displayedCount + 1;
        
        return cardItem;
    }
    
    private func reset() {
        
        animator.removeAllBehaviors();
        
        let snap = UISnapBehavior(item: displayItems.first!, snapToPoint: originalCenter!);
        snap.damping = 0.5;
        animator.addBehavior(snap);
        
        UIView.animateWithDuration(0.25) {
            self.adjustScaleByOffset(0);
        }
    }
    
    private func adjustScaleByOffset(offset: CGFloat) {
        
        if offset > 100 { return;}
        
        for var i = 0; i < displayItems.count; i++ {
            
            if (i == 0 || i >= displayItems.count) { continue;}
            
            let item = displayItems[i];
            
            var origin = 1 - (CGFloat(i) * 0.05);
            var gain = 0.05 * (offset / 100);
            let zoom = origin + gain;
            
            item.transform = CGAffineTransformMakeScale(zoom, zoom);
            
            origin = CGRectGetMidY(self.bounds) + CGFloat(i * 16);
            gain = 16 * (offset / 100);
            let y = origin - gain;
            
            item.center = CGPointMake(CGRectGetMidX(self.bounds), y);
        }
    }
    
    private func pushCardToOutside(card: KYCardItem, velocity: CGPoint) {
        
        let pushBehavior = UIPushBehavior(items: [card], mode: UIPushBehaviorMode.Instantaneous);
        pushBehavior.pushDirection = CGVectorMake(velocity.x / 10, velocity.y / 10);
        pushBehavior.magnitude = 100;
        animator.addBehavior(pushBehavior);
    };
    
    func removeCard(card: KYCardItem) {
        
        self.animator.removeAllBehaviors();
        
        let idx: Int! = self.displayItems.indexOf(card);
        self.displayItems.removeAtIndex(idx);
        self.tempCache.append(card);
        
        card.removeFromSuperview();
        
        if self.delegate?.respondsToSelector("cardView:didRemoveItemAtIndex:") == true {
            
            self.delegate?.cardView!(self, didRemoveItemAtIndex: card.index!);
        }
    }
    
    func insertCardToLowest() {
        
        let zoom = 1 - (CGFloat(3) * 0.05);
        let y = CGRectGetMidY(self.bounds) + CGFloat(3 * 16);
        
        let cardItem = self.createCardItem();
        cardItem.center = CGPointMake(CGRectGetMidX(self.bounds), y);
        cardItem.transform = CGAffineTransformMakeScale(zoom, zoom);
        
        self.insertSubview(cardItem, atIndex: 0);
        self.displayItems.append(cardItem);
    }
    
    private func beganLocationOffsetWithOther(other: CGPoint) -> CGFloat {
        
        let x = abs((dragBeganLocation?.x)! - other.x);
        let y = abs((dragBeganLocation?.y)! - other.y);
        return max(x, y);
    }
    
//    MARK: events response
    
    func tapGestureAction(sender: UITapGestureRecognizer) {
        
        let location = sender.locationInView(self);
        if CGRectContainsPoint((displayItems.first?.frame)!, location) {
            
            if self.delegate?.respondsToSelector("cardView:didTapAtIndex:") == true {
                
                self.delegate?.cardView!(self, didTapAtIndex: (displayItems.first?.index)!);
            }
        }
    }
    
    func panGestureAction(sender: UIPanGestureRecognizer) {
        
        if displayItems.count == 0 { return;}
        
        let cardItem: KYCardItem! = displayItems.first;
        let location = sender.locationInView(self);
        
        switch (sender.state) {
        case .Began:
            animator.removeAllBehaviors();
            
            if CGRectContainsPoint(cardItem.frame, location) {
                cardItem.canDrag = true;
                dragBeganLocation = location;
            }
            
            break
        case .Ended:
            if cardItem.canDrag == true {
                
                cardItem.canDrag = false;
                
                let offset = self.beganLocationOffsetWithOther(location);
                if offset > 100 {
                    let velocity = sender.velocityInView(self);
                    self.adjustScaleByOffset(100);
                    self.pushCardToOutside(cardItem, velocity: velocity);
                    self.performSelector("removeCard:", withObject: cardItem, afterDelay: 0.5);
                    
                    let number = self.delegate?.numberOfCardsInCardView(self);
                    if displayedCount < number {
                        self.insertCardToLowest();
                    }
                    
                } else {
                    self.reset();
                }
            }
            break
        case .Changed:
            if cardItem.canDrag == true {
                
                let offset = sender.translationInView(self);
                cardItem.center = CGPointMake(cardItem.center.x + offset.x, cardItem.center.y + offset.y);
                sender.setTranslation(CGPoint.zero, inView: self);
                
                let offsetOfBegan = self.beganLocationOffsetWithOther(location);
                self.adjustScaleByOffset(offsetOfBegan);
            }
            break
        default:
            break
        }
    }
}
