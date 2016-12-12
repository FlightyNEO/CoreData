//
//  UsersViewController.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 09.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "CoreDataTabTableViewController.h"

typedef enum {
    UsersTypeAll = 1,
    UsersTypeStudents = 2,
    UsersTypeTeachers = 3
} UsersType;

@interface UsersViewController : CoreDataTabTableViewController

@property (assign, nonatomic) UsersType type;

@end
