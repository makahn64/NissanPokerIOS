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
#import "PokerHand.h"

@interface PokerPlayer : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;

@property (nonatomic) NSInteger timeStartedGame;
@property (nonatomic) NSInteger gameDuration;
@property (nonatomic) BOOL abandoned;
@property (nonatomic) BOOL finished;

@property (strong, nonatomic) PokerDeck *deck;
@property (strong, nonatomic) PokerHand *pokerHand;

@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *vehicle;


- (PokerCard *)getNewCard;


@end
