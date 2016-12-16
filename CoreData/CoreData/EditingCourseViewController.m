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
#import "UserSelectionViewController.h"

#import "UIBarButtonItem+UIBarButtonItemCustomButton.h"

#import "University+CoreDataClass.h"
#import "Course+CoreDataClass.h"
#import "User+CoreDataClass.h"

@interface EditingCourseViewController () <UITextFieldDelegate, UserSelectionViewControllerDelegate>

@property (weak, nonatomic) UITextField *nameField;
@property (weak, nonatomic) UITextField *subjectField;
@property (weak, nonatomic) UITextField *sectorField;
@property (weak, nonatomic) UITextField *univesityField;
@property (weak, nonatomic) UITextField *teacherField;

@property (strong, nonatomic) NSMutableArray<User *> *students;
@property (strong, nonatomic) User *teacher;

@property (strong, nonatomic) NSArray<User *> *currentStudents;
@property (strong, nonatomic) User *currentTeacher;

@property (strong, nonatomic) NSIndexPath *editUserIndexPath;

@end

@implementation EditingCourseViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _enableEditing = YES;
        _students = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSLog(@"COURSE - %@", _course.name);
    NSLog(@"TEACHER - %@ %@", _course.teacher.firstName, _course.teacher.lastName);
    
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
    
    _teacher = _course.teacher;
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (_course) {  // if edit course
        
        if (![[NSSet setWithArray:_currentStudents] isEqual:_course.students]) {
            _currentStudents = [[self createStudents] mutableCopy];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:_currentStudents];
            for (User *user in _students) {
                if (![_currentStudents containsObject:user] && user.firstName.length > 0) {
                    [array addObject:user];
                }
            }
            _students = array;
        }
        
        if (![_currentTeacher.firstName isEqual:_course.teacher.firstName]) {
            
            _currentTeacher = _course.teacher;
        }
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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

- (NSArray *)createStudents {
    
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

- (void)changeCourse {
    _course.name        = _nameField.text;
    _course.subject     = _subjectField.text;
    _course.sector      = _sectorField.text;
    [_course setTeacher:_teacher];
    [_course setStudents:[NSSet setWithArray:_students]];
    [_course.university setStudents:_course.students];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
            
        case 0: {
            return 5;
        } break;
            
        case 1: {
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
        } break;
            
        case 1: {
            if (indexPath.row == 0 && _enableEditing) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CellAddUser" forIndexPath:indexPath];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CellUser" forIndexPath:indexPath];
            }
        } break;
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
            } break;
            
            case 1: {
                cell.textLabel.text = @"Subject";
                
                detail.text = _course.subject ? _course.subject : nil;
                _subjectField = detail;
            } break;
            
            case 2: {
                cell.textLabel.text = @"Sector";
                
                detail.text = _course.sector ? _course.sector : nil;
                _sectorField = detail;
            } break;
                
            case 3: {
                cell.textLabel.text = @"University";
                
                detail.text = _course.university.name.length > 0 ? [NSString stringWithFormat:@"%@", _course.university.name] : @"";
                _univesityField = detail;
            } break;
                
            case 4: {
                cell.textLabel.text = @"Teacher";
                
                detail.text = _teacher.firstName.length > 0 ? [NSString stringWithFormat:@"%@ %@", _teacher.firstName, _teacher.lastName] : @"";
                detail.placeholder = @"Select teacher";
                _teacherField = detail;
            } break;
        }
        
    } else if ([cell.reuseIdentifier isEqualToString:@"CellUser"]) {
        
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
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (_enableEditing && indexPath.section == 1 && indexPath.row > 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [_students removeObjectAtIndex:indexPath.row - 1];
        
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
        indexPath.section == 1  &&
        indexPath.row > 0) {
        
        [self showStudentUser];
    }
}

#pragma mark - Verification filling

- (BOOL)verificationFillingOfFieldsForBack {
    
    if ((_enableEditing)    &&
        
        (_nameField.text.length > 0     ||
         _subjectField.text.length > 0  ||
         _sectorField.text.length > 0   ||
         _teacher.firstName.length > 0  ||
         _students.count > 0            ||
         _course)   &&
        
        (![_course.name isEqualToString:_nameField.text]                        ||
         ![_course.subject isEqualToString:_subjectField.text]                  ||
         ![_course.sector isEqualToString:_sectorField.text]                    ||
         (![_course.teacher isEqual:_teacher] && _teacher.firstName.length > 0) ||
         _teacher.firstName.length == 0                                         ||
         ![_course.students isEqual:[NSSet setWithArray:_students]])) {
            
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
        
        if (results.count > 0 && ![_course.name isEqualToString:_nameField.text]) {
            
            [self presentSaveAlertWithMessage:@"This name is exist"];
            return NO;
            
        }
        
        return YES;
    }
    
    [self presentSaveAlertWithMessage:@"Fill course name"];
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
        
        if (!_course) {
            _course = [[Course alloc] initWithContext:[DataManager sharedManager].persistentContainer.viewContext];
        }
        
        [self changeCourse];
        
        NSLog(@"%@", _course.teacher);
        
        [[DataManager sharedManager] saveContext];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:_nameField]) {
        [_subjectField becomeFirstResponder];
    } else if ([textField isEqual:_subjectField]) {
        [_sectorField becomeFirstResponder];
    } else if ([textField isEqual:_sectorField]) {
        [_teacherField becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ([textField isEqual:_teacherField]) {
        
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
    
    if ([segue.identifier isEqualToString:@"CourseStudents"]) {
        
        UINavigationController *nc = [segue destinationViewController];
        
        UserSelectionViewController *vc = (UserSelectionViewController *)nc.topViewController;
        vc.navigationItem.title = @"Students";
        vc.type = UsersCountSomeUsers;
        //vc.usersType = UsersTypeStudents;
        vc.course = _course;
        vc.users = _students;
        vc.delegate = self;
    }
}

- (void)showTeacherUser {
    UserSelectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserSelectionViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vc.navigationItem.title = @"Teacher";
    vc.type = UsersCountOnceUser;
    //vc.usersType = UsersTypeTeachers;
    //vc.course = _course;
    vc.users = _teacher != nil ? [NSMutableArray arrayWithObject:_teacher] : nil;
    vc.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)showStudentUser {
    _editUserIndexPath = [self.tableView indexPathForSelectedRow];
    User *user = _students[_editUserIndexPath.row - 1];
    
    EditingUserViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditingUserViewController"];
    vc.user = user;
    vc.enableEditing = NO;
    vc.navigationItem.title = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UserSelectionViewControllerDelegate

- (void)saveUsers:(NSArray *)users countType:(UsersCountType)countType andUsersType:(UsersType)usersType {
    if (countType == UsersCountOnceUser) {
        _teacher = [users firstObject];
    } else if (countType == UsersCountSomeUsers) {
        _students = [users mutableCopy];
    }
}

@end







