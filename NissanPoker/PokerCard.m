//
//  PokerCard.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/7/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "PokerCard.h"

@implementation PokerCard

#pragma mark - Initializer

- (instancetype)initWithRank:(NSString *)rank andSuit:(NSString *)suit
{
    self = [super init];
    if (self) {
        [self setRank:rank];
        [self setSuit:suit];
    }
    return self;
}

- (instancetype)initWithRankNumeric:(int)rank andSuitNumeric:(int)suit
{
    self = [super init];
    if (self) {
        [self setRankNumeric:rank];
        [self setSuitNumeric:suit];
    }
    return self;
}

#pragma mark - Rank & Suit Valid Values

+ (NSArray *)validRanks
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K",@"A",@"JO"];
}

+ (NSArray *)validSuits
{
    return @[@" ?" ,@"Clubs",@"Diamonds", @"Hearts", @"Spades"];
}

#pragma mark - Rank & Suit Setters


- (void)setRank: (NSString*)rank;
{
    if ([[PokerCard validRanks] containsObject:(rank)])
    {
        _rank = rank;
        self.rankNumeric = (int) [[PokerCard validRanks] indexOfObject:self.rank];
    }
    else
    {
        _rank = [[PokerCard validRanks] objectAtIndex:(0)];
        self.rankNumeric = 0;
    }
    
    [self updateRankSuit];
    
}


- (void)setSuit: (NSString*)suit;
{
    if ([[PokerCard validSuits] containsObject:(suit)])
    {
        _suit = suit;
        self.suitNumeric = (int)[[PokerCard validSuits] indexOfObject:suit];
    }
    else
    {
        _suit = [[PokerCard validSuits] objectAtIndex:(0)];
        self.suitNumeric = 0;
    }
    
    [self updateRankSuit];
    
}


- (void)setRankNumeric: (int)rank;
{
    if (rank < [[PokerCard validRanks] count] && rank > 0)
    {
        _rank = [[PokerCard validRanks] objectAtIndex:(rank)];
        _rankNumeric = rank;
    }
    else
    {
        _rank = [[PokerCard validRanks] objectAtIndex:(0)];
        _rankNumeric = 0;
    }
    
    [self updateRankSuit];
    
}


- (void)setSuitNumeric: (int)suit;
{
    if (suit < [[PokerCard validSuits] count] && suit > 0)
    {
        _suit = [[PokerCard validSuits] objectAtIndex:(suit)];
        _suitNumeric = suit;
    }
    else
    {
        _suit = [[PokerCard validSuits] objectAtIndex:(0)];
        _suitNumeric = 0;
    }
    
    [self updateRankSuit];
    
}

#pragma mark - Special String Getters

- (NSString *)suitAsUnicodeCharacter
{
    NSArray *unicodeSuits = @[@"?" ,@"♣",@"♦", @"♥", @"♠"];
    return unicodeSuits[self.suitNumeric];
}

- (NSString *)suitAsInitial
{
    NSArray *suitInitials = @[@"?" ,@"c",@"d", @"h", @"s"];
    return suitInitials[self.suitNumeric];
}

- (NSString *)rankAsInitial
{
    NSArray *rankInitials = @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"T",@"J",@"Q",@"K",@"A",@"JO"];
    return rankInitials[self.rankNumeric];
}

- (NSString *)rankName
{
    NSArray *rankNames = @[@"?",@"Ace",@"Two",@"Three",@"Four",@"Five",@"Six",@"Seven",@"Eight",@"Nine",@"Ten",@"Jack",@"Queen",@"King",@"Ace",@"Joker"];
    return rankNames[self.rankNumeric];
}

#pragma mark - Card Utilities


- (BOOL)isFaceCard;
{
    if (self.rankNumeric >= 11 && self.rankNumeric <= 13)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isJoker;
{
    if (self.rankNumeric == 15)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


//Returns the highest numerical value in the validSuits array corresponding to a standard suit.
+ (int)maxSuitIndex;
{
    return (int)[[PokerCard validSuits] count] - 1;
}

//Returns the lowest numerical value in the validSuits array corresponding to a standard suit (no error suit).
+ (int)minSuitIndex;
{
    return 1;
}

//returns the lowest valid rank value for a game with Aces low or high
+ (int)minRankIndexAceLow:(BOOL)aceLow;
{
    if (aceLow == YES)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}

//returns the highest valid rank value for a game with Aces low or high
+ (int)maxRankIndexAceLow: (BOOL)aceLow;
{
    if (aceLow == YES)
    {
        return 13;
    }
    else
    {
        return 14;
    }
}

- (int)cardNumeric
{
    int cardNumeric = self.suitNumeric << 16;
    cardNumeric = cardNumeric | self.rankNumeric;
    
    return cardNumeric;
}

+(PokerCard *)cardFromNumeric:(int)numericValue{
    
    int suitNumeric = (numericValue & 0xff00) >> 16;
    int rankNumeric = (numericValue & 0x00ff);
    
    PokerCard *newCard = [[PokerCard alloc] init];
    [newCard setRankNumeric:rankNumeric];
    [newCard setSuitNumeric:suitNumeric];
    
    return newCard;
    
}

#pragma mark - Private Utilities

- (void)updateRankSuit
{
    if (self.rank && self.suit)
    {
        _rankSuit = [self.rankAsInitial stringByAppendingString:( [self suitAsUnicodeCharacter] )];
    }
}


@end
