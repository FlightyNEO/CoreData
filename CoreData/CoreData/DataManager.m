//
//  DataManager.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 09.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

+ (DataManager *)sharedManager {
    
    static DataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
    });
    
    return manager;
}

- (void)generateAndAddUniversity {
    
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                               inManagedObjectContext:self.persistentContainer.viewContext];
    user.firstName = @"Arkadiy";
    user.lastName = @"Grigoryanc";
    user.eMail = @"dragon_500@mail.ru";
    
    User *user2 = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                inManagedObjectContext:self.persistentContainer.viewContext];
    user2.firstName = @"Dmitriy";
    user2.lastName = @"Kozlov";
    user2.eMail = @"kaschejka@mail.ru";
    
    User *user3 = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                inManagedObjectContext:self.persistentContainer.viewContext];
    user3.firstName = @"Yan";
    user3.lastName = @"Karlov";
    user3.eMail = @"yan-yah@mail.ru";
    
    
    NSError *error = nil;
    if (![_persistentContainer.viewContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    NSFetchRequest *fetchRequest = [User fetchRequest];
    //[fetchRequest setResultType:NSDictionaryResultType];
    NSArray *results = [self.persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    
    if (!results) {
        NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    for (User *user in results) {
        NSLog(@"%@ %@", user.firstName, user.lastName);
    }
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"CoreData"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
