//
//  LocalService.swift
//  Saturn_InterviewProj_THM
//
//  Created by Tae Hong Min on 7/10/20.
//  Copyright © 2020 Interview. All rights reserved.
//

import Foundation
import RealmSwift
import SDWebImage

public typealias didSuceeed = (Bool) -> Void

public class LocalService {
    private var realm: Realm!
    
    init() {
        self.realm = try! Realm()
    }
    
    func uploadNoteLocal(note: LocalNote, completion: @escaping (didSuceeed)) {
        DispatchQueue.main.async {
            try! self.realm.write {
                self.realm.add(note)
                print("Note uploaded locally successfully!")
                completion(true)
            }
        }
    }
    
    func uploadImageLocal(imgID: String, img: UIImage, completion: @escaping () -> ()) {
        guard let imgData = UIImage(data: img.jpegData(compressionQuality: 0.3)!) else {
            print("Failed to compress image. Please try again.")
            return
        }
        DispatchQueue.main.async { // Called on main queue to load after uploading in the table
            SDImageCache.shared.store(imgData, forKey: imgID, toDisk: true) {
                completion()
            }
        }
    }
    
    func getNotesLocal(completion: @escaping ([LocalNote])->()) {
        DispatchQueue.main.async {
            let localNotes = Array(self.realm.objects(LocalNote.self))
            completion(localNotes)
        }
    }
    
    func getNote(uniqueID: String, completion: @escaping(LocalNote?) -> ()) {
        DispatchQueue.main.async {
            let note = self.realm.objects(LocalNote.self).filter("localId==%@", uniqueID)
            completion(note.first)
        }
    }
    
    func getImageFromLocal(key: String, completion: @escaping(UIImage?) -> ()) {
        DispatchQueue.main.async {
            let image = SDImageCache.shared.imageFromCache(forKey: key)
            completion(image)
        }
    }
}

/*
todo:
- retrying failed uploads once connection is available
- saving to local and uploading to the sky
*/
