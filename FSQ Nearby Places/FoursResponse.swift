// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - FoursResponse
struct FoursResponse: Codable {
    let meta: Meta
    let response: Response
}

// MARK: - Meta
struct Meta: Codable {
    let code: Int
    let requestID: String

    enum CodingKeys: String, CodingKey {
        case code
        case requestID = "requestId"
    }
}

// MARK: - Response
struct Response: Codable {
    let venues: [Venue]
    let confident: Bool
}

// MARK: - Venue
struct Venue: Codable {
    let id, name: String
    let location: VenueLocation
    let categories: [Category]
    let referralID: String
    let hasPerk: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, location, categories
        case referralID = "referralId"
        case hasPerk
    }
    
    
    
}

extension Venue: Comparable {
    static func < (lhs: Venue, rhs: Venue) -> Bool {
        lhs.location.distance < rhs.location.distance
    }
    
    static func == (lhs: Venue, rhs: Venue) -> Bool {
        lhs.location.distance == rhs.location.distance && lhs.name == rhs.name
    }
    
    
}

// MARK: - Category
struct Category: Codable {
    let id, name, pluralName, shortName: String
    let icon: Icon
    let primary: Bool
}

// MARK: - Icon
struct Icon: Codable {
    let iconPrefix: String
    let suffix: String

    enum CodingKeys: String, CodingKey {
        case iconPrefix = "prefix"
        case suffix
    }
}

// MARK: - Location
struct VenueLocation: Codable {
    let address: String?
    let lat, lng: Double
    let labeledLatLngs: [LabeledLatLng]
    let distance: Int
    let postalCode: String?
    let cc, city, state, country: String
    let formattedAddress: [String]
    let neighborhood: String?
}

// MARK: - LabeledLatLng
struct LabeledLatLng: Codable {
    let label: String
    let lat, lng: Double
}



