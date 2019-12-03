//
//  AlbumController.swift
//  Albums
//
//  Created by Lambda_School_Loaner_204 on 12/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

private var persistentFileURL: URL? {
    guard let filePath = Bundle.main.path(forResource: "exampleAlbum", ofType: "json") else { return nil }
    return URL(fileURLWithPath: filePath)
}

private let baseURL = URL(string: "https://ios-albums-u3s1.firebaseio.com/")!

class AlbumController {
    
    var albums: [Album] = []
    
    func getAlbums(completion: @escaping (Error?) -> Void) {
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                print(error)
                completion(error)
                return
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            do {
                self.albums = try jsonDecoder.decode([Album].self, from: data)
                completion(nil)
            } catch {
                print("Error Decoding")
                completion(error)
                return
            }
            
        }.resume()
        
    }
    
    func put(album: Album) {
        
        let uuid = UUID()
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathComponent("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            let jsonEncoder = JSONEncoder()
            request.httpBody = try jsonEncoder.encode(album)
        } catch {
            print("Error encoding album \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Error PUTing album to server \(error)")
            }
        }.resume()
    }
    
    func createAlbum(artist: String, coverArt: String, genres: [String], id: String, name: String, songs: [Song]) {
        let album = Album(artist: artist, coverArt: coverArt, genres: genres, id: id, name: name, songs: songs)
        albums.append(album)
        put(album: album)
    }
    
    func createSong(duration: String, id: String, name: String) -> Song {
        return Song(duration: duration, id: id, name: name)
    }
    
    func update(for album: Album, artist: String, coverArt: String, genres: [String], id: String, name: String, songs: [Song]) {

        guard let albumIndex = albums.firstIndex(of: album) else { return }
        
        albums[albumIndex].artist = artist
        albums[albumIndex].coverArt = coverArt
        albums[albumIndex].genres = genres
        albums[albumIndex].id = id
        albums[albumIndex].name = name
        albums[albumIndex].songs = songs
        put(album: albums[albumIndex])
    }
    
    func testDecodingExampleAlbum() {
        
        guard let fileURL = persistentFileURL else { return }
        
        URLSession.shared.dataTask(with: fileURL) { (data, _, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            do {
                let album = try jsonDecoder.decode(Album.self, from: data)
                print(album)
            } catch {
                print("Error Decoding")
                return
            }
            
        }.resume()
    }
    
    func testEncodingExampleAlbum() {
        
        guard let fileURL = persistentFileURL else { return }
        
        URLSession.shared.dataTask(with: fileURL) { (data, _, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [.prettyPrinted]
            do {
                let album = try jsonDecoder.decode(Album.self, from: data)
                let encodedAlbum = try jsonEncoder.encode(album)
                let albumString = String(data: encodedAlbum, encoding: .utf8)!
                print(albumString)
            } catch {
                print("Error Encoding")
                return
            }
        }.resume()
    }
}

