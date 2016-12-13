//
//  Section.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 12.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Section : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray<User *> *users;

@end
