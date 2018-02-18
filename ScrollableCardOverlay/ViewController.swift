//
//  ViewController.swift
//  ScrollableCardOverlay
//
//  Created by Evgeny Shurakov on 18/02/2018.
//  Copyright © 2018 Evgeny Shurakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction private func showCard() {
        let cardViewController = CardOverlayViewController(nibName: nil, bundle: nil)
        self.present(cardViewController, animated: true, completion: nil)
    }
    
}

