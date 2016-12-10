//
//  EditingUserViewController.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 09.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "EditingUserViewController.h"
#import "DataManager.h"

#import "User+CoreDataClass.h"

@interface EditingUserViewController ()

@property (weak, nonatomic) UITextField *firstNameField;
@property (weak, nonatomic) UITextField *lastNameField;
@property (weak, nonatomic) UITextField *eMailField;

@end

@implementation EditingUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@", _user.firstName);
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                              target:self action:@selector(actionSave:)];
    
    self.navigationItem.rightBarButtonItem = saveItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellEdit" forIndexPath:indexPath];
    
    UITextField *detail = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.frame) - 200, 0, 200, 40)];
    detail.borderStyle = UITextBorderStyleRoundedRect;
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
    return cell;
}

@end








