//
//  UIImage+UIImageWithText.m
//  CoreData
//
//  Created by Arkadiy Grigoryanc on 13.12.16.
//  Copyright © 2016 Arkadiy Grigoryanc. All rights reserved.
//

#import "UIImage+UIImageWithText.h"

@implementation UIImage (UIImageWithText)

+ (instancetype) imageFromImage:(UIImage*)image size:(CGSize)imageSize text:(NSString*)text {
    
    UIFont *font = [UIFont systemFontOfSize:16.0];
    CGSize expectedTextSize = [text sizeWithAttributes:@{NSFontAttributeName: font}];
    
    UIImage *newImage = [image imageWithImage:image scaledToSize:imageSize];
    
    int width = expectedTextSize.width + newImage.size.width + 5;
    int height = MAX(expectedTextSize.height, newImage.size.width);
    CGSize size = CGSizeMake((float)width, (float)height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(context, color.CGColor);
    int fontTopPosition = (height - expectedTextSize.height) / 2;
    CGPoint textPoint = CGPointMake(newImage.size.width + 5, fontTopPosition);
    
    [text drawAtPoint:textPoint withAttributes:@{NSFontAttributeName: font}];
    // Images upside down so flip them
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, size.height);
    CGContextConcatCTM(context, flipVertical);
    
    NSInteger space = 10;
    CGRect rect = CGRectMake(space / 2,
                             (height - newImage.size.height) / 2 + space / 2,
                             newImage.size.width - space,
                             newImage.size.height - space);
    
    CGContextDrawImage(context, rect, newImage.CGImage);
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
    
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
