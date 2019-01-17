//
//  APIController.swift
//  Sentiment Bot
//
//  Created by Moin Uddin on 1/9/19.
//  Copyright © 2019 Scott Bennett. All rights reserved.
//

import UIKit
import JWTDecode

class APIController {
    
    static let shared = APIController()
    
    //Signup User
    func signUp(firstName: String, lastName: String, email: String, password: String, completion: @escaping (Error?) -> Void = {_ in }){
        let url = baseUrl.appendingPathComponent("users")
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.post.rawValue
        let userCredentials = ["firstName": firstName, "lastName": lastName, "email": email, "password": password] as [String: Any]
        do {
            let json = try JSONSerialization.data(withJSONObject: userCredentials, options: .prettyPrinted)
            request.httpBody = json
            completion(nil)
        } catch {
            NSLog("Error encoding JSON")
            completion(error)
        }
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            if let error = error {
                NSLog("There was an error signup up the user: \(error)")
                completion(error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                NSLog("Error code from the http request: \(httpResponse.statusCode)")
                completion(error)
                return
            }
            
            NSLog("Successfully signed up User")
            
            self.logIn(email: email, password: password, completion: { (_) in
                completion(nil)
            })
            
            }.resume()
    }
    
    //Login User
    func logIn(email: String, password: String, completion: @escaping (Error?) -> Void = {_ in }) {
        let url = baseUrl.appendingPathComponent("tokens")
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.post.rawValue
        let userCredentials = ["email": email, "password": password] as [String: Any]
        do {
            let json = try JSONSerialization.data(withJSONObject: userCredentials, options: .prettyPrinted)
            request.httpBody = json
            completion(nil)
        } catch {
            NSLog("Error encoding JSON")
            completion(error)
        }
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            if let error = error {
                NSLog("There was an error logging in the user: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                NSLog("Error code from the http request: \(httpResponse.statusCode)")
                completion(error)
                return
            }
            
            do {
                let jwtToken = try JSONDecoder().decode(JWT.self, from: data)
                let jwt = try decode(jwt: jwtToken.jwt)
                let userId = jwt.body["id"] as! Int
                let token = jwt.string
                self.saveCurrentUser(userId: userId, token: token)
            } catch {
                NSLog("Error decoding JSON Web Token \(error)")
                completion(error)
                return
            }
            
            NSLog("Successfully logged in User")
            
            completion(nil)
            }.resume()
    }
    
    func getUser(userId: Int, completion: @escaping (User?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("users")
                         .appendingPathComponent("\(userId)")
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error with getting user: \(error)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                NSLog("Error code from the http request: \(httpResponse.statusCode)")
                completion(nil, error)
                return
            }
            
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let responses = try JSONDecoder().decode(User.self, from: data)
                completion(responses, nil)
            } catch {
                NSLog("Error with network request: \(error)")
                completion(nil, error)
                return
            }
            
            NSLog("Successfully fetched User")
            
            
            }.resume()
        
    }
    
    private func saveCurrentUser(userId: Int, token: String) {
        UserDefaults.standard.set(token, forKey: UserDefaultsKeys.token.rawValue)
        UserDefaults.standard.set(userId, forKey: UserDefaultsKeys.userId.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    //Join a Team
    func joinTeam(code: Int, completion: @escaping (Team?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("join")
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.post.rawValue
        let teamCredentials = ["code": code] as [String: Any]
        do {
            let json = try JSONSerialization.data(withJSONObject: teamCredentials, options: .prettyPrinted)
            request.httpBody = json
        } catch {
            NSLog("Error encoding JSON")
            completion(nil, error)
        }
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            if let error = error {
                NSLog("There was an error sending team code to server: \(error)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                NSLog("Error code from the http request: \(httpResponse.statusCode)")
                completion(nil, error)
                return
            }
            
            do {
                let team = try JSONDecoder().decode(Team.self, from: data)
                completion(team, nil)
            } catch {
                NSLog("Error decoding team \(error)")
                completion(nil, error)
                return
            }
            
            NSLog("User successfully joined Team")
        
            }.resume()
    }
    
    func getUserResponses(userId: Int, completion: @escaping ([Response]?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("users")
                         .appendingPathComponent("\(userId)")
                         .appendingPathComponent("responses")
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.get.rawValue
        
//        guard let token = UserDefaults.standard.token else {
//            NSLog("No JWT Token Set to User Defaults")
//            return
//        }
//
//        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error with getting user responses: \(error)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                NSLog("Error code from the http request: \(httpResponse.statusCode)")
                completion(nil, error)
                return
            }
            
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let responses = try JSONDecoder().decode([Response].self, from: data)
                completion(responses, nil)
            } catch {
                NSLog("Error with network request: \(error)")
                completion(nil, error)
                return
            }
            
            NSLog("Successfully fetched all User Responses")
            
            
        }.resume()
    }
    
    func googleSignIn(email: String, fullName: String, completion: @escaping (User?, Error?) -> Void) {
        
    }
    
    func getTeamMembers(teamId: Int, completion: @escaping ([User]?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("teams")
            .appendingPathComponent("\(teamId)")
            .appendingPathComponent("users")
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error with getting team members: \(error)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                NSLog("Error code from the http request: \(httpResponse.statusCode)")
                completion(nil, error)
                return
            }
            
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                completion(users, nil)
            } catch {
                NSLog("Error with network request: \(error)")
                completion(nil, error)
                return
            }
            
            NSLog("Successfully fetched Team members")
            
            
            }.resume()
    }
    
    func getManagingTeam(userId: Int, completion: @escaping (Team?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("users")
            .appendingPathComponent("\(userId)")
            .appendingPathComponent("teams")
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error with getting user team: \(error)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                NSLog("Error code from the http request: \(httpResponse.statusCode)")
                completion(nil, error)
                return
            }
            
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let team = try JSONDecoder().decode([Team].self, from: data).first
                completion(team, nil)
            } catch {
                NSLog("Error with network request: \(error)")
                completion(nil, error)
                return
            }
            
            NSLog("Successfully fetched User Team")
            
            
            }.resume()
    }
    
    func sendSurveyNotification() {
        //This will be inside
        let emojis = ["😄","😃"]
        localNotificationHelper.getAuthorizationStatus { (status) in
            switch status {
            case .authorized:
                self.localNotificationHelper.sendSurveyNotification(emojis: emojis, schedule: "Daily")
            case .notDetermined:
                self.localNotificationHelper.requestAuthorization(completion: { (granted) in
                    
                    if (granted) {
                        self.localNotificationHelper.sendSurveyNotification(emojis: emojis, schedule: "Daily")
                    }
                })
            default:
                return
            }
        }
    }
    
    //Get Image
    func getImage(url: URL, completion: @escaping (UIImage?, Error?) -> Void = {_,_ in}) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error \(error)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            let image = UIImage(data: data)
            completion(image, error);
            }.resume()
    }
    
    
    
    
    let localNotificationHelper = LocalNotificationHelper()
    //let baseUrl = URL(string: "http://localhost:3000/api")!
    let baseUrl = URL(string: "https://sentimentbot-1.herokuapp.com/api")!
    let prodUrl = URL(string: "https://feelzy-api.herokuapp.com/api")!
}
