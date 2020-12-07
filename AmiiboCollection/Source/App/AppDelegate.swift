//
//  AppDelegate.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// Shortcut to accessing the user *Documents* directory.
    static var applicationDocumentsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }()
    
    /// Main container for CoreData.
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AmiiboModels")
        container.loadPersistentStores { (storeDescription, error)
            in
            if let error = error {
                fatalError("Could not load data store: \(error)")
            }
        }
        return container
    }()
    
    /// Object storage location for CoreData.
    private lazy var managedObjectContext: NSManagedObjectContext =
                         persistentContainer.viewContext
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AmiiboManager.shared.managedObjectContext = managedObjectContext
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
