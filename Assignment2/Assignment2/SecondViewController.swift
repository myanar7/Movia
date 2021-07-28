//
//  SecondViewController.swift
//  Assignment2
//
//  Created by obss on 28.07.2021.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    var pageName : String = "Sayfa"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Şüphesiz ki \(pageName) dünyanın en güzel şehridir !"
        
    }
    func observeMethod(){
        NotificationCenter.default.addObserver(self, selector: #selector(receiveCellData(_:)), name: Notification.Name(Constants.notificationName), object: nil)
    }
    @objc func receiveCellData(_ notification : Notification){
        if let userInfo = notification.userInfo, let value = userInfo["valueKey"] as? String {
            pageName = value
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
