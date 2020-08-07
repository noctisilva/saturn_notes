//
//  NotePayload.swift
//  Saturn_InterviewProj_THM
//
//  Created by Tae Hong Min on 7/9/20.
//  Copyright © 2020 Interview. All rights reserved.
//
//  Comments:
//  We're only bringing in small for sake of tableviewcell size. No need to bring in additional data
//

import Foundation

struct NoteResponse: Decodable {
    let id: Int
    let title: String
    let image: NoteImgPayload?
}

struct NoteImgPayload: Decodable {
    let id: String
    let size_urls: NoteImgURLS
}

struct NoteImgURLS: Decodable {
    let small: String
}

struct NewNoteUpload: Codable {
    let title: String
    let image_id: String
}
