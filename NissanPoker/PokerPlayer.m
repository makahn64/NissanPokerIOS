//
//  PokerPlayer.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/7/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "PokerPlayer.h"

@implementation PokerPlayer


#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        double timeStartedDecimal = round( [[NSDate date] timeIntervalSince1970] );
        self.timeStartedGame = (int) timeStartedDecimal;
        
        self.deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        self.deck = [[PokerDeck alloc] init];
        self.pokerHand = [[PokerHand alloc] init];
    }
    
    return self;
}

- (PokerCard *)getNewCard
{
    PokerCard *newCard = self.deck.drawCard;
    
    [self.pokerHand addCard:newCard];
    return newCard;
}


@end
