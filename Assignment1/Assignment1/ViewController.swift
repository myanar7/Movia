//
//  ViewController.swift
//  Assignment1
//
//  Created by obss on 27.07.2021.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        label.text = ""
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        do {
            let newLabel : UILabel = try label.copyObject() as! UILabel
            newLabel.text = textField.text
            stackView.insertArrangedSubview(newLabel,at: 1)
        } catch {
            print("OLMADI")
        }
        textField.text = ""
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        buttonTopConstraint.constant = 300.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text == "" {
            buttonTopConstraint.constant = 700.0
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            textField.resignFirstResponder()
        }
    }
}
//INTERNETTEN BULDUM OBJE KOPYALAMA
extension NSObject {
    func copyObject<T:NSObject>() throws -> T? {
        let data = try NSKeyedArchiver.archivedData(withRootObject:self, requiringSecureCoding:false)
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
    }
}
