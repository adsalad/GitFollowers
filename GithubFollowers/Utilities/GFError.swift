//
//  GFError.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-20.
//

import Foundation

enum GFError: String, Error {
    case invalidUsername = "This username createde an invalid request. Please try again."
    case invalidRequest = "Unable to complete request. Check your internet!"
    case invalidResponse =  "Invalid response from the server. Please try again"
    case invalidData = "Data recieved from server was invalid. Please try again!"
    case unableToFavourite = "There was an error favourites this user. Please try again."
    case alreadyInFavourites = "You already favourited this user!"
}
