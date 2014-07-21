//
//  PokerCard.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/7/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "PokerCard.h"

@implementation PokerCard


#pragma mark - Rank & Suit Valid Values

+ (NSArray *)validRanks
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K",@"A",@"JO"];
}

+ (NSArray *)validSuits
{
    return @[@" ?" ,@"Clubs",@"Diamonds", @"Hearts", @"Spades"];
}

#pragma mark - Numeric Getters

-(int)suitNumeric{
    
    return [[PokerCard validSuits] indexOfObject:self.suit];
}


-(int)rankNumeric{
    return [[PokerCard validRanks] indexOfObject:self.rank];

}

-(int)cardNumeric{
    
    return [self suitNumeric] << 16 | [self rankNumeric];
}

#pragma mark - Rank & Suit Setters


- (void)setRank: (NSString*)rank;
{
    if ([[PokerCard validRanks] containsObject:(rank)])
    {
        _rank = rank;
    }
    else
    {
        _rank = [[PokerCard validRanks] objectAtIndex:(0)];
    }
    
    [self updateRankSuit];
    
}


- (void)setSuit: (NSString*)suit;
{
    if ([[PokerCard validSuits] containsObject:(suit)])
    {
        _suit = suit;
    }
    else
    {
        _suit = [[PokerCard validSuits] objectAtIndex:(0)];
    }
    
    [self updateRankSuit];
    
}


- (void)setRankNumeric: (int)rank;
{
    if (rank < [[PokerCard validRanks] count] && rank > 0)
    {
        _rank = [[PokerCard validRanks] objectAtIndex:(rank)];
    }
    else
    {
        _rank = [[PokerCard validRanks] objectAtIndex:(0)];
    }
    
    [self updateRankSuit];
    
}


- (void)setSuitNumeric: (int)suit;
{
    if (suit < [[PokerCard validSuits] count] && suit > 0)
    {
        _suit = [[PokerCard validSuits] objectAtIndex:(suit)];
    }
    else
    {
        _suit = [[PokerCard validSuits] objectAtIndex:(0)];
    }
    
    [self updateRankSuit];
    
}

#pragma mark - Suit as Unicode Getter

- (NSString *)suitAsCharacter
{
    NSArray *unicodeSuits = @[@" ?" ,@"♣",@"♦", @"♥", @"♠"];
    return unicodeSuits[[self suitNumeric]];
}


#pragma mark - Card Utilities


- (BOOL)isFaceCard;
{
    int rankValue = [[PokerCard validRanks] indexOfObject:(_rank)];
    
    if (rankValue >= 11 && rankValue <= 13)
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
    if (_rank == [[PokerCard validRanks] objectAtIndex:(15)])
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
    return [[PokerCard validSuits] count] - 1;
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


#pragma mark - Private Utilities

- (void)updateRankSuit
{
    if (self.rank && self.suit)
    {
        _rankSuit = [_rank stringByAppendingString:(_suit)];
    }
}

+(PokerCard *)cardFromNumeric:(int)numericValue{
    
    int suitNumeric = (numericValue & 0xff00) >> 16;
    int rankNumeric = (numericValue & 0x00ff);
    
    PokerCard *newCard = [[PokerCard alloc] init];
    [newCard setRankNumeric:rankNumeric];
    [newCard setSuitNumeric:suitNumeric];
    
    return newCard;
    
}


@end
