//
//  CourseUsersViewController.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 10.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "CoreDataTabTableViewController.h"

typedef enum {
    UsersViewControllerWithStudents = 1,
    UsersViewControllerWithTeacher = 2
} UsersViewController;

@class Course;

@interface CourseUsersViewController : CoreDataTabTableViewController

@property (assign, nonatomic) UsersViewController type;

@property (strong, nonatomic) Course *course;

@end
