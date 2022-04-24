//
//  Date+Ext.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-24.
//

import Foundation

extension Date {
    
    func convertToMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: self)
    }
}

