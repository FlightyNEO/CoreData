//
//  CoursesViewController.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 10.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "CoursesViewController.h"
#import "EditingCourseViewController.h"

#import "Course+CoreDataClass.h"

typedef enum {
    CourseTypeAll = 0,
    CourseTypeWithTeacher = 1,
    CourseTypeWithoutTeacher = 2
} CourseType;

typedef enum {
    CourseFilterSubject = 0,
    CourseFilterSector = 1
} CourseFilter;

@interface CoursesViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeCoursesControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterCoursesControl;

@end

@implementation CoursesViewController

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
    NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *sortSubjectDescriptor = [[NSSortDescriptor alloc] initWithKey:@"subject" ascending:YES];
    NSSortDescriptor *sortSectorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sector" ascending:YES];
    NSString *sectionNameKeyPath = nil;
    switch (_filterCoursesControl.selectedSegmentIndex) {
        case CourseFilterSubject: {
            sectionNameKeyPath = @"subject";
            [fetchRequest setSortDescriptors:@[sortSubjectDescriptor, sortNameDescriptor]];
        } break;
        case CourseFilterSector: {
            sectionNameKeyPath = @"sector";
            [fetchRequest setSortDescriptors:@[sortSectorDescriptor, sortNameDescriptor]];
        } break;
    }
    
    // Edit predicate
    NSPredicate *predicate = nil;
    
    NSMutableArray *arguments = [NSMutableArray array];
    if (_searchBar.text.length > 0) {
        for (int i = 0; i < 4; i++) {
            [arguments addObject:_searchBar.text];
        }
    }
    
    switch (_typeCoursesControl.selectedSegmentIndex) {
        
        case CourseTypeWithTeacher: {
            
            if (_searchBar.text.length > 0) {
                predicate = [NSPredicate predicateWithFormat:
                             @"teacher != NULL AND "
                             "(name CONTAINS[c] %@ OR "
                             "subject CONTAINS[c] %@ OR "
                             "sector CONTAINS[c] %@ OR "
                             "teacher.firstName CONTAINS[c] %@)"
                                               argumentArray:arguments];
            } else {
                predicate = [NSPredicate predicateWithFormat:@"teacher != NULL"];
            }
        } break;
        
        case CourseTypeWithoutTeacher: {
            
            if (_searchBar.text.length > 0) {
                predicate = [NSPredicate predicateWithFormat:
                             @"teacher == NULL AND "
                             "(name CONTAINS[c] %@ OR "
                             "subject CONTAINS[c] %@ OR "
                             "sector CONTAINS[c] %@)"
                                               argumentArray:arguments];
            } else {
                predicate = [NSPredicate predicateWithFormat:@"teacher == NULL"];
            }
        } break;
        
        default: {
            
            if (_searchBar.text.length > 0) {
                predicate = [NSPredicate predicateWithFormat:
                             @"name CONTAINS[c] %@ OR "
                             "subject CONTAINS[c] %@ OR "
                             "sector CONTAINS[c] %@ OR "
                             "teacher.firstName CONTAINS[c] %@"
                                               argumentArray:arguments];
            }
            
        } break;
    }
    
    [fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:sectionNameKeyPath
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _fetchedResultsController.sections[section].name;
}

- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = course.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    EditingCourseViewController *vc = [segue destinationViewController];
    vc.enableEditing = YES;
    if ([segue.identifier isEqualToString:@"EditCourse"]) {
        vc.course = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        vc.navigationItem.title = @"Editing course";
    } else {
        vc.navigationItem.title = @"Add course";
    }
}

#pragma mark - Actions

- (IBAction)changeTypeCourses:(id)sender {
    _fetchedResultsController = nil;
    [self.tableView reloadData];
}

- (IBAction)changeFilterCourses:(id)sender {
    _fetchedResultsController = nil;
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _fetchedResultsController = nil;
    [self.tableView reloadData];
}

@end






