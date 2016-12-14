//
//  UIBarButtonItem+UIBarButtonItemCustomButton.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 14.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "UIBarButtonItem+UIBarButtonItemCustomButton.h"

@implementation UIBarButtonItem (UIBarButtonItemCustomButton)

+ (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target action:(SEL)action tintColor:(UIColor *)tintColor {
    
    UIView *leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 110, 50)];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage imageNamed:@"Icon-Back"]
                forState:UIControlStateNormal];
    [leftButton setTitle:@"  Back"
                forState:UIControlStateNormal];
    [leftButton sizeToFit];
    leftButton.frame = CGRectMake(0, 0, CGRectGetWidth(leftButton.frame) + 25, CGRectGetHeight(leftButtonView.frame));
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.tintColor = tintColor;
    leftButton.autoresizesSubviews = YES;
    leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [leftButton addTarget:target
                   action:action
         forControlEvents:UIControlEventTouchUpInside];
    [leftButtonView addSubview:leftButton];
    
    return [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
}

@end
