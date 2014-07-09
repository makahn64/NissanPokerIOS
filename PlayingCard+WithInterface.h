//
//  PlayingCard+WithInterface.h
//  NissanPoker
//
//  Created by Mitchell Kahn on 7/9/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "PlayingCard.h"
#import "PokerCard.h"

@interface PlayingCard (WithInterface)

+(PlayingCard *)playingCardFromPokerCard:(PokerCard *)pokerCard;

@end
