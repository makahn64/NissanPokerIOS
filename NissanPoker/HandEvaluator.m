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

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.sevenCardHand = [[NSMutableArray alloc] init];
        
        self.suitCounts = [[NSMutableArray alloc] init];
        
        self.rankCounts = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}


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
    
    
    //Trillions place is the hand rank
    //Each card is multiplied by 10^(2*i), where i is index from low to high.
    
    for (PokerCard *card in self.sevenCardHand)
    {
        NSNumber *count = (NSNumber *) [self.rankCounts objectAtIndex:card.rankNumeric];
        [self.rankCounts setOb]
    }
    
    
    return finalHand;
    
}

@end
