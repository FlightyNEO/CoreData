//
//  UsersViewController.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 09.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "UsersViewController.h"
#import "EditingUserViewController.h"

#import "DataManager.h"

#import "Section.h"
#import "User+CoreDataClass.h"

typedef enum {
    UsersTypeAll = 0,
    UsersTypeStudents = 1,
    UsersTypeTeachers = 2
} UsersType;

typedef enum {
    UsersFilterName = 0,
    UsersFilterLastName = 1
} UsersFilter;

@interface UsersViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeUsersControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *usersFilterControl;

@property (strong, nonatomic) NSArray<User *> *users;

@property (strong, nonatomic) NSMutableArray<Section *> *sections;

@property (strong, nonatomic) NSArray *letters;

@property (strong, nonatomic) NSOperation *currentOperation;

@end

@implementation UsersViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        //_type = UsersTypeAll;
        //self.navigationItem.title = @"Users";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [[DataManager sharedManager] generateAndAddUniversity];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    _users = [self createUsers];
    
    [self generateSectionsInBackgroundFromArray:_users withFilter:self.searchBar.text];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (NSArray *)createUsers {
    
    NSFetchRequest *fetchRequest = [User fetchRequest];
    
    // Edit the sort key as appropriate.
    NSArray<NSSortDescriptor *> *descriptors;
    NSSortDescriptor *firstNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    
    switch (_usersFilterControl.selectedSegmentIndex) {
        case UsersFilterName:
            descriptors = @[firstNameSortDescriptor, lastNameSortDescriptor];
            break;
        case UsersFilterLastName:
            descriptors = @[lastNameSortDescriptor, firstNameSortDescriptor];
            break;
    }
    
    // Edit predicate
    NSPredicate *predicate = nil;
    switch (_typeUsersControl.selectedSegmentIndex) {
        case UsersTypeTeachers:
            predicate = [NSPredicate predicateWithFormat:@"teachesCourses.@count > %d", 0];
            break;
        case UsersTypeStudents:
            predicate = [NSPredicate predicateWithFormat:@"studesCourses.@count > %d", 0];
            break;
    }
    
    [fetchRequest setSortDescriptors:descriptors];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:20];
    
    return [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:fetchRequest error:nil];
}

- (void)generateSectionsInBackgroundFromArray:(NSArray *)array withFilter:(NSString *)filterString {
    
    [self.currentOperation cancel];
    
    __weak UsersViewController *weakSelf = self;
    
    self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSArray *sectionsArray = [self generateSectionsFromArray:array withFilter:filterString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.sections = [sectionsArray mutableCopy];
            [weakSelf.tableView reloadData];
            
            self.currentOperation = nil;
        });
    }];
    
    [self.currentOperation start];
}

- (NSArray *)generateSectionsFromArray:(NSArray *)array withFilter:(NSString *)filterString {
    
    NSString *currentName = nil;
    NSString *currentLastName = nil;
    
    NSMutableArray *sectionsArray = [NSMutableArray array];
    
    for (User *user in array) {
        
        if (filterString.length > 0 &&
            [user.firstName rangeOfString:filterString options:NSCaseInsensitiveSearch].location == NSNotFound &&
            [user.lastName rangeOfString:filterString options:NSCaseInsensitiveSearch].location == NSNotFound) {
            
            continue;
        }
        
        UsersFilter filter = (UsersFilter)self.usersFilterControl.selectedSegmentIndex;
        switch (filter) {
            case UsersFilterName: {
                
                NSString *name = [user.firstName substringToIndex:1];
                
                Section *section = nil;
                
                if (![currentName isEqualToString:name]) {
                    
                    section = [[Section alloc] init];
                    section.name = name;
                    section.users = [NSMutableArray array];
                    
                    currentName = name;
                    
                    [sectionsArray addObject:section];
                    
                } else {
                    
                    section = [sectionsArray lastObject];
                    
                }
                
                [section.users addObject:user];
            }
                break;
                
            case UsersFilterLastName: {
                
                NSString *lastName = [user.lastName substringToIndex:1];
                
                Section *section = nil;
                
                if (![currentLastName isEqualToString:lastName]) {
                    
                    section = [[Section alloc] init];
                    section.name = lastName;
                    section.users = [NSMutableArray array];
                    
                    currentLastName = lastName;
                    
                    [sectionsArray addObject:section];
                    
                } else {
                    
                    section = [sectionsArray lastObject];
                    
                }
                
                [section.users addObject:user];
            }
                break;
        }
    }
    
    return sectionsArray;
}

#pragma mark - UITableViewDataSource

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (Section *section in self.sections) {
        
        [array addObject:section.name];
        
    }
    
    return array;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section] users].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sections[section] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    User *user = [self.sections[indexPath.section] users][indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:
                           @"%@ %@",
                           user.firstName,
                           user.lastName];
    
    switch (_typeUsersControl.selectedSegmentIndex) {
        case UsersTypeTeachers:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", user.teachesCourses.count];
            break;
        case UsersTypeStudents:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", user.studesCourses.count];
            break;
        default:
            cell.detailTextLabel.text = @"";
            break;
    }

    cell.detailTextLabel.textColor = [UIColor blueColor];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.tableView beginUpdates];
        
        // remove user from CoreData
        NSManagedObjectContext *context = [DataManager sharedManager].persistentContainer.viewContext;
        NSManagedObject *object = _sections[indexPath.section].users[indexPath.row];
        [context deleteObject:object];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
        
        // remove user from data for table view
        if (_sections[indexPath.section].users.count == 1) {
            [_sections removeObjectAtIndex:indexPath.section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                          withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            [_sections[indexPath.section].users removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationLeft];
        }
        
        [self.tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    EditingUserViewController *vc = [segue destinationViewController];
    vc.enableEditing = YES;
    if ([segue.identifier isEqualToString:@"EditUser"]) {
        //EditingUserViewController *vc = [segue destinationViewController];
        vc.user = _sections[[self.tableView indexPathForSelectedRow].section].users[[self.tableView indexPathForSelectedRow].row];
        vc.navigationItem.title = @"Editing user";
    } else if ([segue.identifier isEqualToString:@"AddUser"]) {
        vc.navigationItem.title = @"Add user";
    }
}

#pragma mark - Actions

- (IBAction)changeTypeUsers:(UISegmentedControl *)sender {
    //_fetchedResultsController = nil;
    //[self.tableView reloadData];
    
    _users = [self createUsers];
    [self generateSectionsInBackgroundFromArray:_users withFilter:self.searchBar.text];
    
}
- (IBAction)changeFilterUsers:(UISegmentedControl *)sender {
    //_fetchedResultsController = nil;
    //[self.tableView reloadData];
    _users = [self createUsers];
    [self generateSectionsInBackgroundFromArray:_users withFilter:self.searchBar.text];
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
    [self generateSectionsInBackgroundFromArray:_users withFilter:searchText];
}

@end








