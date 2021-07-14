//
//  ViewController.swift
//  Petitions
//
//  Created by Atin Agnihotri on 14/07/21.
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [PetitionModel]()
    var filter = ""
    var filteredList = [PetitionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setNavBar()
        loadDataFromAPI()
        print("Loading complete")
    }
    
    func setNavBar() {
        title = "Petitions"
        // Credits Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        // Filter Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(promptFilter))
    }
    
    @objc func promptFilter() {
        let ac = UIAlertController(title: "Add Filter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submit = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let filterText = ac?.textFields?[0].text else {
                self?.showError(title: "Filter Error", message: "Cannot create an empty filter")
                return
            }
            self?.filter = filterText
            self?.filterPetitions()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let clear = UIAlertAction(title: "Clear Filters", style: .destructive) { [weak self] _ in
            self?.filter = ""
            self?.filterPetitions()
        }
        ac.addAction(submit)
        ac.addAction(cancel)
        ac.addAction(clear)
        present(ac, animated: true)
    }
    
    
    
    func loadDataFromAPI() {
        let urlString: String
            
        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }

        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parseData(data)
            } else {
                showError(title: "Loading Error", message: "Failed to parse data from url")
            }
        } else {
            showError(title: "Loading Error", message: "Failed to fetch data from url")
        }
        
        filterPetitions()
    }
    
    @objc func showCredits() {
        showAlert(title: "Credits", message: "This data comes from the We The People API of the Whitehouse")
    }
    
    func showError(title: String, message: String) {
        showAlert(title: "⚠️ " + title, message: message)
    }
    
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        ac.addAction(ok)
        present(ac, animated: true)
    }
    
    func parseData(_ json: Data) {
        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode(PetitionResultsModel.self, from: json) {
            petitions = decodedData.results
            tableView.reloadData()
        } else {
            showError(title: "Loading Error", message: "Failed to decode data from url")
        }
    }
    
    func filterPetitions() {
        filteredList.removeAll(keepingCapacity: true)
        if filter == "" {
            filteredList = petitions
        } else {
            for petition in petitions {
                let lowerFilter = filter.lowercased()
                let lowerTitle = petition.title.lowercased()
                if lowerTitle.contains(lowerFilter) {
                    filteredList.append(petition)
                }
            }
            
            if filteredList.isEmpty {
                showError(title: "Filter Error", message: "No petitions match this particular filter")
                filter = ""
                filteredList = petitions
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Petition", for: indexPath)
        let petition = filteredList[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.contentMode = .scaleToFill
        cell.detailTextLabel?.text = petition.allIssues
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.petition = filteredList[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }


}

