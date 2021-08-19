//
//  CurrentUserInfo.swift
//  PlutoGo
//
//  Created by Tarun Sachdeva on 01/06/18.
//  Copyright © 2018 Tsss. All rights reserved.
//

import Foundation

struct CurrentUserInfo {
    
   static var userID : String!
   static var email : String!
   static var name : String!
   static var enrollDate : String!
   static var userType : String!
   static var userPin : String!
   static var phone : String!
   static var status : String!
   
    init(dict : NSDictionary)  {
        //CurrentUserInfo.userInfo = dict
        let data = dict
        print(data)
        
        
        
        if (data["status"] as? NSNull) == nil {
            CurrentUserInfo.status = (data["status"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.status = ""
        }
        
        if (data["email"] as? NSNull) == nil {
            CurrentUserInfo.email = (data["email"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.email = ""
        }
        
        if (data["phone"] as? NSNull) == nil {
            CurrentUserInfo.phone = (data["phone"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.phone = ""
        }
        
        if (data["userPin"] as? NSNull) == nil {
            CurrentUserInfo.userPin = (data["userPin"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.userPin = ""
        }
        
        if (data["userType"] as? NSNull) == nil {
            CurrentUserInfo.userType = (data["userType"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.userType = ""
        }
        
        if ((data["userID"] as? NSNull) == nil){
            CurrentUserInfo.userID = (data["userID"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.userID = ""
        }
        
        if (data["name"] as? NSNull) == nil {
            CurrentUserInfo.name = (data["name"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.name = ""
        }
        
        if (data["enrollDate"] as? NSNull) == nil {
            CurrentUserInfo.enrollDate = (data["dob"].map { $0 as? String } ?? "")!
        }
        else {
            CurrentUserInfo.enrollDate = ""
        }
        
    }
    
}
