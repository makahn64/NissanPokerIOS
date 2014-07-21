//
//  CrossfadeSegue.m
//  Nissan Poker
//
//  Created by Jasper Kahn on 7/17/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "CrossfadeSegue.h"

@implementation CrossfadeSegue

- (void)perform
{
    CATransition* transition = [CATransition animation];
    
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    
    [[self.sourceViewController navigationController].view.layer addAnimation:transition forKey:kCATransition];
    [[self.sourceViewController navigationController] pushViewController:[self destinationViewController] animated:NO];
    
}

@end
