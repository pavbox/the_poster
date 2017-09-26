//
//  fetch_data_pav.swift
//  theposter
//
//  Created by Admin on 17/09/2017.
//  Copyright © 2017 pavbox. All rights reserved.
//

import UIKit

typealias postDictionary = [[String: Any?]]

class FetchData: NSObject {

    // why string become Optional in other classes?
    public let API_ADDR = "http://178.62.217.59:3020/api/v1"
    
    private let postCollection = PostCollection()
    
    
    private struct PostModel: Decodable {
        var _id: String?
        var title: String?
        var description: String?
        var hashtag: String?
        var imageName: String?
        
        func dictionaryRepresents() -> [String: Any?] {
            return [
                "id": self._id,
                "title": self.title,
                "description": self.description,
                "hashtag": self.hashtag,
                "imageName": self.imageName
            ]
        }
    }
    
    
    private struct responseJSON: Decodable {
        var status: String?
        var code  : String?
        var body: [PostModel]
        
        var dictionary: postDictionary {
            var dict: postDictionary = []
            
            for item in body {
                dict.append(item.dictionaryRepresents())
            }
            return dict
        }
    }
    
    

    
    public func removePostById(_ id: String) {
        guard let url = URL(string: "\(self.API_ADDR)/post/\(id)") else { return }
    
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print("catch error on sending post \(error)")
                }
            }
        }.resume();
    }
    
    
    public func savePostToDatabase(description: String, hashtag: String, image: String = "", isUpdate: Bool, _ callback: @escaping (String) -> Void) {
        
        let parameters = [
            "title": description,
            "hashtag": hashtag,
            "description": description,
            "imageName": "\(image)"
        ]
        
        guard let url = URL(string: "\(self.API_ADDR)/post/\(image)") else { return }
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        
        var request = URLRequest(url: url)
        
        if isUpdate {
            request.httpMethod = "PUT"
        } else {
            request.httpMethod = "POST"
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        var decodeJson: responseJSON?
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                // guard let decodeJson: responseJSON = try? JSONDecoder().decode(responseJSON.self, from: data) else { return }
                do {
                    decodeJson = try JSONDecoder().decode(responseJSON.self, from: data)
                    callback((decodeJson!.dictionary)[0]["id"] as! String)
                } catch {
                    print(error)
                }
            }
        }.resume();
    }
    
    
    
    
    // Download table list
    public func downloadPostList(_ callback: @escaping (postDictionary) -> Void ) {
        guard let url = URL(string: "\(self.API_ADDR)/post") else { return }
        
        var decodeJson: responseJSON?
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                // guard let decodeJson: responseJSON = try? JSONDecoder().decode(responseJSON.self, from: data) else { return }
                do {
                    decodeJson = try JSONDecoder().decode(responseJSON.self, from: data)
                    DispatchQueue.main.async() { () -> Void in
                        callback(decodeJson!.dictionary)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    
    // download from url
    public func downloadImage(from link: String, to imageView: UIImageView) {
        guard let url = URL(string: link) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            DispatchQueue.main.async() { () -> Void in
                imageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    
    /**
     * Binary Parse image and send to server
     */
    public func uploadImage(_ image: UIImage, _ id: String) {
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request  = URLRequest(url: URL(string: "\(self.API_ADDR)/post/\(id)/upload")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(parameters: [:],
                                boundary: boundary,
                                data: UIImageJPEGRepresentation(image, 0.5)!,
                                mimeType: "image/jpeg",
                                filename: "\(id).jpeg")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else { print(error!); return }

            do {
                try JSONSerialization.jsonObject(with: data!)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    private func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
}



extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

