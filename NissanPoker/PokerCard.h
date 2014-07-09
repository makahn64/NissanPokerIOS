//
//  PokerCard.h
//  NissanPoker
//
//  Created by Jasper Kahn on 7/7/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PokerCard : NSObject

@property (strong, nonatomic) NSString *rank;
@property (strong, nonatomic) NSString *suit;
@property (strong, nonatomic, readonly) NSString *rankSuit;

- (void)setRankNumeric: (int)rank;
- (void)setSuitNumeric: (int)suit;

- (BOOL)isFaceCard;
- (BOOL)isJoker;

+ (int)maxSuitIndex;
+ (int)minSuitIndex;
+ (int)minRankIndexAceLow: (BOOL)aceLow;
+ (int)maxRankIndexAceLow: (BOOL)aceLow;

@end
