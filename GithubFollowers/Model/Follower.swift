//
//  Follower.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-07.
//

import Foundation

struct Follower: Codable, Hashable {
    var login: String
    var avatarUrl: String
}
