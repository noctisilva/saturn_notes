//
//  Note.swift
//  Saturn_InterviewProj_THM
//
//  Created by Tae Hong Min on 7/8/20.
//  Copyright © 2020 Interview. All rights reserved.
//

import Foundation
import RealmSwift

public enum NoteStatus: String {
    case local
    case server
}

@objcMembers public class LocalNote: Object {
    dynamic var id = 0
    dynamic var image_id = ""
    dynamic var localId: String = ""
    dynamic var imageURL: String = ""
    dynamic var noteText: String = ""
    dynamic var isLocal: Bool = false
    dynamic var isLoading: Bool = false
    dynamic var rawStatus: String = NoteStatus.local.rawValue
    
    var status: NoteStatus {
        get {
            return NoteStatus.init(rawValue: rawStatus) ?? NoteStatus.local
        }
        set {
            rawStatus = newValue.rawValue
        }
    }
    
    static func from(newNote: NewNoteUpload, realm: Realm) -> LocalNote {
        return realm.create(LocalNote.self, value: LocalNote().apply { it in
            it.noteText = newNote.title
            it.image_id = newNote.image_id
        }, update: .all)
    }
    
    func toURL() -> URL? {
        if let url = URL(string: imageURL) {
            return url
        }
        return nil
    }
    
    func toNewNoteUpload(noteText: String, imgId: String) -> NewNoteUpload {
        return NewNoteUpload(title: noteText, image_id: imgId)
    }
    
    func updateStatusDidUpload() -> LocalNote{
        let realm = try! Realm()
        DispatchQueue.main.async {
            try! realm.write {
                self.status = .server
                self.isLoading = false
            }
        }
        return self
    }
    
    func updateStatusStartLoading() -> LocalNote{
        let realm = try! Realm()
        DispatchQueue.main.async {
            try! realm.write {
                self.isLoading = true
            }
        }
        return self
    }
    
    func updateStatusNotLoading(completion: @escaping(Bool) -> ()) {
        let realm = try! Realm()
        DispatchQueue.main.async {
            try! realm.write {
                self.isLoading = false
                completion(true)
            }
        }
    }
    
    func fetchNote(completion: @escaping(LocalNote?) -> ()) {

        let realm = try! Realm()
        DispatchQueue.main.async {
            let note = realm.objects(LocalNote.self).filter("localId==%@", self.localId)
            completion(note.first)
        }
    }
    
    
}
