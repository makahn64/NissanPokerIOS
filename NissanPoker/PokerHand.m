//
//  PokerHand.m
//  Nissan Poker
//
//  Created by Jasper Kahn on 7/21/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "PokerHand.h"

@interface PokerHand() {
    
    int _rankCounts[15];
    int _suitCounts[5];
    
}

@property (nonatomic) int highRankOfStraight;
@property (nonatomic) int suitOfFlush;
@property (nonatomic) int rankOfQuad;
@property (nonatomic) int rankOfHighTrip;
@property (nonatomic) int rankOfHighPair;
@property (nonatomic) int rankOfLowPair;

@end


@implementation PokerHand

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hand = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Public Actions

- (NSComparisonResult)compareTo:(PokerHand *)otherHand
{
    if (self.handValue == otherHand.handValue)
    {
        return NSOrderedSame;
    }
    else if (self.handValue > otherHand.handValue)
    {
        return NSOrderedDescending;
    }
    else
    {
        return NSOrderedAscending;
    }
}

- (void)addCard:(PokerCard *)newCard
{
    [self.hand addObject:newCard];
    
    //NSLog(@"Added %@", newCard.rankSuit);
    
    _rankCounts[newCard.rankNumeric] += 1;
    _suitCounts[newCard.suitNumeric] += 1;
    
    [self updateHandValue];
}

- (void)addCards:(NSArray *)newCards
{
    for (PokerCard *card in newCards)
    {
        [self addCard:card];
    }
}

- (void)addCardWithRank:(NSString *)rank andSuit:(NSString *)suit
{
    PokerCard *newCard = [[PokerCard alloc] init];
    [newCard setRank:rank];
    [newCard setSuit:suit];
    
    [self addCard:newCard];
}

#pragma mark - Evaluator Logic

- (void)updateHandValue
{
    //Do nothing without at least a 5 card hand.
    if ([self.hand count] < 5)
    {
        _handValue = 0;
        return;
    }
    
    //Sort cards in hand from highest to lowest.
    [self.hand sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PokerCard *card1 = obj1;
        PokerCard *card2 = obj2;
        
        if (card1.rankNumeric > card2.rankNumeric) {
            return NSOrderedAscending;
        }
        if (card1.rankNumeric < card2.rankNumeric) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;

    }];
    
    //Clear out saved info about which cards make up the hand (ex: of which suit was the flush)
    [self resetHandRanks];
    
    //Get hand component info
    BOOL hasFlush = [self checkForFlush];
    HandType straightType = [self checkForStraight];
    HandType pairType = [self checkForPairs];
    
    if (straightType != Nothing && hasFlush) {
        straightType = [self checkForStraightFlushWithStraight:(straightType)];
    }
    
    //Combine components to match the correct actual hand type
    if (straightType == StraightFlush)
    {
        _handValue = [self calculateHandValue:(StraightFlush)];
        return;
    }
    else if (straightType == LowballStraightFlush)
    {
        _handValue = [self calculateHandValue:(LowballStraightFlush)];
        return;
    }
    else if (pairType == FourOfAKind)
    {
        _handValue = [self calculateHandValue:(FourOfAKind)];
        return;
    }
    else if (pairType == FullHouse)
    {
        _handValue = [self calculateHandValue:(FullHouse)];
        return;
    }
    else if (hasFlush)
    {
        _handValue = [self calculateHandValue:(Flush)];
        return;
    }
    else if (straightType == Straight)
    {
        _handValue = [self calculateHandValue:(Straight)];
        return;
    }
    else if (straightType == LowballStraight)
    {
        _handValue = [self calculateHandValue:(LowballStraight)];
        return;
    }
    else if (pairType == ThreeOfAKind)
    {
        _handValue = [self calculateHandValue:(ThreeOfAKind)];
        return;
    }
    else if (pairType == TwoPair)
    {
        _handValue = [self calculateHandValue:(TwoPair)];
        return;
    }
    else if (pairType == Pair)
    {
        _handValue = [self calculateHandValue:(Pair)];
        return;
    }
    else
    {
        _handValue = [self calculateHandValue:(HighCard)];
        return;
    }
    
}

- (void)resetHandRanks
{
    self.highRankOfStraight = 0;
    self.suitOfFlush = 0;
    self.rankOfQuad = 0;
    self.rankOfHighTrip = 0;
    self.rankOfHighPair = 0;
    self.rankOfLowPair = 0;
}

#pragma mark Hand Type Checkers

- (BOOL)checkForFlush
{
    //Iterates through counts of occurences for each suit.
    for (int i = 1; i < 5; i++)
    {
        if (_suitCounts[i] >= 5)
        {
            self.suitOfFlush = i;
            return YES;
        }
    }
    
    return NO;
    
}

