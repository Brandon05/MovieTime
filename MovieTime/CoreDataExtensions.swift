//
//  CoreDataExtensions.swift
//  MovieTime
//
//  Created by Brandon Sanchez on 2/9/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol CoreData {
    
}

extension CoreData {
    // MARK: Delete Data Records
    
    func deleteRecords() -> Void {
        
        let moc = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WatchLaterMovie")
        
        //        let fetchRequest: NSFetchRequest<WatchLaterMovie>
        //        if #available(iOS 10.0, OSX 10.12, *) {
        //            fetchRequest = WatchLaterMovie.fetchRequest()
        //        } else {
        //            fetchRequest = fetchRequest(entityName: "WatchLaterMovie")
        //        }
        
        let result = try? moc.fetch(fetchRequest)
        let resultData = result as! [WatchLaterMovie]
        
        for object in resultData {
            moc.delete(object)
        }
        
        do {
            try moc.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    // MARK: Get Context
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK:- Clear all data in UserDefaults
    func clearDefaults() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    // MARK:- Cast NSManagedObject to Movie
    func typeMovie(_ movies: [WatchLaterMovie]) -> [Movie] {
        var castedMovies = [Movie]()
        // A flatmap method may be better? Guard against nil
        for result in movies {
            let castedMovie = Movie(title: result.title!, overview: result.overview!, posterPath: result.posterPath!, backdropPath: result.backdropPath!, voteAverage: result.voteAverage as! Double, voteCount: Int(result.voteCount!), id: Int(result.id!))
            castedMovies.append(castedMovie)
        }
        // return reversed so the latest saved movie is first
        return castedMovies.reversed()
    }
    
    func typeNSManagedObject(_ movie: Movie) -> NSManagedObject {
        //var watchLaterMovie = WatchLaterMovie()
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "WatchLaterMovie", in: context)
        var watchLaterMovie = NSManagedObject(entity: entity!, insertInto: nil)
        
        
        watchLaterMovie.setValue(movie.title, forKey: "title")
        watchLaterMovie.setValue(movie.overview, forKey: "overview")
        watchLaterMovie.setValue(movie.posterPath, forKey: "posterPath")
        watchLaterMovie.setValue(movie.backdropPath, forKey: "backdropPath")
        watchLaterMovie.setValue(movie.voteAverage, forKey: "voteAverage")
        watchLaterMovie.setValue(movie.voteCount, forKey: "voteCount")
        watchLaterMovie.setValue(movie.id, forKey: "id")
        print(watchLaterMovie)
        return watchLaterMovie
    }
    
    func removeData(for movie: Movie) {
        let context = getContext()
        let request: NSFetchRequest<WatchLaterMovie>
        if #available(iOS 10.0, OSX 10.12, *) {
            request = WatchLaterMovie.fetchRequest()
        } else {
            request = NSFetchRequest(entityName: "WatchLaterMovie")
        }

        let castedMovie = typeNSManagedObject(movie)
        
        do {
            let results = try context.fetch(request) as [WatchLaterMovie]
            
            // Cast NSManagedObject from core data to type Movie and append
            let movieToDelete = results.filter({$0.id == (movie.id as NSNumber)})//results.first(where: {$0.id == movie.id})//results.filter{($0 == castedMovie)}
            print(results[0])
            print(movieToDelete)
            context.delete(movieToDelete[0])
            try context.save()
        } catch {
            print("Fetching Failed")
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension WatchLaterViewController: CoreData {
    
    func getData() {
        let context = getContext()
        let request: NSFetchRequest<WatchLaterMovie>
        if #available(iOS 10.0, OSX 10.12, *) {
            request = WatchLaterMovie.fetchRequest()
        } else {
            request = NSFetchRequest(entityName: "WatchLaterMovie")
        }
        
        do {
            let results = try context.fetch(request) as [WatchLaterMovie]
            
            // Cast NSManagedObject from core data to type Movie and append

            watchLaterAll = typeMovie(results)
            watchLaterFiltered = typeMovie(results)

            watchLaterCollectionView.reloadData()
            refreshControl.endRefreshing()
        } catch {
            print("Fetching Failed")
        }
    }
    
    func removeData(for movie: Movie) {
        let context = getContext()
        let movieToDelete = typeNSManagedObject(movie)
        context.delete(movieToDelete)
        
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
//        // MARK:- Cast NSManagedObject to Movie
//    func typeMovie(_ movies: [WatchLaterMovie]) -> [Movie] {
//        var castedMovies = [Movie]()
//        // A flatmap method may be better? Guard against nil
//        for result in movies {
//        let castedMovie = Movie(title: result.title!, overview: result.overview!, posterPath: result.posterPath!, backdropPath: result.backdropPath!, voteAverage: result.voteAverage as! Double, voteCount: Int(result.voteCount!), id: Int(result.id!))
//            castedMovies.append(castedMovie)
//        }
//        // return reversed so the latest saved movie is first
//        return castedMovies.reversed()
//    }
    
    // Beacause I am casting NSManagedObject into the struct Movie and then appending to the collectionviewdatasource, movies are duplicated on each fetchRequest()
    // EDIT:- Not needed, I just appened casted core data to watchLaterAll and Filtered
    func removeDuplicateMovies(in movies: [Movie]) -> [Movie] {
        var alreadyThere = Set<Movie>()
        let uniquePosts = movies.flatMap { (movie) -> Movie? in
            guard !alreadyThere.contains(movie) else { return nil }
            alreadyThere.insert(movie)
            return movie
        }
        return uniquePosts.reversed()
    }
    

    
}

extension DetailViewController: CoreData {
    
    func save(_ watchLaterMovie: Movie) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "WatchLaterMovie", in: managedContext)!
        print(entity)
        let watchLaterMovie = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        watchLaterMovie.setValue(movie.title, forKey: "title")
        watchLaterMovie.setValue(movie.overview, forKey: "overview")
        watchLaterMovie.setValue(movie.posterPath, forKey: "posterPath")
        watchLaterMovie.setValue(movie.backdropPath, forKey: "backdropPath")
        watchLaterMovie.setValue(movie.voteAverage, forKey: "voteAverage")
        watchLaterMovie.setValue(movie.voteCount, forKey: "voteCount")
        watchLaterMovie.setValue(movie.id, forKey: "id")
        
        // 4 Save the data to coredata
        do {
            try  appDelegate.saveContext()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
       
    }
    
//    func removeData(for movie: Movie) {
////        let context = getContext()
////        context.delete(movie)
////        context.save()
//    }
}
