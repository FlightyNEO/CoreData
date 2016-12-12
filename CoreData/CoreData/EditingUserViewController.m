//
//  EditingUserViewController.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 09.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "EditingUserViewController.h"
#import "DataManager.h"

#import "EditingCourseViewController.h"

#import "User+CoreDataClass.h"
#import "Course+CoreDataClass.h"

@interface EditingUserViewController ()

@property (weak, nonatomic) UITextField *firstNameField;
@property (weak, nonatomic) UITextField *lastNameField;
@property (weak, nonatomic) UITextField *eMailField;

@property (strong, nonatomic) NSArray <Course *> *teachesCourses;
@property (strong, nonatomic) NSArray <Course *> *studesCourses;

@property (strong, nonatomic) NSIndexPath *editUserIndexPath;

@end

@implementation EditingUserViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _enableEditing = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@", _user.firstName);
    
    if (_user.teachesCourses.count > 0) {
        _teachesCourses = [self createTeachesCourses];
    }
    if (_user.studesCourses.count > 0) {
        _studesCourses = [self createStudesCourses];
    }
    
    if (_enableEditing) {
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                  target:self
                                                                                  action:@selector(actionSave:)];
        self.navigationItem.rightBarButtonItem = saveItem;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (NSFetchRequest *)createFetchRequestWithEntity:(id)entity andSort:(NSString *)sort {
    NSFetchRequest *fetchRequest = [entity fetchRequest];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sort ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    return fetchRequest;
}

- (NSArray *)createTeachesCourses {
    NSFetchRequest *fetchRequest = [self createFetchRequestWithEntity:[Course class] andSort:@"name"];
    NSPredicate *teachesCoursesPredicate = [NSPredicate predicateWithFormat:@"teacher == %@", _user];
    [fetchRequest setPredicate:teachesCoursesPredicate];
    return [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:fetchRequest error:nil];
}

- (NSArray *)createStudesCourses {
    NSFetchRequest *fetchRequest = [self createFetchRequestWithEntity:[Course class] andSort:@"name"];
    NSPredicate *studesCoursesPredicate = [NSPredicate predicateWithFormat:@"students CONTAINS %@", _user];
    [fetchRequest setPredicate:studesCoursesPredicate];
    return [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:fetchRequest error:nil];
}

#pragma mark - Actions

- (void)actionSave:(id)sender {
    
    if (!_user) {
        
        User *user = [[User alloc] initWithContext:[DataManager sharedManager].persistentContainer.viewContext];
        
        // If appropriate, configure the new managed object.
        user.firstName = _firstNameField.text;
        user.lastName = _lastNameField.text;
        user.eMail = _eMailField.text;
        
    } else {
        
        _user.firstName = _firstNameField.text;
        _user.lastName = _lastNameField.text;
        _user.eMail = _eMailField.text;
    }
    
    [[DataManager sharedManager] saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger sectionsCount = 1;
    
    if (_teachesCourses.count > 0) {
        ++sectionsCount;
    }
    if (_studesCourses.count > 0) {
        ++sectionsCount;
    }
    
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
            break;
        case 1: {
            
            if (_teachesCourses.count > 0) {
                return _teachesCourses.count;
            } else {
                return _studesCourses.count;
            }
        }
            break;
        case 2:
            return _studesCourses.count;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Profil";
            break;
        case 1: {
            if (_teachesCourses.count > 0) {
                return @"Teaches courses";
            } else {
                return @"Studes courses";
            }
        }
            break;
        case 2:
            return @"Studes courses";
            break;
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellEdit" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellCourse" forIndexPath:indexPath];
    }
    
    [self configureCell:cell withIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell.reuseIdentifier isEqualToString:@"CellEdit"]) {
        
        UITextField *detail = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.frame) - 200 - 20,
                                                                            (CGRectGetHeight(cell.frame) - 30) / 2,
                                                                            200,
                                                                            30)];
        detail.borderStyle = UITextBorderStyleRoundedRect;
        if (!_enableEditing)  {
            detail.enabled = NO;
        }
        [cell addSubview:detail];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"First name";
                detail.text = _user.firstName;
                _firstNameField = detail;
                break;
            case 1:
                cell.textLabel.text = @"Last name";
                detail.text = _user.lastName;
                _lastNameField = detail;
                break;
            case 2:
                cell.textLabel.text = @"e-Mail";
                detail.text =  _user.eMail;
                _eMailField = detail;
                break;
        }
    } else if ([cell.reuseIdentifier isEqualToString:@"CellCourse"]) {
        
        if (_enableEditing) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        switch (indexPath.section) {
            case 1: {
                if (_teachesCourses.count > 0) {
                    cell.textLabel.text = _teachesCourses[indexPath.row].name;
                } else {
                    cell.textLabel.text = _studesCourses[indexPath.row].name;
                }
            }
                break;
            case 2: {
                cell.textLabel.text = _studesCourses[indexPath.row].name;
            }
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section > 0 && _enableEditing) {
        [self showCourse];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Methods

- (void)showCourse {
    EditingCourseViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditingCourseViewController"];
    
    Course *course;
    
    _editUserIndexPath = [self.tableView indexPathForSelectedRow];
    switch (_editUserIndexPath.section) {
        case 1: {
            if (_teachesCourses.count > 0) {
                course = _teachesCourses[_editUserIndexPath.row];
            } else {
                course = _studesCourses[_editUserIndexPath.row];
            }
        }
            break;
        case 2:
            course = _studesCourses[_editUserIndexPath.row];
            break;
        default:
            break;
    }
    
    vc.course = course;
    vc.enableEditing = NO;
    vc.navigationItem.title = course.name;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end








