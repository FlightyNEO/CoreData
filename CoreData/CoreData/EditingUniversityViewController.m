//
//  EditingUniversityViewController.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 15.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "EditingUniversityViewController.h"
#import "DataManager.h"

#import "EditingUserViewController.h"
#import "EditingCourseViewController.h"

#import "UserSelectionViewController.h"
#import "CourseSelectionViewController.h"

#import "UIBarButtonItem+UIBarButtonItemCustomButton.h"

#import "University+CoreDataClass.h"
#import "Course+CoreDataClass.h"
#import "User+CoreDataClass.h"

@interface EditingUniversityViewController () <UITextFieldDelegate, UserSelectionViewControllerDelegate, CourseSelectionViewControllerDelegate>

@property (weak, nonatomic) UITextField *nameField;

@property (strong, nonatomic) NSMutableArray<Course *> *courses;
@property (strong, nonatomic) NSMutableArray<User *> *students;
@property (strong, nonatomic) NSMutableArray<User *> *teachers;

@property (strong, nonatomic) NSArray<Course *> *currentCourses;
@property (strong, nonatomic) NSArray<User *> *currentTeachers;
@property (strong, nonatomic) NSArray<User *> *currentStudents;

@property (strong, nonatomic) NSIndexPath *editUserIndexPath;

@end

@implementation EditingUniversityViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _enableEditing = YES;
        _courses = [NSMutableArray array];
        _students = [NSMutableArray array];
        _teachers = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Edit left bar button item
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self
                                                                                  action:@selector(actionBack)
                                                                               tintColor:self.view.tintColor];
    
    // Edit rigth bar button item
    if (_enableEditing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                               target:self
                                                                                               action:@selector(actionSave)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (_university) {  // if edit course
        
        if (![[NSSet setWithArray:_currentCourses] isEqual:_university.courses]) {
            _currentCourses = [[self createCourses] mutableCopy];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:_currentCourses];
            for (Course *course in _courses) {
                if (![_currentCourses containsObject:course] && course.name.length > 0) {
                    [array addObject:course];
                }
            }
            _courses = array;
        }
        
        if (![[NSSet setWithArray:_currentTeachers] isEqual:_university.teachers]) {
            _currentTeachers = [[self createTeachers] mutableCopy];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:_currentTeachers];
            for (User *user in _teachers) {
                if (![_currentTeachers containsObject:user] && user.firstName.length > 0) {
                    [array addObject:user];
                }
            }
            _teachers = array;
        }
        
        if (![[NSSet setWithArray:_currentStudents] isEqual:_university.students]) {
            _currentStudents = [[self createStudents] mutableCopy];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:_currentStudents];
            for (User *user in _students) {
                if (![_currentStudents containsObject:user] && user.firstName.length > 0) {
                    [array addObject:user];
                }
            }
            _students = array;
        }
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
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
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.returnKeyType = UIReturnKeyNext;
    
    return textField;
}

- (NSArray *)createCourses {
    
    NSFetchRequest *fetchRequest = [Course fetchRequest];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"university == %@", _university];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:fetchRequest error:nil];
    
    for (Course *course in results) {
        NSLog(@"%@", course.name);
    }
    
    return results;
}

