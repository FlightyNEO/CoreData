//
//  EditingCourseViewController.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 10.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Course;
@class User;

@interface EditingCourseViewController : UITableViewController

@property (strong, nonatomic) Course *course;

@property (assign, nonatomic, getter=isEnableEditing) BOOL enableEditing;

@property (strong, nonatomic) NSMutableArray<User *> *users;

@property (strong, nonatomic) User *teacher;
@end