- (HandType)checkForStraight
{

    //Variables used to compare to previous card and current state of the straight.
    int numConsecutiveCards = 1;
    int previousRank = -1;
    
    //Iterates through the hand from highest card to lowest looking for consecutive cards.
    for (int i = 0; i < [self.hand count]; i++)
    {
        PokerCard *card = self.hand[i];
        
        if (card.rankNumeric == previousRank - 1)
        {
            numConsecutiveCards++;
        }
        else if (card.rankNumeric != previousRank)
        {
            //If it's the same rank (a pair within the straight) do nothing and continue.
            numConsecutiveCards = 1;
        }
        
        previousRank = card.rankNumeric;
        
        //Checks for lowball Ace in a straight (Ace to 5).
        if (card.rankNumeric == 2 && numConsecutiveCards == 4)
        {
            PokerCard *firstCard = self.hand[0];
            if (firstCard.rankNumeric == 14)
            {
                self.highRankOfStraight = 5;
                return LowballStraight;
            }
        }
        
        if (numConsecutiveCards == 5)
        {
            self.highRankOfStraight = previousRank + 4;
            return Straight;
        }
    }
    //No straight found if it gets here.
    return Nothing;
}

- (HandType)checkForPairs
{
    //Iterates through the counts of occurences for each rank looking for pairs and up, from lowest to highest rank.
    for (int i = 0; i < 15; i++)
    {
        if (_rankCounts[i] == 4)
        {
            //Quads are exclusive (no other outcome matters) so we return here.
            self.rankOfQuad = i;
            return FourOfAKind;
        }
        else if (_rankCounts[i] == 3)
        {
            //If we already have a trip, it's necessarily lower (going from bottom up) so we check to see if it should requalify as a high pair.
            if (self.rankOfHighTrip > 0 && self.rankOfHighPair < self.rankOfHighTrip)
            {
                self.rankOfHighPair = self.rankOfHighTrip;
            }
            self.rankOfHighTrip = i;
        }
        else if (_rankCounts[i] == 2)
        {
            //Again, any prior pair is necessarily lower, so we bump it to second best.
            self.rankOfLowPair = self.rankOfHighPair;
            self.rankOfHighPair = i;
        }
        
    }
    
    
    if (self.rankOfHighTrip > 0)
    {
        //Having a pair as well means a full house.
        if (self.rankOfHighPair > 0)
        {
            return FullHouse;
        }
        //Ohterwise just a triple.
        else
        {
            return ThreeOfAKind;
        }
    }
    else if (self.rankOfHighPair > 0)
    {
        //Having two pairs means, surprise!, two pair.
        if (self.rankOfLowPair > 0)
        {
            return TwoPair;
        }
        else
        {
            return Pair;
        }
    }
    else
    {
        return Nothing;
    }
    
}

- (HandType)checkForStraightFlushWithStraight:(HandType)straightType
{
    int nextRank = self.highRankOfStraight;
    int count = 0;
    
    for (PokerCard *card in self.hand) {
        if (card.suitNumeric == self.suitOfFlush) {
            if (card.rankNumeric == nextRank && count < 5) {
                count++;
                nextRank--;
            }
        }
    }
    
    if (straightType == LowballStraight) {
        for (PokerCard *card in self.hand) {
            if (card.rankNumeric == 14 && card.suitNumeric == self.suitOfFlush) {
                count++;
            }
        }
    }
    
    if (count >= 5)
    {
        return (straightType + 4);
    }
    
    return straightType;
    
}

#pragma mark Value Calculator

- (int)calculateHandValue:(HandType)type
{
    //Sets the largest position based on hand type.
    int value = 10000000 * (type % 10);
    
    [self setFinalHandWithType:(type)];
    
    int exponent = 4;
    
    //Iterates through the final hand adding exponentially decaying value to give a unique value.
    for (PokerCard* card in self.bestFiveCardHand)
    {
        value += (card.rankNumeric * pow(16, exponent) );
        exponent--;
    }
    
    if ([self.hand count] >= 7) {
        NSLog(@"Full Hand %@", [self fullHandAsString]);
        NSLog(@"Evaluated as %@: %d",[self bestHandAsString],value);
    }
    

    return value;
    
}

#pragma mark - Set Final Hand

