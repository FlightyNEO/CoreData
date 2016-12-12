//
//  EditingCourseViewController.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 10.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "EditingCourseViewController.h"
#import "DataManager.h"

#import "EditingUserViewController.h"
#import "CourseUsersViewController.h"

#import "Course+CoreDataClass.h"
#import "User+CoreDataClass.h"


@interface EditingCourseViewController () <UITextFieldDelegate>

@property (weak, nonatomic) UITextField *nameField;
@property (weak, nonatomic) UITextField *subjectField;
@property (weak, nonatomic) UITextField *sectorField;
@property (weak, nonatomic) UITextField *professorField;

@property (strong, nonatomic) NSArray<User *> *users;

@property (strong, nonatomic) NSIndexPath *editUserIndexPath;

@end

@implementation EditingCourseViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _enableEditing = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSLog(@"COURSE - %@", _course.name);
    NSLog(@"PROFESSOR - %@ %@", _course.teacher.firstName, _course.teacher.lastName);
    
    if (_enableEditing) {
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                  target:self
                                                                                  action:@selector(actionSave:)];
        self.navigationItem.rightBarButtonItem = saveItem;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (_course.students.count > 0) {
        _users = [self createUsers];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (UITextField *)createDetailTextFieldWithFrame:(CGRect)frame isEnabled:(BOOL)flag {
    
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.delegate = self;
    textField.enabled = flag;
    
    return textField;
}

- (NSArray *)createUsers {
    
    NSFetchRequest *fetchRequest = [User fetchRequest];
    
    NSSortDescriptor *firstNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    [fetchRequest setSortDescriptors:@[firstNameSortDescriptor, lastNameSortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"studesCourses CONTAINS %@", _course];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:fetchRequest error:nil];
    
    for (User *user in results) {
        NSLog(@"%@ %@", user.firstName, user.lastName);
    }
    
    return results;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_enableEditing || _course.students.count > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 4;
            break;
        case 1: {
            if (_enableEditing) {
                return _course.students.count + 1;
            } else {
                return _course.students.count;
            }
        }
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Course";
            break;
        case 1:
            return @"Students";
            break;
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellEdit" forIndexPath:indexPath];
        }
            break;
        case 1: {
            
            if (indexPath.row == 0 && _enableEditing) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CellAddUser" forIndexPath:indexPath];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CellUser" forIndexPath:indexPath];
            }
        }
            break;
    }
    
    [self configureCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell.reuseIdentifier isEqualToString:@"CellEdit"]) {
        
        UITextField *detail = [self createDetailTextFieldWithFrame:CGRectMake(CGRectGetWidth(cell.frame) - 200 - 20,
                                                                              (CGRectGetHeight(cell.frame) - 30) / 2,
                                                                              200,
                                                                              30)
                                                         isEnabled:_enableEditing];
        [cell addSubview:detail];
        
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = @"Course name";
                detail.text = _course.name ? _course.name : nil;
                _nameField = detail;
            }
                break;
            case 1: {
                cell.textLabel.text = @"Subject";
                detail.text = _course.subject ? _course.subject : nil;
                _subjectField = detail;
            }
                break;
            case 2: {
                cell.textLabel.text = @"Sector";
                detail.text =  _course.sector ? _course.sector : nil;
                _sectorField = detail;
            }
                break;
            case 3: {
                cell.textLabel.text = @"Teacher";
                detail.text = _course.teacher ? [NSString stringWithFormat:@"%@ %@", _course.teacher.firstName, _course.teacher.lastName] : nil;
                detail.placeholder = @"Select teacher";
                _professorField = detail;
            }
                break;
        }
        
    } else if ([cell.reuseIdentifier isEqualToString:@"CellUser"]) {
        
        if (_users) {
            User *user;
            if (_enableEditing) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                user = _users[indexPath.row - 1];
            } else {
                user = _users[indexPath.row];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 1 && indexPath.row > 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        User *user = _users[indexPath.row - 1];
        
        [_course removeStudents:[NSSet setWithObject:user]];
        
        [[DataManager sharedManager] saveContext];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_enableEditing && indexPath.section == 1 && indexPath.row > 0) {
        [self showStudentUser];
    }
    
}

#pragma mark - Actions

- (void)actionSave:(id)sender {
    
    if (!_course) {
        
        Course *course = [[Course alloc] initWithContext:[DataManager sharedManager].persistentContainer.viewContext];
        
        // If appropriate, configure the new managed object.
        course.name = _nameField.text;
        course.subject = _subjectField.text;
        course.sector = _sectorField.text;
        
    } else {
        
        _course.name = _nameField.text;
        _course.subject = _subjectField.text;
        _course.sector = _sectorField.text;
    }
    
    [[DataManager sharedManager] saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ([textField isEqual:_professorField]) {
        
        [self showTeacherUser];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"CourseUsers"]) {
        
        UINavigationController *nc = [segue destinationViewController];
        
        CourseUsersViewController *vc = (CourseUsersViewController *)nc.topViewController;
        vc.navigationItem.title = @"Students";
        vc.type = UsersViewControllerWithStudents;
        vc.course = _course;
    }
}

- (void)showTeacherUser {
    CourseUsersViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CourseUsersViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vc.navigationItem.title = @"Teacher";
    vc.type = UsersViewControllerWithTeacher;
    vc.course = _course;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)showStudentUser {
    _editUserIndexPath = [self.tableView indexPathForSelectedRow];
    User *user = _users[_editUserIndexPath.row - 1];
    
    EditingUserViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditingUserViewController"];
    vc.user = user;
    vc.enableEditing = NO;
    vc.navigationItem.title = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end







