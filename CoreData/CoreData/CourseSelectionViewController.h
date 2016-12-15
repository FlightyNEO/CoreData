//
//  CourseSelectionViewController.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 15.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "CoreDataTabTableViewController.h"

typedef enum {
    CoursesCountSomeCourses = 1,
    CoursesCountOnceCourse = 2
} CoursesCountType;

@class Course;

@protocol CourseSelectionViewControllerDelegate;

@interface CourseSelectionViewController : CoreDataTabTableViewController

@property (assign, nonatomic) CoursesCountType type;

@property (weak, nonatomic) id<CourseSelectionViewControllerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray<Course *> *courses;

@end

@protocol CourseSelectionViewControllerDelegate <NSObject>

- (void)saveCourses:(NSArray *)courses countType:(CoursesCountType)countType;

@end
