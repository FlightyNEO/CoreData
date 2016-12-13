//
//  UIImage+UIImageWithText.h
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 13.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageWithText)

+ (instancetype) imageFromImage:(UIImage*)image size:(CGSize)size text:(NSString*)text;

@end
