//
//  PokerPlayer.h
//  NissanPoker
//
//  Created by Jasper Kahn on 7/7/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PokerDeck.h"
#import "PokerCard.h"

@interface PokerPlayer : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *emailAddress;

@property (nonatomic) NSInteger timeStartedGame;

@property (strong, nonatomic) PokerDeck *deck;
@property (strong, nonatomic) NSMutableArray *pokerHand;


- (PokerCard *)getNewCard;


@end
