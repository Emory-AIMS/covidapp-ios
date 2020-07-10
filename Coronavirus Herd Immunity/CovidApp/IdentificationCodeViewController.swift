//
//  IdentificationCodeViewController.swift
//  CovidApp - Covid Community Alert
//
//  Created by Cesar Bess on 22/04/20.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class IdentificationCodeViewController: UIViewController {
    
    var identificationCode: String?
    
    @IBOutlet weak var identificationCodeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        identificationCodeLabel.text = identificationCode
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
