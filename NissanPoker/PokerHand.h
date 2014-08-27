//
//  PokerHand.h
//  Nissan Poker
//
//  Created by Jasper Kahn on 7/21/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PokerHand : NSObject

@property (strong, nonatomic) NSMutableArray *hand;

@property (readonly, nonatomic) int handValue;

@property (readonly, nonatomic, strong) NSArray *bestFiveCardHand;
@property (readonly, nonatomic, strong) NSString *handDescription;

- (NSComparisonResult)compareTo:(PokerHand *)otherHand;

- (void)addCard:(PokerCard *)newCard;
- (void)addCards:(NSArray *)newCards;
- (void)addCardWithRank:(NSString *)rank andSuit:(NSString *)suit;

- (NSString *)fullHandAsString;
- (NSString *)bestHandAsString;
- (NSString *)bestHandAsStringInitials;

- (NSArray *)bestHandNetworkArray;

typedef enum {
    Nothing = 0,
    HighCard = 1,
    Pair = 2,
    TwoPair = 3,
    ThreeOfAKind = 4,
    LowballStraight = 15,
    Straight = 5,
    Flush = 6,
    FullHouse = 7,
    FourOfAKind = 8,
    LowballStraightFlush = 19,
    StraightFlush = 9
} HandType;

@end
