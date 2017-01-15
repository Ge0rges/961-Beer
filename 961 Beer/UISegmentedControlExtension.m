//
//  UISegmentedControlExtension.m
//  961 Beer
//
//  Created by Georges Kanaan on 7/15/14.
//  Copyright (c) 2014 Gravity Brewing SAL. All rights reserved.
//

#import "UISegmentedControlExtension.h"


@implementation UISegmentedControl (CustomTintExtension)

-(void)setTag:(NSInteger)tag forSegmentAtIndex:(NSUInteger)segment {
    [[[self subviews] objectAtIndex:segment] setTag:tag];
}

-(void)setTintColor:(UIColor*)color forTag:(NSInteger)aTag {
    // must operate by tags.  Subview index is unreliable
    UIView *segment = [self viewWithTag:aTag];
    
    // UISegment is an undocumented class, so tread carefully
    // if the segment exists and if it responds to the setTintColor message
    if (segment && ([segment respondsToSelector:@selector(setTintColor:)])) {
        [segment performSelector:@selector(setTintColor:) withObject:color];
    }
}

-(void)setTextColor:(UIColor*)color forTag:(NSInteger)aTag {
    UIView *segment = [self viewWithTag:aTag];
    for (UIView *view in segment.subviews) {
        
        // if the sub view exists and if it responds to the setTextColor message
        if (view && ([view respondsToSelector:@selector(setTextColor:)])) {
            [view performSelector:@selector(setTextColor:) withObject:color];
        }
    }
}

@end
