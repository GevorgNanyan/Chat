//Chat.swift
/*
 * ChatUI
 * Created by Gevor Nanyan on 03.04.24.
 * Is a product created by abnboys
 * For the ChatUI in the ChatUI
 
 * Here the permission is granted to this file with free of use anywhere in the IOS Projects.
*/

import UIKit

struct Chat: Codable {
    var user_name: String
    var user_image_url: String
    var is_sent_by_me: Bool
    var text: String
    var type: fileType
    var file_url: String
    var estimated_Height: Int
    
    enum CodingKeys: String, CodingKey {
        case user_name
        case user_image_url
        case is_sent_by_me
        case text
        case type
        case file_url
        case estimated_Height
    }
}

enum fileType: String, Codable {
    case photo
    case video
    case text
}


