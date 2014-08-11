//
//  PokerCard.h
//  NissanPoker
//
//  Created by Jasper Kahn on 7/7/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PokerCard : NSObject

@property (strong, nonatomic, setter = setRank:) NSString *rank;
@property (nonatomic, setter = setRankNumeric:) int rankNumeric;

@property (strong, nonatomic, setter = setSuit:) NSString *suit;
@property (nonatomic, setter = setSuitNumeric:) int suitNumeric;

@property (strong, nonatomic, readonly) NSString *rankSuit;


- (instancetype)initWithRank:(NSString *)rank andSuit:(NSString *)suit;
- (instancetype)initWithRankNumeric:(int)rank andSuitNumeric:(int)suit;


- (void)setRank: (NSString*)rank;
- (void)setSuit: (NSString*)suit;
- (void)setRankNumeric: (int)rank;
- (void)setSuitNumeric: (int)suit;

- (NSString *)suitAsUnicodeCharacter;
- (NSString *)suitAsInitial;
- (NSString *)rankAsInitial;
- (NSString *)rankSuitAsInitials;
- (NSString *)rankName;

- (BOOL)isFaceCard;
- (BOOL)isJoker;

+ (NSArray *)validRanks;
+ (NSArray *)validSuits;

+ (int)maxSuitIndex;
+ (int)minSuitIndex;
+ (int)minRankIndexAceLow: (BOOL)aceLow;
+ (int)maxRankIndexAceLow: (BOOL)aceLow;

- (int)cardNumeric;
+(PokerCard *)cardFromNumeric:(int)numericValue;

@end
