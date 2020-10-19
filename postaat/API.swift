//
//  API.swift
//  postaat
//
//  Created by ahmed abdelhameed on 5/6/20.
//  Copyright © 2020 ahmed abdelhameed. All rights reserved.
//

import Foundation
import Alamofire

class API : NSObject {
    
    class func sendTokenToServer(token : String , userName : String,completion : @escaping (_ error :Error? ,_  result :String?) -> Void){
        
        
        let paramater : [String:Any] = ["_username":userName,"_uuid":token]
        
        let header : HTTPHeaders = ["Content-Type":"application/json"]
        print("params \(paramater)")
        
        AF.request("https://www.postat.com/user/change-uuid" , method: .post , parameters: paramater , encoding: JSONEncoding.default, headers: header).responseData { (response) in
         
            switch response.result {
                
            case   .failure(let error):
                completion(error,nil)
                
            case  .success(let value):
                let resultValue = String(decoding: value, as: UTF8.self)
                completion(nil,resultValue)
            }
        }
    }
}
