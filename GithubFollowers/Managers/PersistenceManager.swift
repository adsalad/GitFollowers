//
//  PersistenceManager.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-28.
//

import Foundation


enum PersistenceActionType {
    case add, remove
}

enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let favourites = "favourites"
    }
    
    // Result type type is very useful, but I don't really see the point of a completion handler. I have no choice here...
    // this function updates favourites when user adds a new user to favourites, or removes them
    static func updateWith(favourite: Follower, actionType: PersistenceActionType, completed: @escaping (GFError?) -> Void) {
        retrieveFavourites { result in
            switch result {
            case .success(var favourites):
                                
                switch actionType {
                case .add:
                    guard !favourites.contains(favourite) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    favourites.append(favourite)
                    
                case .remove:
                    favourites.removeAll { $0.login == favourite.login }
                }
                
                completed(saveFavourites(favourites: favourites))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    // retrieves favourites from UserDefaults
    static func retrieveFavourites(completed: @escaping (Result<[Follower], GFError>) -> Void) {
        // first time access/retrieval
        guard let favouritesData = defaults.object(forKey: Keys.favourites) as? Data else {
            completed(.success([]))
            return
        }
        
        // otherwise, decode what was retrieved from user defaults
        do {
            let decoder = JSONDecoder()
            let favourites = try decoder.decode([Follower].self, from: favouritesData)
            completed(.success(favourites))
        } catch {
            completed(.failure(.alreadyInFavorites))
        }
    }
    
    // save favourites to UserDefaults
    static func saveFavourites(favourites: [Follower]) -> GFError? {
        
        do {
            let encoder = JSONEncoder()
            let encodedFavourites = try encoder.encode(favourites)
            defaults.set(encodedFavourites, forKey: Keys.favourites)
            return nil
        } catch {
            return .alreadyInFavorites
        }
    }
}
