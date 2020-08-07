//
//  Network.swift
//  Saturn_InterviewProj_THM
//
//  Created by Tae Hong Min on 7/7/20.
//  Copyright © 2020 Interview. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import RealmSwift
import SDWebImage

public protocol NetworkDelegate: NSObject {
    func getNotes(notes: [LocalNote])
    func refreshData()
}

public class NetworkService {
    var urlString = URLComponents(string: "https://env-develop.saturn.engineering")
    public weak var delegate: NetworkDelegate?
    var localService: LocalService?
    //var hasNetwork : Bool = false
    
    public init() {
        localService = LocalService()
        //hasNetwork = SReachability.shared.isNetworkAvailable
        hasNetwork { network in
            if network {
                self.getAllNotes()
            } else {
                self.localService?.getNotesLocal { response in
                    self.delegate?.getNotes(notes: response)
                }
            }
        }
    }
    
    func hasNetwork(completion: @escaping(Bool) -> ()) {
        DispatchQueue.main.async {
            let hasNetwork = SReachability.shared.isNetworkAvailable
            completion(hasNetwork)
        }
    }
    
    //In retrospect I p r o b a b l y should have used combine to subscribe the operations in order but this works too for the sake of interview
    func uploadNoteLocal(img: UIImage, note: LocalNote) {
        guard let localService = localService, note.status == .local else { return }
        localService.uploadImageLocal(imgID: note.image_id, img: img) {
            localService.uploadNoteLocal(note: note) { didSuceeed in
//                self.hasNetwork = SReachability.shared.isNetworkAvailable
                self.hasNetwork { network in
                    if network {
                        guard let imgData = img.jpegData(compressionQuality: 0.3) else { return }
                        self.uploadNoteAsync(note: note, imgData: imgData) { response in
                            self.delegate?.refreshData()
                            return
                        }
                    } else {
                        note.updateStatusNotLoading { didSuceeed in
                            if didSuceeed {
                                self.delegate?.refreshData()
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func retryUploadingNote(note: LocalNote, completion: @escaping(LocalNote) -> ()) {
        self.localService?.getImageFromLocal(key: note.image_id) { noteImage in
            if let noteImage = noteImage {
                guard let imgData = noteImage.jpegData(compressionQuality: 0.3) else { return }
                self.uploadNoteAsync(note: note, imgData: imgData) { response in
                    completion(response)
                }
            }
        }

    }
    
    func uploadNoteAsync(note: LocalNote, imgData: Data, completion: @escaping(LocalNote) -> ()) {
        uploadImage(imgData: imgData) { imgId in
            guard let imgId = imgId else {
                //attempt to upload again
                return
            }
            self.uploadNote(note: note.toNewNoteUpload(noteText: note.noteText, imgId: imgId)) { response in
                if let response = response, response {
                    let note = note.updateStatusDidUpload()
                    completion(note)
                    print("uploadNoteAsync: successfully uploaded note!")
                }
            }
        }
    }
    
    
    func getNote(uniqueID: String, completion: @escaping(LocalNote?) -> ()) {
        if let localService = localService {
            localService.getNote(uniqueID: uniqueID) { note in
                completion(note)
            }
        }
    }
    
    func getAllNotes() {
        fetchNotes { response in
            switch response {
            case .success(let notes):
                let notes: [NoteResponse] = notes.reversed() // .reversed could be optimized but in a real life scenario, this situation would never happen.
                //Delete this later. Temporarily bringing only top 10.
                let top10Notes: [NoteResponse] = Array(notes.prefix(10))
                self.transformNoteResponseToNote(noteResponse: top10Notes) { (offlineNotes, error) in
                    if error == nil {
                        if let offlineNotes = offlineNotes {
                            self.delegate?.getNotes(notes: offlineNotes)
                        }
                    }
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }

    func transformNoteResponseToNote(noteResponse: [NoteResponse], completion: @escaping([LocalNote]?, Error?) -> ()) {
        let notes : [LocalNote] = noteResponse.map { note in
            let offlineNote = LocalNote()
            offlineNote.id = note.id
            offlineNote.noteText = note.title
            offlineNote.status = .server
            offlineNote.isLoading = false
            if let noteImage = note.image {
                offlineNote.image_id = noteImage.id
                offlineNote.imageURL = noteImage.size_urls.small
            }
            return offlineNote
        }
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(notes)
                completion(notes, nil)
            }
        } catch let e {
            completion(nil, e)
        }
    }
    
    func fetchNotes(completion: @escaping (Result<[NoteResponse], AFError>) -> ()) {
        urlString?.path = "/api/v2/test-notes"
        guard let url = urlString?.url else { return }
        AF.request(url)
            .validate()
            .responseDecodable(of: [NoteResponse].self, decoder: JSONDecoder()) { response in
                completion(response.result)
            }
    }
    
    func uploadImage(imgData: Data, completion: @escaping (String?) -> ()) {
        urlString?.path = "/api/v2/test-notes/photo"
        guard let imgUrl = urlString?.url else { return }
        AF.upload(multipartFormData: { (multipart) in
            multipart.append(imgData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
        }, to: imgUrl).responseJSON { (response) in
            switch response.result {
                case .success(let payload):
                    guard let dict = payload as? [String: Any], let imageID = dict["id"] as? String else {
                        print("There is no id in your payload response. Please check for errors. Perhaps your server for any model changes.")
                        return
                    }
                    completion(imageID)
                    break
                case .failure(let e):
                    completion(e.errorDescription)
                    break
            }
        }
    }
    
    func uploadNote(note: NewNoteUpload, completion: @escaping (Bool?) -> ()) {
        urlString?.path = "/api/v2/test-notes"
        guard let noteUrl = urlString?.url else { return }
        let parameters = ["title": note.title, "image_id": note.image_id]
        AF.request(noteUrl, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseDecodable(of: NoteResponse.self, decoder: JSONDecoder()) { response in
                switch response.result {
                    case .success(_):
                        completion(true)
                    case .failure(let error):
                        print("Failed to upload note to server. Error Message: \(error)")
                        completion(false)
                }
        }
    }
}

/*
 todo:
 - upload to the cloud
 */
