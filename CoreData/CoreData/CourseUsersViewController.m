//
//  CourseUsersViewController.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 10.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "CourseUsersViewController.h"

#import "Course+CoreDataClass.h"
#import "User+CoreDataClass.h"

@interface CourseUsersViewController ()

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation CourseUsersViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [User fetchRequest];
    
    //    // Set the batch size to a suitable number.
    //    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *firstNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    [fetchRequest setSortDescriptors:@[firstNameSortDescriptor, lastNameSortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    
    switch (_type) {
        case UsersViewControllerWithStudents: {
            
            if ([_editingCourseViewController.users containsObject:user]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
        case UsersViewControllerWithTeacher: {
            
            if ([_editingCourseViewController.teacher isEqual:user]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                _selectedIndexPath = indexPath;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    switch (_type) {
        case UsersViewControllerWithStudents: {
            
            if ([_editingCourseViewController.users containsObject:user]) {
                //[_course removeStudentsObject:user];
                [_editingCourseViewController.users removeObject:user];
            } else {
                //[_course addStudentsObject:user];
                [_editingCourseViewController.users addObject:user];
            }
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case UsersViewControllerWithTeacher: {
            
            if ([_editingCourseViewController.teacher isEqual:user]) {
                //_course.teacher = NULL;
                _editingCourseViewController.teacher = nil;
            } else {
                //_course.teacher = user;
                _editingCourseViewController.teacher = user;
                
                if (_selectedIndexPath) {
                    [self.tableView reloadRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
                
                _selectedIndexPath = indexPath;
            }
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
    }
    
    
    //[self.managedObjectContext save:nil];
}

#pragma mark - Actions

- (IBAction)actionSave:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end





