//
//  ViewController.swift
//  Assignment3
//
//  Created by obss on 29.07.2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Food Master"
        // Do any additional setup after loading the view.
    }
    @IBAction func buttonTapped(_ sender: Any) {
        let foodViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.foodViewName) as! FoodViewController
        foodViewController.foodName = textField.text
        
        navigationController?.pushViewController(foodViewController, animated: true)
    }
}

