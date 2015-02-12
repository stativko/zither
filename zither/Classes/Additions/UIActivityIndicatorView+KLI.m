//
//  UIActivityIndicatorView+KLI.m
//  JSwipe
//
//  Created by Kevin Weiler on 5/29/14.
//  Copyright (c) 2014 Smooch Labs. All rights reserved.
//

#import "UIActivityIndicatorView+KLI.h"

@implementation UIActivityIndicatorView (KLI)


+ (UIActivityIndicatorView*)createActivityIndicatorInView:(UIView*) view style:(UIActivityIndicatorViewStyle) style offset:(UIOffset) offset {
    UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    [av startAnimating];
    [view addSubview:av];
    CGPoint center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    center.x += offset.horizontal;
    center.y += offset.vertical;
    av.center = center;
    return av;
}


@end
