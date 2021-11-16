//
//  APIRequest.swift
//  FSQ Nearby Places
//
//  Created by Lyubomir Lazarov on 11/2/21.
//

import Foundation
import UIKit

class APIRequest {
    
    var mainViewController: ViewController?
     static let shared = APIRequest()

    func fetchNearbyPlaces(forLocation location: String, numberOfPlaces limit: Int, completion: @escaping (Result<FoursResponse, Error>) -> Void) {

        let url = URL(string: "https://api.foursquare.com/v2/venues/search")!

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "ll", value: location),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "v", value: "20211104"),
            URLQueryItem(name: "client_id", value: "43LFZZZSA2MOZ3KP4GPT4KNNE0KCWWF03NVWMHXHV5TJP3MH"),
            URLQueryItem(name: "client_secret", value: "ITQ0L1XGMRNQV125TUD5E4352DS0VXIQCUQMRJEAV4RSFOFV")
        ]
        let placeURL = components.url!
        let task = URLSession.shared.dataTask(with: placeURL) { data, response, error in
            if let data = data {
                do {
                    guard let placesResponse = try? JSONDecoder().decode(FoursResponse.self, from: data) else {
                        print("No decodable response from server. The account ran out of free requests.")
                        return
                    }
                    completion(.success(placesResponse))
                }
            } else if let error = error {
                    completion(.failure(error))
                    
            }
        }
        task.resume()
          
    }
    
}
