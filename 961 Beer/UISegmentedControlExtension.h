//
//  UISegmentedControlExtension.h
//  961 Beer
//
//  Created by Georges Kanaan on 7/15/14.
//  Copyright (c) 2014 Gravity Brewing SAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISegmentedControl (CustomTintExtension)

-(void)setTag:(NSInteger)tag forSegmentAtIndex:(NSUInteger)segment;
-(void)setTintColor:(UIColor*)color forTag:(NSInteger)aTag;
-(void)setTextColor:(UIColor*)color forTag:(NSInteger)aTag;

@end
