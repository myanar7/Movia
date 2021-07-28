//
//  ViewController.swift
//  Assignment2
//
//  Created by obss on 28.07.2021.
//

import UIKit

class Constants {
    static let reuseIdentifier = "tableViewCell"
    static let nibName = "FirstTableViewCell"
    static let secondViewIdentifier = "SecondViewController"
    static let notificationName = "Observer"
}

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UINib(nibName: Constants.nibName, bundle: nil), forCellReuseIdentifier: Constants.reuseIdentifier)
        }
    }
    
    let names = [
        "Dida",
        "Maldini",
        "Nesta",
        "Stam",
        "Gattuso",
        "Cafu",
        "Kaka",
        "Seedorf",
        "Schevchenko",
        "Inzaghi",
        "Pirlo",
        "Crespo",
        "Pato",
    ]
    let cities = [
        "Antalya",
        "Istanbul",
        "Warsaw",
        "Izmir",
        "Ankara",
        "Bursa",
        "Eskisehir",
        "New York",
        "Amasya",
        "Sivas",
        "Mersin",
        "Bolu",
        "Balikesir",
    ]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FirstTableViewCell
        
        if indexPath.section == 0 {
            
            cell.contentView.backgroundColor = (cell.contentView.backgroundColor==UIColor.white) ? UIColor.red : UIColor.white
            
        }else if indexPath.section == 1 {
        
            guard let secondViewController = UIStoryboard(name: "Main" , bundle: nil).instantiateViewController(withIdentifier: Constants.secondViewIdentifier) as? SecondViewController else {return}
            
            secondViewController.observeMethod()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.notificationName), object: nil, userInfo: ["valueKey" : cities[indexPath.row]])
            
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return names.count
        }else if section == 1 {
            return cities.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier,for: indexPath) as! FirstTableViewCell
        
        if indexPath.section == 0 {
            cell.cellLabel.text = names[indexPath.row]
            cell.contentView.backgroundColor = .white
        }else if indexPath.section == 1 {
            cell.cellLabel.text = cities[indexPath.row]
            cell.contentView.backgroundColor = .systemBlue
        } else {
            cell.cellLabel.text = "PROBLEM"
        }        
        return cell
    }
}
