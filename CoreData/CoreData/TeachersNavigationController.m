//
//  TeachersNavigationController.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 12.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "TeachersNavigationController.h"
#import "UsersViewController.h"

@interface TeachersNavigationController ()

@end

@implementation TeachersNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UsersViewController *vc = (UsersViewController *)self.topViewController;
    vc.type = UsersTypeTeachers;
    vc.navigationItem.title = @"Teachers";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
