//
//  ImageDownloader.swift
//  ShowCaseApp
//
//  Created by Federico Enrriquez on 4/20/16.
//  Copyright © 2016 Federico Enrriquez. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ImageStore {
    static var imageCache = NSCache()
    
    static func downloadImage(imgUrl: String, afterDownloadImage: AfterDownloadImage) {
        
        if let img = ImageStore.imageCache.objectForKey(imgUrl) as? UIImage {
            afterDownloadImage(img: img)
        }
        
        Alamofire.request(.GET, imgUrl).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, error in
            if error == nil {
                if let imageData = data {
                    if let newImg = UIImage(data: imageData) {
                        ImageStore.imageCache.setObject(newImg, forKey: imgUrl)
                        afterDownloadImage(img: newImg)
                    }
                }
            } else {
                print(error)
            }
        })
    }
    
    static func uploadImage(img: UIImage, afterUploadImage: AfterUploadImage) {
        let url = NSURL(string: API_URL_IMAGE_SHACK)!
        let imgData = UIImageJPEGRepresentation(img, 0.2)!
        let keyData = API_KEY_IMAGE_SHACK.dataUsingEncoding(NSUTF8StringEncoding)!
        let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
        
        Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpeg")
            multipartFormData.appendBodyPart(data: keyData, name: "key")
            multipartFormData.appendBodyPart(data: keyJSON, name: "format")
        }) { encodingResult in
            
            switch encodingResult {
            case .Success(let upload, _, _):
                upload.responseJSON(completionHandler: { response in
                    if let info = response.result.value as? Dictionary<String, AnyObject> {
                        if let links = info["links"] as? Dictionary<String, String> {
                            if let imageLink = links["image_link"] {
                                afterUploadImage(url: imageLink)
                            }
                        }
                    }
                })
            case .Failure(let error):
                print("Error uploading Picture: \(error)")
            }
        }

    }
}