- (NSArray *)createTeachers {
    
    NSFetchRequest *fetchRequest = [User fetchRequest];
    
    NSSortDescriptor *firstNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    [fetchRequest setSortDescriptors:@[firstNameSortDescriptor, lastNameSortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teachersUniversity CONTAINS %@", _university];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:fetchRequest error:nil];
    
    for (User *user in results) {
        NSLog(@"%@ %@", user.firstName, user.lastName);
    }
    
    return results;
}

- (NSArray *)createStudents {
    
    NSFetchRequest *fetchRequest = [User fetchRequest];
    
    NSSortDescriptor *firstNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    [fetchRequest setSortDescriptors:@[firstNameSortDescriptor, lastNameSortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"studentsUniversity == %@", _university];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:fetchRequest error:nil];
    
    for (User *user in results) {
        NSLog(@"%@ %@", user.firstName, user.lastName);
    }
    
    return results;
}

- (void)changeUniversity {
    _university.name        = _nameField.text;
    [_university setCourses:[NSSet setWithArray:_courses]];
    [_university setTeachers:[NSSet setWithArray:_teachers]];
    [_university setStudents:[NSSet setWithArray:_students]];
}

#pragma mark - Alerts

- (void)presentBackAlert {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Apply modifications?"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionDestructive = [UIAlertAction actionWithTitle:@"Apply"
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [self actionSave];
                                                              }];
    UIAlertAction *actionDefault = [UIAlertAction actionWithTitle:@"Do not apply"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    [alert addAction:actionDestructive];
    [alert addAction:actionDefault];
    [alert addAction:actionCancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentSaveAlertWithMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ERROR!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [_nameField becomeFirstResponder];
                                                   }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
            
        case 0: {
            return 1;
        } break;
            
        case 1: {
            if (_enableEditing) {
                return _courses.count + 1;
            } else {
                return _courses.count;
            }
        } break;
            
        case 2: {
            if (_enableEditing) {
                return _teachers.count + 1;
            } else {
                return _teachers.count;
            }
        } break;
            
        case 3: {
            if (_enableEditing) {
                return _students.count + 1;
            } else {
                return _students.count;
            }
        } break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"University";
            break;
        case 1:
            return @"Courses";
            break;
        case 2:
            return @"Teachers";
            break;
        case 3:
            return @"Students";
            break;
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifire;
    
    if (indexPath.section == 0) {
        
        identifire = @"CellEdit";
    
    } else {
        
        if (indexPath.row == 0 && _enableEditing) {
            
            switch (indexPath.section) {
                case 1:
                    identifire = @"CellAddCourse";
                    break;
                case 2:
                    identifire = @"CellAddTeacher";
                    break;
                case 3:
                    identifire = @"CellAddStudent";
                    break;
            }
            
        } else {
            
            identifire = @"Cell";
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifire forIndexPath:indexPath];
    
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
        cell.textLabel.text = @"Course name";
        detail.text = _university.name ? _university.name : nil;
        _nameField = detail;
        
    } else if ([cell.reuseIdentifier isEqualToString:@"Cell"]) {
        
        switch (indexPath.section) {
                
            case 1: {
                
                if (_courses) {
                    Course *course;
                    if (_enableEditing) {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        course = _courses[indexPath.row - 1];
                    } else {
                        course = _courses[indexPath.row];
                    }
                    cell.textLabel.text = [NSString stringWithFormat:@"%@", course.name];
                }
                
            } break;
            
            case 2: {
                
                if (_teachers) {
                    User *user;
                    if (_enableEditing) {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        user = _teachers[indexPath.row - 1];
                    } else {
                        user = _teachers[indexPath.row];
                    }
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                }
                
            } break;
                
            case 3: {
                
                if (_students) {
                    User *user;
                    if (_enableEditing) {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        user = _students[indexPath.row - 1];
                    } else {
                        user = _students[indexPath.row];
                    }
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                }
                
            } break;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section > 0 && indexPath.row > 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        switch (indexPath.section) {
            
            case 1: {
                [_courses removeObjectAtIndex:indexPath.row - 1];
            } break;
            
            case 2: {
                [_teachers removeObjectAtIndex:indexPath.row - 1];
            } break;
                
            case 3: {
                [_students removeObjectAtIndex:indexPath.row - 1];
            } break;
        }
        
        [[DataManager sharedManager] saveContext];
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_enableEditing          &&
        indexPath.row > 0) {
        
        switch (indexPath.section) {
            case 1:
                [self showCourse];
                break;
            case 2:
                [self showUser:UsersTypeTeachers];
                break;
            case 3:
                [self showUser:UsersTypeStudents];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Verification filling

- (BOOL)verificationFillingOfFieldsForBack {
    
    if ((_enableEditing)    &&
        
        (_nameField.text.length > 0 ||
         _courses.count > 0         ||
         _teachers.count > 0        ||
         _students.count > 0        ||
         _university)   &&
        
        (![_university.name isEqualToString:_nameField.text]                ||
         ![_university.courses isEqual:[NSSet setWithArray:_courses]]       ||
         ![_university.teachers isEqual:[NSSet setWithArray:_teachers]]     ||
         ![_university.students isEqual:[NSSet setWithArray:_students]])) {
            
            [self presentBackAlert];
            return NO;
            
        }
    
    return YES;
}

- (BOOL)verificationFillingOfFieldsForSave {
    
    if (_nameField.text.length > 0) {
        
        NSFetchRequest *fetchRequest = [Course fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", _nameField.text];
        [fetchRequest setPredicate:predicate];
        NSArray *results = [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:fetchRequest error:nil];
        
        if (results.count > 0 && ![_university.name isEqualToString:_nameField.text]) {
            
            [self presentSaveAlertWithMessage:@"This name is exist"];
            return NO;
            
        }
        
        return YES;
    }
    
    [self presentSaveAlertWithMessage:@"Fill university name"];
    return NO;
}

#pragma mark - Actions

- (void)actionBack {
    
    [self.view endEditing:YES];
    
    if ([self verificationFillingOfFieldsForBack]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionSave {
    
    [self.view endEditing:YES];
    
    if ([self verificationFillingOfFieldsForSave ]) {
        
        if (!_university) {
            _university = [[University alloc] initWithContext:[DataManager sharedManager].persistentContainer.viewContext];
        }
        
        [self changeUniversity];
        
        [[DataManager sharedManager] saveContext];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UINavigationController *nc = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"UniversityTeachers"]) {
        
        UserSelectionViewController *vc = (UserSelectionViewController *)nc.topViewController;
        vc.delegate = self;
        vc.type = UsersCountSomeUsers;
        vc.navigationItem.title = @"Teachers";
        vc.usersType = UsersTypeTeachers;
        vc.users = _teachers;
        
    } else if ([segue.identifier isEqualToString:@"UniversityStudents"]) {
        
        UserSelectionViewController *vc = (UserSelectionViewController *)nc.topViewController;
        vc.delegate = self;
        vc.type = UsersCountSomeUsers;
        vc.navigationItem.title = @"Students";
        vc.usersType = UsersTypeStudents;
        vc.users = _students;
        
    } else if ([segue.identifier isEqualToString:@"UniversityCourses"]) {
        
        CourseSelectionViewController *vc = (CourseSelectionViewController *)nc.topViewController;
        vc.delegate = self;
        vc.type = CoursesCountSomeCourses;
        vc.navigationItem.title = @"Courses";
        vc.courses = _courses;
    }
}

- (void)showCourse {
    _editUserIndexPath = [self.tableView indexPathForSelectedRow];
    Course *course = _courses[_editUserIndexPath.row - 1];
    
    EditingCourseViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditingCourseViewController"];
    vc.course = course;
    vc.enableEditing = NO;
    vc.navigationItem.title = [NSString stringWithFormat:@"%@", course.name];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showUser:(UsersType)type {
    _editUserIndexPath = [self.tableView indexPathForSelectedRow];
    User *user;
    switch (type) {
        case UsersTypeTeachers:
            user = _teachers[_editUserIndexPath.row - 1];
            break;
        case UsersTypeStudents:
            user = _students[_editUserIndexPath.row - 1];
            break;
    }
    
    EditingUserViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditingUserViewController"];
    vc.user = user;
    vc.enableEditing = NO;
    vc.navigationItem.title = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UserSelectionViewControllerDelegate

- (void)saveUsers:(NSArray *)users countType:(UsersCountType)countType andUsersType:(UsersType)usersType {
    
    if (countType == UsersCountSomeUsers) {
        
        switch (usersType) {
            
            case UsersTypeTeachers:
                _teachers = [users mutableCopy];
                break;
            
            case UsersTypeStudents:
                _students = [users mutableCopy];
                break;
        }
    }
}

#pragma mark - CourseSelectionViewControllerDelegate

- (void)saveCourses:(NSArray *)courses countType:(CoursesCountType)countType {
    
    if (countType == CoursesCountSomeCourses) {
        
        _courses = [courses mutableCopy];
    }
}

@end












