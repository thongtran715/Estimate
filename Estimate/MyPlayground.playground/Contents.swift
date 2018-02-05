//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var projects = ["1", "2", "0"]

// Generate random id
var randomId = "0"
var isGood = true
repeat {
    randomId = String(arc4random_uniform(5))
    for i in 0..<projects.count {
        if (projects[i] == randomId) {
            isGood = false
        }
    }
}while(isGood != true)

print(randomId)
