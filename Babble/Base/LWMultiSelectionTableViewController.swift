//
//  LWMultiSelectionTableViewController.swift
//  Babble
//
//  Created by Liyu Wang on 10/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import UIKit

fileprivate class LWMultiSelectionItem {
    let title: String
    var selected: Bool
    
    init(title: String, seleted: Bool) {
        self.title = title
        self.selected = seleted
    }
}

typealias LWMultiSelectionCompletion = (_ multiSelectionController: LWMultiSelectionTableViewController, _ selectedItems: [String], _ selectedIndices: [Int]) -> Void

class LWMultiSelectionTableViewController: UITableViewController {
    private let selectionTitle: String
    private var items: [LWMultiSelectionItem] = []
    
    var completion: LWMultiSelectionCompletion?
    
    var zeroSelectionAllowed = true
    
    var cancelButtonHidden: Bool = false {
        didSet(newValue) {
            configCancelButton(with: newValue)
        }
    }
    
    init(title: String, strs: [String], selected: [Int] = [], completion: LWMultiSelectionCompletion? = nil) {
        self.selectionTitle = title
        
        super.init(style: .plain)
        
        for i in 0..<strs.count {
            self.items.append(LWMultiSelectionItem(title: strs[i], seleted: selected.contains(i)))
        }
        self.completion = completion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.selectionTitle
        configCancelButton(with: self.cancelButtonHidden)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                 target: self,
                                                                 action: #selector(LWMultiSelectionTableViewController.doneButtonTapped(_:)))
        
        self.tableView.separatorInset = UIEdgeInsets.zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        
        // Configure the cell...
        let item = self.items[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        if item.selected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        item.selected = !item.selected
        tableView.reloadData()
        
        configDoneButton()
    }

}

extension LWMultiSelectionTableViewController {
    private func configCancelButton(with hiddenFlag: Bool) {
        if hiddenFlag {
            self.navigationItem.leftBarButtonItem = nil
        } else {
            self.navigationItem.leftBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                     target: self,
                                                                     action: #selector(LWMultiSelectionTableViewController.cancelButtonTapped(_:)))
        }
    }
    
    private func configDoneButton() {
        if !zeroSelectionAllowed {
            let selected = self.items.filter({ (item) -> Bool in
                return item.selected
            })
            
            self.navigationItem.rightBarButtonItem?.isEnabled = selected.count > 0
        }
    }
    
    @objc func cancelButtonTapped(_ sender: AnyObject!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonTapped(_ sender: AnyObject!) {
        self.dismiss(animated: true) {
            if let completion = self.completion {
                var selectedStrs: [String] = []
                var selectedIndices: [Int] = []
                
                for i in 0..<self.items.count {
                    if self.items[i].selected {
                        selectedStrs.append(self.items[i].title)
                        selectedIndices.append(i)
                    }
                }
                
                completion(self, selectedStrs, selectedIndices)
            }
        }
    }
}
