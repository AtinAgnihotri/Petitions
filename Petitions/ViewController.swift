//
//  ViewController.swift
//  Petitions
//
//  Created by Atin Agnihotri on 14/07/21.
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [PetitionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setNavBar()
        loadDataFromAPI()
        print("Loading complete")
    }
    
    func setNavBar() {
        title = "Petitions"
    }
    
    func loadDataFromAPI() {
//         let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        let urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"

        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parseData(data)
            } else {
                print("Failed to parse data from url")
            }
        } else {
            print("Failed to fetch data from url")
        }
    }
    
    func parseData(_ json: Data) {
        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode(PetitionResultsModel.self, from: json) {
            petitions = decodedData.results
            tableView.reloadData()
        } else {
            print("Failed to decode data from url")
        }
    }
    
    func addToPetitions(_ result: Data) {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Petition", for: indexPath)
        cell.textLabel?.text = petitions[indexPath.row].title
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.contentMode = .scaleToFill
        cell.detailTextLabel?.text = petitions[indexPath.row].allIssues
        return cell
    }


}

