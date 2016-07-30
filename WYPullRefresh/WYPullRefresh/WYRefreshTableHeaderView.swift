//
//  WYRefreshTableHeaderView.swift
//  refresh
//
//  Created by 王颖 on 16/3/15.
//  Copyright © 2016年 王颖. All rights reserved.
//

import Foundation
import UIKit
@objc protocol RefreshTableHeaderDelegate:NSObjectProtocol{
    func refreshTableHeaderDidTriggerRefresh(view :WYRefreshTableHeaderView)
    func refreshTableHeaderDataSourceIsLoading(view :WYRefreshTableHeaderView)->Bool
    optional func refreshTableHeaderDataSourceLastUpdated(view :WYRefreshTableHeaderView)->NSDate
}
enum PullRefreshState{
    case PullRefreshPulling
    case PullRefreshNormal
    case PullRefreshLoading
}
class WYRefreshTableHeaderView:UIView{
    var state :PullRefreshState?
    var lastUpdatedLabel :UILabel?
    var statusLabel:UILabel?
    var arrowImage:CALayer?
    var activityView:UIActivityIndicatorView?
    var delegate:RefreshTableHeaderDelegate?
    func refreshLastUpdatedDate(){
        if ((delegate?.respondsToSelector(#selector(RefreshTableHeaderDelegate.refreshTableHeaderDataSourceLastUpdated(_:)))) == true){
            let date :NSDate = (delegate?.refreshTableHeaderDataSourceLastUpdated!(self))!
            let formatter :NSDateFormatter = NSDateFormatter()
            formatter.AMSymbol = "AM"
            formatter.PMSymbol = "PM"
            formatter.dateFormat = "MM/dd/yyyy hh:mm:a"
            lastUpdatedLabel?.text = formatter.stringFromDate(date)
            NSUserDefaults.standardUserDefaults().setObject(lastUpdatedLabel?.text, forKey: "RefreshTableView_LastRefresh")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        else {
            lastUpdatedLabel?.text = nil
        }
    }
    func refreshScrollViewDidScroll(scrollView:UIScrollView){
        if (self.state == PullRefreshState.PullRefreshLoading){
            var offset :CGFloat = max(scrollView.contentOffset.y * (-1), 0)
            offset = min(offset, 60)
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0, 0.0, 0.0)
        }
        else if scrollView.dragging == true{
            var loading = false
            if ((self.delegate?.respondsToSelector(#selector(RefreshTableHeaderDelegate.refreshTableHeaderDataSourceIsLoading(_:)))) == true){
                loading = (self.delegate?.refreshTableHeaderDataSourceIsLoading(self))!
            }
            if (self.state == PullRefreshState.PullRefreshPulling && scrollView.contentOffset.y > -65.0 && scrollView.contentOffset.y < 0 && loading == false){
                self.setState(.PullRefreshNormal)
            }
            else if (self.state == PullRefreshState.PullRefreshNormal && scrollView.contentOffset.y < -65 && loading == false){
                self.setState(.PullRefreshPulling)
            }
            if (scrollView.contentInset.top != 0){
                scrollView.contentInset = UIEdgeInsetsZero
            }
        }
    }
    func refreshScrollViewDidEndDragging(scrollView:UIScrollView){
        var loading = false
        if (self.delegate?.respondsToSelector(#selector(RefreshTableHeaderDelegate.refreshTableHeaderDataSourceIsLoading(_:))) == true){
            loading = (self.delegate?.refreshTableHeaderDataSourceIsLoading(self))!
        }
        if (scrollView.contentOffset.y < -65 && loading == false){
            if (self.delegate?.respondsToSelector(#selector(RefreshTableHeaderDelegate.refreshTableHeaderDidTriggerRefresh(_:))) == true){
                self.delegate?.refreshTableHeaderDidTriggerRefresh(self)
            }
            self.setState(.PullRefreshLoading)
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            scrollView.contentInset = UIEdgeInsetsMake(60.0, 0.0, 0.0, 0.0)
            UIView.commitAnimations()
        }
    }
    func refreshScrollViewDataSourceDidFinishedLoading(scrollView:UIScrollView){
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        UIView.commitAnimations()
        self.setState(.PullRefreshNormal)
    }
    private func setState(aState :PullRefreshState){
        switch aState {
        case .PullRefreshPulling:
            self.statusLabel?.text = NSLocalizedString("Release to refresh...", comment: "Release to refresh status")
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.18)
            self.arrowImage?.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0, 0, 1.0)
            CATransaction.commit()
            break
        case .PullRefreshNormal:
            if self.state == .PullRefreshPulling {
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.18)
                self.arrowImage?.transform = CATransform3DIdentity
                CATransaction.commit()
            }
            self.statusLabel?.text = NSLocalizedString("Pull down to refresh...", comment: "Pull down to refresh status")
            self.activityView?.stopAnimating()
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.arrowImage?.hidden = false
            self.arrowImage?.transform = CATransform3DIdentity
            CATransaction.commit()
            self.refreshLastUpdatedDate()
            break
        default:
            self.statusLabel?.text = NSLocalizedString("Loading...", comment: "Loading Status")
            self.activityView?.startAnimating()
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.arrowImage?.hidden = true
            CATransaction.commit()
            break
        }
        self.state = aState
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 226.0/255.0, green: 231.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        //
        let label1 = UILabel()
        label1.frame = CGRectMake(0.0, frame.size.height - 30 , frame.size.width, 20.0)
        label1.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        label1.font = UIFont(name:"system" , size: 12.0)
        label1.textColor = UIColor(red: 87.0/255.0, green: 108.0/255.0, blue: 137.0/255.0, alpha: 1.0)
        label1.shadowColor = UIColor(white: 0.9, alpha: 1.0)
        label1.shadowOffset = CGSize(width: 0.0, height: 1.0)
        label1.backgroundColor = UIColor.clearColor()
        label1.textAlignment = .Center
        lastUpdatedLabel = label1
        self.addSubview(lastUpdatedLabel!)
        //
        let label2 = UILabel()
        label2.frame = CGRectMake(0.0, frame.size.height - 48 ,frame.size.width, 20.0)
        label2.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        label2.font = UIFont(name:"boldSystem" , size: 13.0)
        label2.textColor = UIColor(red: 87.0/255.0, green: 108.0/255.0, blue: 137.0/255.0, alpha: 1.0)
        label2.shadowColor = UIColor(white: 0.9, alpha: 1.0)
        label2.shadowOffset = CGSize(width: 0.0, height: 1.0)
        label2.backgroundColor = UIColor.clearColor()
        label2.textAlignment = .Center
        statusLabel = label2
        self.addSubview(statusLabel!)
        //
        let layer = CALayer()
        layer.frame = CGRectMake(25.0, frame.size.height - 65.0, 30.0, 55.0)
        layer.contentsGravity = kCAGravityResizeAspect
        let image :UIImage = UIImage(named: "blueArrow.png")!
        layer.contents = image.CGImage
        self.layer.addSublayer(layer)
        arrowImage = layer
        
        //
        let view :UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        view.frame = CGRectMake(25.0, frame.size.height - 38 , 20.0, 20.0)
        self.addSubview(view)
        activityView  = view
        //
        self.setState(.PullRefreshNormal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
