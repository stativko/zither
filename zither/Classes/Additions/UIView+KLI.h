//
//  UIView+KLI.h
//  zither
//
//  Created by Kevin Weiler on 2/26/15.
//  Copyright (c) 2015 Silber Studios, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KLI)


- (void) animateOut;
- (void) animateIn;
- (void) animateInWithCompletion:(dispatch_block_t)completion;
- (void) animateOutWithCompletion:(dispatch_block_t)completion;


@end
