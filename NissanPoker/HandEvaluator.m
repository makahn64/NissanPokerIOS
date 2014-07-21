//
//  HandEvaluator.m
//  Nissan Poker
//
//  Created by Jasper Kahn on 7/21/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "HandEvaluator.h"

@interface HandEvaluator()

@property (strong, nonatomic) NSMutableArray *sevenCardHand;
@property (nonatomic) int handValue;

@property (strong, nonatomic) NSMutableArray *suitCounts;
@property (strong, nonatomic) NSMutableArray *rankCounts;

@end


@implementation HandEvaluator

- (void)addCard:(PokerCard *)newCard
{
    [self.sevenCardHand addObject:newCard];
}

- (void)addCardWithRank:(int)rank andSuit:(NSString *)suit
{
    PokerCard *newCard = [[PokerCard alloc] init];
    [newCard setSuit:suit];
    [newCard setSuitNumeric:rank];
}

- (PokerHand *)evaluateHand
{
    PokerHand *finalHand = [[PokerHand alloc] init];
    
    
    
    
    
    return finalHand;
    
}

@end
