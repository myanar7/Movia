//
//  FoodViewController.swift
//  Assignment3
//
//  Created by obss on 29.07.2021.
//

import UIKit

class FoodViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: Constants.foodCellNibName, bundle: nil), forCellReuseIdentifier: Constants.foodCellNibName)
        }
    }
    
    var foodName : String?
    var arrayFoods : FoodResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FoodNetwork.shared.delegate = self
        if let name = foodName {
            FoodNetwork.shared.fetchData(foodName: name)
        }
        // Do any additional setup after loading the view.
    }
}
extension FoodViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayFoods?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.foodCellNibName) as! FoodCell
        if let food = arrayFoods?.results[indexPath.row]{
            print("DENEME")
            cell.configure(foodName: food.title, calories: food.nutrition.nutrients.first!.amount, imageUrl: food.image)
        }
        return cell
    }
}
extension FoodViewController : FoodNetworkDelegate{
    func didDataReceived(data: FoodResult) {
        self.arrayFoods = data
        self.tableView.reloadData()
    }
    
    
}
