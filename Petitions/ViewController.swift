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
//    var tag: Int
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setNavBar()
        performSelector(inBackground: #selector(loadDataFromAPI), with: nil)
//        loadDataFromAPI()
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
    
    @objc func getActiveTab() -> Int {
        var activeTab = 0
        DispatchQueue.main.async { [weak self] in
            activeTab = self?.navigationController?.tabBarItem.tag ?? 0
        }
        return activeTab
    }
    
    @objc func loadDataFromAPI() {
        let urlString: String
//        let tag = getActiveTab()
        // Here we aren't doing any work on the UI in background thread, just fetching the current value, so it's fine
        if self.navigationController?.tabBarItem.tag == 0 {
//        if tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        // GCD Queues are FIFO
        // Importance of code depends on QoS (Quality of Service)
        /*
         User Interactive: this is the highest priority background thread, and should be used when you want a background thread to do work that is important to keep your user interface working. This priority will ask the system to dedicate nearly all available CPU time to you to get the job done as quickly as possible.
         User Initiated: this should be used to execute tasks requested by the user that they are now waiting for in order to continue using your app. It's not as important as user interactive work – i.e., if the user taps on buttons to do other stuff, that should be executed first – but it is important because you're keeping the user waiting.
         The Utility queue: this should be used for long-running tasks that the user is aware of, but not necessarily desperate for now. If the user has requested something and can happily leave it running while they do something else with your app, you should use Utility.
         The Background queue: this is for long-running tasks that the user isn't actively aware of, or at least doesn't care about its progress or when it completes.
         There’s also one more option, which is the default queue. This is prioritized between user-initiated and utility, and is a good general-purpose choice while you’re learning.
         */
//        DispatchQueue.global(qos: .userInitiated).async {
//            [weak self] in
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parseData(data)
            } else {
                performSelector(onMainThread: #selector(showParseError), with: nil, waitUntilDone: false)
            }
        } else {
            performSelector(onMainThread: #selector(showFetchError), with: nil, waitUntilDone: false)
        }
        
        filterPetitions()
    }
    
    @objc func showCredits() {
        showAlert(title: "Credits", message: "This data comes from the We The People API of the Whitehouse")
    }
    
    @objc func showParseError() {
        showError(title: "Loading Error", message: "Failed to parse data from url")
    }
    
    @objc func showFetchError() {
        showError(title: "Loading Error", message: "Failed to fetch data from url")
    }
    
    func showError(title: String, message: String) {
//        DispatchQueue.main.async { [weak self] in
          showAlert(title: "⚠️ " + title, message: message)
//        }
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
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
//            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            
        } else {
            performSelector(onMainThread: #selector(showParseError), with: nil, waitUntilDone: false)
//            showError(title: "Loading Error", message: "Failed to decode data from url")
        }
    }
    
    @objc func showNoMatchingFilterError() {
        showError(title: "Filter Error", message: "No petitions match this particular filter")
    }
    
    @objc func filterPetitions() {
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
                performSelector(onMainThread: #selector(showNoMatchingFilterError), with: nil, waitUntilDone: false)
                filter = ""
                filteredList = petitions
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
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

