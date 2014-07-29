//
//  PlayingCard+WithInterface.m
//  NissanPoker
//
//  Created by Mitchell Kahn on 7/9/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "PlayingCard+WithInterface.h"

@implementation PlayingCard (WithInterface)


+(PlayingCard *)playingCardFromPokerCard:(PokerCard *)pokerCard{
    
    PlayingCard *newPC = [NSEntityDescription
                             insertNewObjectForEntityForName:@"PlayingCard"
                             inManagedObjectContext:[[AppDelegate sharedAppDelegate] managedObjectContext]];
    
    newPC.rank = pokerCard.rankAsInitial;
    newPC.suit = pokerCard.suitAsInitial;
    return newPC;    

}


@end
