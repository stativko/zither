//
//  SSIIntroView.m
//  WarrantyManager
//
//  Created by User on 10/30/14.
//  Copyright (c) 2014 Ibrahim. All rights reserved.
//

#import "SSIIntroView.h"

@interface SSIIntroView ()

@property (nonatomic) BOOL isAnimating;

@end

@implementation SSIIntroView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setHidden:YES];
}

- (void)startAnimate
{
    if (self.isAnimating) {

        return;
    }

    self.isAnimating = YES;

    [self setHidden:NO];
    self.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{

        self.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    } completion:^(BOOL finished) {

        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{

            self.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
        } completion:^(BOOL finished) {

            [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{

                self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            } completion:^(BOOL finished) {

                [self startRotatingAnimation];
            }];
        }];
    }];
}

- (void)startRotatingAnimation
{
    [UIView animateWithDuration:5.0f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{

        self.animateImageView.transform = CGAffineTransformRotate(self.animateImageView.transform, M_PI_2);
    } completion:^(BOOL finished) {

        [self startRotatingAnimation];
    }];
}

@end
