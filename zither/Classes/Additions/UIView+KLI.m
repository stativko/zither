//
//  UIView+KLI.m
//  zither
//
//  Created by Kevin Weiler on 2/26/15.
//  Copyright (c) 2015 Silber Studios, Inc. All rights reserved.
//

#import "UIView+KLI.h"

@implementation UIView (KLI)

- (void) animateOut {
    if (self.alpha == 0) {
        return;
    }
    [UIView animateWithDuration:DEFAULT_ANIM_SPEED animations:^{
        self.alpha = 0;
    }];
}

- (void) animateIn {
    if (self.alpha == 1) {
        return;
    }
    [UIView animateWithDuration:DEFAULT_ANIM_SPEED animations:^{
        self.alpha = 1;
    }];
}

- (void) animateOutWithCompletion:(dispatch_block_t)completion {
    NSInteger animSpeed = DEFAULT_ANIM_SPEED;
    if (self.alpha==0) {
        if (completion) {
            completion();
        }
        return;
    }
    [UIView animateWithDuration:animSpeed animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void) animateInWithCompletion:(dispatch_block_t)completion {
    NSInteger animSpeed = DEFAULT_ANIM_SPEED;
    if (self.alpha==1) {
        if (completion) {
            completion();
        }
        return;
    }
    [UIView animateWithDuration:animSpeed animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

@end
