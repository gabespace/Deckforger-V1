//
//  AddDeckViewController.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/15/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit
import ReSwift

class AddDeckViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, StoreSubscriber {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var formatPickerView: UIPickerView!
    
    
    // MARK: - Properties
    private let formats = ["Casual", "Standard", "Frontier", "Modern", "Legacy", "Vintage", "EDH", "Pauper"]
    private var name = "Untitled"
    private var format = "Casual"
    
    // MARK: - IBActions
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        store.dispatch(AddNewDeck(name: name, format: format))
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatPickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func newState(state: State) { }
    
    
    // MARK: - UIPickerView Data Source & Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return formats.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
