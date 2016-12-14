//
//  UIBarButtonItem+UIBarButtonItemCustomButton.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 14.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (UIBarButtonItemCustomButton)

+ (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target action:(SEL)action tintColor:(UIColor *)tintColor;

@end
