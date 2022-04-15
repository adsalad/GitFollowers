//
//  Follower.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-07.
//

import Foundation

struct Follower: Codable, Hashable, Identifiable {
    let id: Int
    let login: String
    let avatarUrl: String
}
