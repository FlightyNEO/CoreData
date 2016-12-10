//
//  DataManager.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 09.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

+ (DataManager *)sharedManager;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

- (void)generateAndAddUniversity;

@end
