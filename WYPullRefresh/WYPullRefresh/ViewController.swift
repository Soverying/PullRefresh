//
//  ViewController.swift
//  testRefresh
//
//  Created by 王颖 on 16/5/31.
//  Copyright © 2016年 王颖. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,RefreshTableHeaderDelegate {
    var refreshHeaderView:WYRefreshTableHeaderView?
    var reloading = false
    var datas:Array<Int> = Array()
    @IBOutlet weak var tableView:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if refreshHeaderView == nil{
            let view :WYRefreshTableHeaderView = WYRefreshTableHeaderView(frame:CGRectMake(0.0, 0.0 - self.tableView.bounds.size.height, self.view.bounds.size.width, self.tableView.bounds.size.height) )
            view.delegate = self
            self.tableView.addSubview(view)
            refreshHeaderView = view
            datas.append(1)
            datas.append(2)
            datas.append(3)
            
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func reloadTableViewDataSource(){
        reloading = true
        datas.append(1)
        datas.append(2)
        datas.append(3)
    }
    func doneLoadingTableViewData(){
        reloading = false
        self.tableView.reloadData()
        self.refreshHeaderView?.refreshScrollViewDataSourceDidFinishedLoading(self.tableView)
    }
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (datas.count)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell:UITableViewCell?
        cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
        }
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
    //
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "section\(section)"
    }
    
    //
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.refreshHeaderView?.refreshScrollViewDidScroll(scrollView)
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.refreshHeaderView?.refreshScrollViewDidEndDragging(scrollView)
    }
    
    //
    
    func refreshTableHeaderDidTriggerRefresh(view: WYRefreshTableHeaderView) {
        self.reloadTableViewDataSource()
        self.performSelector(#selector(ViewController.doneLoadingTableViewData), withObject: nil, afterDelay: 3.0)
    }
    
    func refreshTableHeaderDataSourceIsLoading(view: WYRefreshTableHeaderView) -> Bool {
        return reloading
    }
    
    func refreshTableHeaderDataSourceLastUpdated(view: WYRefreshTableHeaderView) -> NSDate {
        return NSDate()
    }
    deinit{
        self.refreshHeaderView = nil
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

