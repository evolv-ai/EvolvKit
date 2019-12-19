//
//  ViewController.swift
//
//  Copyright (c) 2019 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import EvolvKit

/// This example shows how the data can be structured in your view controllers,
/// your implementation can work directly with the raw string and serialize into EvolvRawAllocation.
class ViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
    private let evolvClient = EvolvClientHelper.shared.client
    
    @IBAction func didPressCheckOut(_ sender: Any) {
        evolvClient.emitEvent(forKey: "conversion")
        textLabel.text = "Conversion!"
    }
    
    @IBAction func didPressProductInfo(_ sender: Any) {
        textLabel.text = "Some really cool product info"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        checkoutButton?.titleLabel?.font = .systemFont(ofSize: 24)
        
        // MARK: Evolv subscribe
        evolvClient.subscribe(forKey: "checkout.button.background.color", defaultValue: __N("#000000"), closure: setCheckoutButtonColor)
        evolvClient.subscribe(forKey: "checkout.button.text", defaultValue: __N("BUY STUFF"), closure: changeButtonText)
        evolvClient.confirm()
    }
    
    /// Trailing closure example that will apply the treatments from the allocation.
    ///
    /// - Parameter layoutOption: Implementer decides what the data type will be.
    ///   Needs to match subscribe method's default value data type.
    /// - Use DispatchQueue to ensure this operation runs on the UI thread
    lazy var changeButtonText: (EvolvRawAllocationNode) -> Void = { buttonTextOption in
        DispatchQueue.main.async { [weak self] in
            self?.checkoutButton.setTitle(buttonTextOption.stringValue, for: .normal)
        }
    }
    
}

extension ViewController {
    
    /// Simple function example that will apply the treatments from the allocation.
    ///
    /// - Parameter color: Implementer decides what the data type will be.
    ///   Needs to match subscribe method's default value data type.
    /// - Use DispatchQueue to ensure this operation runs on the UI thread
    private func setCheckoutButtonColor(_ color: EvolvRawAllocationNode) {
        DispatchQueue.main.async { [weak self] in
            let backgroundColor = UIColor(hexString: color.stringValue)
            
            self?.checkoutButton.backgroundColor = backgroundColor
            
            if backgroundColor.isLight() ?? false {
                self?.checkoutButton.setTitleColor(.black, for: .normal)
            } else {
                self?.checkoutButton.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
