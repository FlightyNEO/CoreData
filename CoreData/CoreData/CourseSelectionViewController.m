//
//  CourseSelectionViewController.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 15.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "CourseSelectionViewController.h"

#import "University+CoreDataClass.h"
#import "Course+CoreDataClass.h"

@interface CourseSelectionViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation CourseSelectionViewController

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
    
    NSFetchRequest *fetchRequest = [Course fetchRequest];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    if (_searchBar.text.length > 0) {   // if search bar full
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", _searchBar.text];
        [fetchRequest setPredicate:predicate];
    }
    
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
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", course.name];
    
    if (course.university.name.length > 0 &&
        ![course.university isEqual:_university]) {
        
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    switch (_type) {
            
        case CoursesCountSomeCourses: {
            
            if ([_courses containsObject:course]) {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            } else {
                
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
            
        case CoursesCountOnceCourse: {
            
            if ([[_courses firstObject] isEqual:course]) {
                
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
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    switch (_type) {
            
        case CoursesCountSomeCourses: {
            
            if ([_courses containsObject:course]) {
                
                [_courses removeObject:course];
                
            } else {
                
                [_courses addObject:course];
            }
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case CoursesCountOnceCourse: {
            
            if ([[_courses firstObject] isEqual:course]) {
                
                _courses = nil;
                
            } else {
                
                _courses = [NSMutableArray arrayWithObject:course];
                
                if (_selectedIndexPath) {
                    
                    [self.tableView reloadRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
                
                _selectedIndexPath = indexPath;
            }
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
    }
}

#pragma mark - Actions

- (IBAction)actionSave:(id)sender {
    
    [_delegate saveCourses:_courses countType:_type];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _fetchedResultsController = nil;
    [self.tableView reloadData];
}

@end
