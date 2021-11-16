//
//  NearbyViewController.swift
//  FSQ Nearby Places
//
//  Created by Lyubomir Lazarov on 11/2/21.
//

import UIKit
import CoreLocation
import CoreData

class NearbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    var locationManager = CLLocationManager()
    
    var coreDataPlaces: [NSManagedObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.startAnimating()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    var myLocation: Location? {
        didSet {
            let userLocation = myLocation!
            let formattedLocation = "\(userLocation.latitude),\(userLocation.longitude)"
            print("formattedLocation: \(formattedLocation)")
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            APIRequest.shared.fetchNearbyPlaces(forLocation: formattedLocation, numberOfPlaces: 5) { result in
                print("ima rezultat")
                switch result {
                case .success(let resultItems):
                    DispatchQueue.main.async {
                        self.delete()
                        for i in 0...4 {
                            self.save(name: resultItems.response.venues[i].name, distance: resultItems.response.venues[i].location.distance)
                        }
                        self.load()
                        self.tableView.reloadData()
                        
                    }
                case.failure(let error):
                    self.displayError(error, title: "Failure")
                    DispatchQueue.main.async {
                        self.load()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func displayError(_ error: Error, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func save(name: String, distance: Int) {
      
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "PlaceEntity", in: managedContext)!

        let place = NSManagedObject(entity: entity, insertInto: managedContext)
        place.setValue(name, forKeyPath: "name")
        place.setValue(distance, forKey: "distance")

        do {
          try managedContext.save()
          coreDataPlaces.append(place)
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func load() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
          
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PlaceEntity")
        
        let sort = NSSortDescriptor(key: "distance", ascending: true)
        fetchRequest.sortDescriptors = [sort]

        do {
            coreDataPlaces = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func delete() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: "PlaceEntity")

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        deleteRequest.resultType = .resultTypeObjectIDs

        let managedContext = appDelegate.persistentContainer.viewContext

        var batchDelete = NSBatchDeleteResult()
        
        do {
            batchDelete = try managedContext.execute(deleteRequest) as! NSBatchDeleteResult
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        guard let deleteResult = batchDelete.result as? [NSManagedObjectID] else { return }

        let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]

        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [managedContext])

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            myLocation = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }

    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let status = manager.authorizationStatus
    let preciseLocation = manager.accuracyAuthorization
    switch status {
        case .restricted, .denied:
          presentStartupAlert(title: "Authorization Needed", message: "The app cannot function properly without permission to use location", actionTitle: "Okay")
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
          if preciseLocation == .fullAccuracy && isFirstLaunch() {
              presentStartupAlert(title: "Welcome", message: "This app will show you the five nearest venues on Foursquare", actionTitle: "Continue")
              locationManager.requestLocation()
          } else if preciseLocation == .reducedAccuracy{
              presentStartupAlert(title: "Precise Location Needed", message: "The app cannot function properly without permission to use precise location", actionTitle: "Okay")
          }
        case .notDetermined:
          break
        @unknown default:
          print("Unknown")
        }
    }


    func presentStartupAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func isFirstLaunch() -> Bool {
        if (!UserDefaults.standard.bool(forKey: "launched_before")) {
            UserDefaults.standard.set(true, forKey: "launched_before")
            return true
        }
        return false
    }
    
    //MARK: Table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        configureCell(cell, forItemAt: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        let placeItem = coreDataPlaces[indexPath.row]
        cell.textLabel?.text = placeItem.value(forKeyPath: "name") as? String
        cell.detailTextLabel?.text = ("\(String(placeItem.value(forKeyPath: "distance") as? Int ?? 0))m")
    }
 
}
