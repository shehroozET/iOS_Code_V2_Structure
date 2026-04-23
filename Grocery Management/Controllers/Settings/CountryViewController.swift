//
//  CountryViewController.swift
//  Grocery Management
//
//  Created by mac on 01/07/2025.
//

import UIKit

class CountryViewController: UIViewController  , UITableViewDelegate , UITableViewDataSource{
    
  
    @IBOutlet weak var tableCountry : UITableView!
    var onCountrySelected: ((String, String) -> Void)?
    var countryList: [(key: String, value: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "country", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            let countryPairs = dict.sorted { $0.key < $1.key }
            self.countryList = countryPairs
            tableCountry.delegate = self
            tableCountry.dataSource = self
            tableCountry.reloadData()
        } else {
            print("Failed to load Countries")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell") as! CountryCell
        cell.country.text = self.countryList[indexPath.row].key
        cell.currency.text = self.countryList[indexPath.row].value
        return cell
    }
    
    func tableView(_ tableView : UITableView , didSelectRowAt indexPath : IndexPath){
        
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedCountry = countryList[safe: indexPath.row]
        {
            
            onCountrySelected?(selectedCountry.key, selectedCountry.value)
            self.navigationController?.popViewController(animated: true)
        }
    }
    

}
