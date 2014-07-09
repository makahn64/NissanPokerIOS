//
//  CardDeck.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/7/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "PokerDeck.h"


@interface PokerDeck()

@property (strong, nonatomic) NSMutableArray *deck;

@end



@implementation PokerDeck

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self resetDeck];
    }
    
    return self;
}


#pragma mark - Methods


- (void)shuffle;
{
    NSUInteger deckSize = [self.deck count];
    
    for (NSUInteger i = 0; i < deckSize; i++)
    {
        NSInteger remainingCount = deckSize - i;
        NSInteger exchangeIndex = i + arc4random_uniform(remainingCount);
        [self.deck exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
}


- (void)resetDeck;
{
    if (self.deck != nil)
    {
        [self.deck removeAllObjects];
    }
    else
    {
        self.deck = [[NSMutableArray alloc] init];
    }
    
    for (int suit = [PokerCard minSuitIndex]; suit <= [PokerCard maxSuitIndex]; suit++)
    {
        for (int rank = [PokerCard minRankIndexAceLow:(NO)]; rank <= [PokerCard maxRankIndexAceLow:(NO)]; rank++)
        {
            PokerCard *card = [[PokerCard alloc]init];
            [card setRankNumeric: rank];
            [card setSuitNumeric: suit];
            [self.deck addObject: card];
        }
    }
    
    [self shuffle];
    
}


- (PokerCard *)drawCard;
{
    PokerCard *card = [self.deck objectAtIndex:(1)];
    [self.deck removeObjectAtIndex:(1)];
    return card;
}


- (PokerCard *)drawCardRandomly;
{
    NSUInteger randIndex = arc4random_uniform([self.deck count]+1);
    PokerCard *card = [_deck objectAtIndex:(randIndex)];
    [self.deck removeObjectAtIndex:(randIndex)];
    return card;
}


@end
