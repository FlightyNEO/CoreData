//
//  EditingUniversityViewController.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 15.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class University, Course, User;

@interface EditingUniversityViewController : UITableViewController

@property (strong, nonatomic) University *university;

@property (assign, nonatomic, getter=isEnableEditing) BOOL enableEditing;

@end
