//
//  EditingUserViewController.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 09.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface EditingUserViewController : UITableViewController

@property (strong, nonatomic) User *user;

@property (assign, nonatomic, getter=isEnableEditing) BOOL enableEditing;

@end
