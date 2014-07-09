//
//  CardDeck.h
//  NissanPoker
//
//  Created by Jasper Kahn on 7/7/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PokerCard.h"

@interface PokerDeck : NSObject

- (void)shuffle;
- (void)resetDeck;                  //refills deck and shuffles
- (PokerCard *)drawCard;          //Draws the top card
- (PokerCard *)drawCardRandomly;  //Draws from a random index

@end
