//
//  UserSelectionViewController.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 10.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "CoreDataTabTableViewController.h"

//#import "EditingCourseViewController.h"

typedef enum {
    UsersCountSomeUsers = 1,
    UsersCountOnceUser = 2
} UsersCountType;

typedef enum {
    UsersTypeTeachers = 1,
    UsersTypeStudents = 2
} UsersType;

@class Course, User;

@protocol UserSelectionViewControllerDelegate;

@interface UserSelectionViewController : CoreDataTabTableViewController

@property (assign, nonatomic) UsersCountType type;
@property (assign, nonatomic) UsersType usersType;

@property (weak, nonatomic) id<UserSelectionViewControllerDelegate> delegate;

@property (strong, nonatomic) Course *course;
@property (strong, nonatomic) NSMutableArray<User *> *users;

@end

@protocol UserSelectionViewControllerDelegate <NSObject>

- (void)saveUsers:(NSArray *)users countType:(UsersCountType)countType andUsersType:(UsersType)usersType;

@end
