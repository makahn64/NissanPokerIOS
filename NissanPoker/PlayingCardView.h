//
//  PlayingCardView.h
//  NissanPoker
//
//  Created by Jasper Kahn on 7/10/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayingCardView : UIView

@property (nonatomic) BOOL isFaceup;

- (id)initWithFrame:(CGRect)frame andIsSmall:(BOOL)small;

- (void)flipCard;
- (void)flipCardAnimated;
- (void)flipCardAnimatedwithCompletion:(void(^)(void))afterFlip;

- (void)setRankAndSuitFromCard:(PokerCard *)card;
- (void)setRank:(NSString *)rank andSuit:(NSString *)suit;
- (void)setRank:(NSString *)rank;
- (void)setSuit:(NSString *)suit;

- (void)makeLarge;

@end
