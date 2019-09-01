//
//  FavoriteViewController.swift
//  MiniBrouser
//
//  Created by Сергей on 24/07/2019.
//  Copyright © 2019 Sergey Gryaznov. All rights reserved.
//


let keyPages = "pages"

import UIKit

class FavoriteViewController: UITableViewController {

    var pages: [String] = []
    var currentURL: URL!
    weak var delegate: FavoriteViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: keyPages) == nil {
            let bundle = Bundle.main
            let plistURL = bundle.url(forResource: "data", withExtension: "plist")
            pages = NSArray.init(contentsOf: plistURL!) as! [String]
            saveSettings()
        } else {
            loadSettings()
        }
  
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
  
    //MARK: - Save and Load
    
    private func saveSettings() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(self.pages, forKey: keyPages)
        userDefaults.synchronize()
    }
    
    private func loadSettings() {
        let userDefaults = UserDefaults.standard
        self.pages = userDefaults.object(forKey: keyPages) as! [String]
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifierStatic = "Cell"
        let identifierDynamic = "NewPage"
        
        if indexPath.row <= pages.count - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: identifierStatic, for: indexPath)
            cell.textLabel?.text = pages[indexPath.row]
            if indexPath.row < 4 {
                cell.backgroundColor = .groupTableViewBackground
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: identifierDynamic, for: indexPath)
            cell.textLabel?.textColor = .blue
            cell.textLabel?.text = "Добавить"
            return cell
        }       
    }
    
  
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row > 3 && indexPath.row < pages.count {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == pages.count  {
            let allert = UIAlertController(title: "Новая страница", message: "Введите адрес:", preferredStyle: .alert)
            allert.addTextField { (textField) in
                textField.font = UIFont.systemFont(ofSize: 22)
                textField.keyboardType = .URL
                textField.placeholder = "https://www."
            }
            let actionOK = UIAlertAction(title: "OK", style: .default) { (_) in
                var soursePages = self.pages
                soursePages.append("https://www.\(allert.textFields!.last!.text!)")
                if soursePages.last != "https://www." {
                    self.pages = soursePages
                    self.saveSettings()
                    self.tableView.reloadData()
                }
            }
            let actionCancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            allert.addAction(actionOK)
            allert.addAction(actionCancel)
            present(allert, animated: true, completion: nil)
        } else {
            currentURL = URL(string: pages[indexPath.row])
            delegate?.newRequest(request: URLRequest(url: currentURL))
            self.dismiss(animated: true) {
               
            }
        }
    }
    
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.pages.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            saveSettings()
        }
    }
}

protocol FavoriteViewControllerDelegate: class {
    func newRequest(request: URLRequest)
}