- (void)setFinalHandWithType:(HandType)type
{
    NSMutableArray *finalHand = [[NSMutableArray alloc] initWithCapacity:5];
    
    //Pulls the cards for each kind of hand and sets the Hand Description property
    switch (type) {
            
        case HighCard:
        {
            for (PokerCard *card in self.hand) {
                if ( [finalHand count] < 5 ) {
                    [finalHand addObject:card];
                }
            }
            PokerCard *highCard = finalHand[0];
            _handDescription = [NSString stringWithFormat:(@"%@ High"), highCard.rankName];
        }
            break;
        
        case Pair:
        {
            for (PokerCard *card in self.hand) {
                if (card.rankNumeric == self.rankOfHighPair) {
                    [finalHand addObject:card];
                }
            }
            PokerCard *highCard = finalHand[0];
            _handDescription = [NSString stringWithFormat:(@"Pair of %@s"), highCard.rankName];
        }
            break;
            
        case TwoPair:
        {
            for (PokerCard *card in self.hand) {
                if (card.rankNumeric == self.rankOfHighPair || card.rankNumeric == self.rankOfLowPair) {
                    [finalHand addObject:card];
                }
            }
            _handDescription = @"Two Pair";
        }
            break;
            
        case ThreeOfAKind:
        {
            for (PokerCard *card in self.hand) {
                if (card.rankNumeric == self.rankOfHighTrip) {
                    [finalHand addObject:card];
                }
            }
            _handDescription = @"Three of a Kind";
        }
            break;
            
        case LowballStraight:
        {
            int nextRank = self.highRankOfStraight;
            
            for (PokerCard *card in self.hand) {
                if (card.rankNumeric == nextRank && [finalHand count] < 5) {
                    [finalHand addObject:card];
                    nextRank--;
                }
            }
            
            [finalHand addObject:self.hand[0]];
            _handDescription = @"Straight";
        }
            break;
            
        case Straight:
        {
            int nextRank = self.highRankOfStraight;
            
            for (PokerCard *card in self.hand) {
                if (card.rankNumeric == nextRank && [finalHand count] < 5) {
                    [finalHand addObject:card];
                    nextRank--;
                }
            }
            _handDescription = @"Straight";
        }

            break;
            
        case Flush:
        {
            for (PokerCard *card in self.hand) {
                if (card.suitNumeric == self.suitOfFlush && [finalHand count] < 5) {
                    [finalHand addObject:card];
                }
            }
            _handDescription = @"Flush";
        }
            break;
            
        case FullHouse:
        {
            for (PokerCard *card in self.hand) {
                if (card.rankNumeric == self.rankOfHighTrip) {
                    [finalHand addObject:card];
                }
            }
            for (PokerCard *card in self.hand) {
                if (card.rankNumeric == self.rankOfHighPair) {
                    [finalHand addObject:card];
                }
            }
            _handDescription = @"Full House";
        }
            break;
            
        case FourOfAKind:
        {
            for (PokerCard *card in self.hand) {
                if (card.rankNumeric == self.rankOfQuad) {
                    [finalHand addObject:card];
                }
            }
            _handDescription = @"Four of a Kind";
        }
            break;
            
        case LowballStraightFlush:
        {
            int nextRank = self.highRankOfStraight;
            
            for (PokerCard *card in self.hand) {
                if (card.rankNumeric == nextRank && card.suitNumeric == self.suitOfFlush && [finalHand count] < 5) {
                    [finalHand addObject:card];
                    nextRank--;
                }
            }
            _handDescription = @"Straight Flush";
            
            [finalHand addObject:self.hand[0]];
            
        }
            break;
            
        case StraightFlush:
        {
            int nextRank = self.highRankOfStraight;
            
            for (PokerCard *card in self.hand) {
                if (card.rankNumeric == nextRank && card.suitNumeric == self.suitOfFlush && [finalHand count] < 5) {
                    [finalHand addObject:card];
                    nextRank--;
                }
            }
            _handDescription = @"Straight FLush";
        }
            break;
            
            
        default:
            break;
    }
    
    for (PokerCard *kicker in self.hand)
    {
        if ([finalHand count] < 5 && ![finalHand containsObject:kicker]) {
            [finalHand addObject:kicker];
        }
    }
    
    _bestFiveCardHand = finalHand;
    
}

#pragma mark - Useful Values as Strings

- (NSString *)fullHandAsString
{
    NSString *handString = @"[";
    
    for (PokerCard *card in self.hand) {
        NSString *nextStr = [card.rankSuit stringByAppendingString:@", "];
        handString = [handString stringByAppendingString:nextStr];
    }
    
    handString = [handString substringToIndex:handString.length - 2];
    handString = [handString stringByAppendingString:@"]"];
    
    return handString;
}

- (NSString *)bestHandAsString
{
    NSString *handString = @"[";
    
    for (PokerCard *card in self.bestFiveCardHand) {
        NSString *nextStr = [card.rankSuit stringByAppendingString:@", "];
        handString = [handString stringByAppendingString:nextStr];
    }
    
    handString = [handString substringToIndex:handString.length - 2];
    handString = [handString stringByAppendingString:@"]"];
    
    return handString;
}

- (NSString *)bestHandAsStringInitials
{
    NSString *handString = @"[";
    
    for (PokerCard *card in self.bestFiveCardHand) {
        NSString *cardRS = [card.rankAsInitial stringByAppendingString:card.suitAsInitial];
        NSString *nextStr = [cardRS stringByAppendingString:@", "];
        handString = [handString stringByAppendingString:nextStr];
    }
    
    handString = [handString substringToIndex:handString.length - 2];
    handString = [handString stringByAppendingString:@"]"];
    
    return handString;
}
    

@end
