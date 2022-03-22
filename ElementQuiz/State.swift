//
//  State.swift
//  ElementQuiz
//
//  Created by Park JooHyun on 2022/03/22.
//

import Foundation

class Element {
    let name: String
    var misstimes: Int
    
    init(name: String) {
        self.name = name
        self.misstimes = 0
    }
    
    func updateMissTimes() {
        misstimes += 1
    }
}
