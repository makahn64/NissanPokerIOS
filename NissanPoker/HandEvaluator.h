//
//  HandEvaluator.h
//  Nissan Poker
//
//  Created by Jasper Kahn on 7/21/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PokerHand.h"

@interface HandEvaluator : NSObject

- (void)addCard:(PokerCard *)newCard;
- (void)addCardWithRank:(int)rank andSuit:(NSString *)suit;

- (PokerHand *)evaluateHand;

@end
