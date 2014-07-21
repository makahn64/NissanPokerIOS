//
//  PokerHand.h
//  Nissan Poker
//
//  Created by Jasper Kahn on 7/21/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PokerHand : NSObject

@property (strong, nonatomic) NSArray *hand;
@property (nonatomic) int handValue;

@end
