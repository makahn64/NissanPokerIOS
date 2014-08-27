//
//  PlayingCardView.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/10/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "PlayingCardView.h"

#define PLAYING_CARD_DEFAULT_HEIGHT 420
#define PLAYING_CARD_DEFAULT_WIDTH 300

@interface PlayingCardView()

@property (weak, nonatomic) UIImageView *frontOfCardView;
@property (weak, nonatomic) UIImageView *backOfCardView;

@property (weak, nonatomic) UILabel *topRankLabel;
@property (weak, nonatomic) UILabel *topSuitLabel;

@property (weak, nonatomic) UIImageView *cardFaceImageView;

@property (weak, nonatomic) UILabel *bottomRankLabel;
@property (weak, nonatomic) UILabel *bottomSuitLabel;

@property (nonatomic) BOOL subviewsAreSetup;

@property (weak, nonatomic) NSString *currentSuit;

@property (nonatomic) BOOL isSmall;
@property (nonatomic) BOOL imageBased;

@end

@implementation PlayingCardView


#pragma mark - Initializers

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.autoresizesSubviews = YES;
        self.isSmall = NO;
        [self setupSubviews];
    }
    
    
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.autoresizesSubviews = YES;
        self.isSmall = NO;
        [self setupSubviews];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andIsSmall:(BOOL)isSmall
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.autoresizesSubviews = YES;
        self.isSmall = isSmall;
        [self setupImageSubviews];
        
    }
    return self;
}


#pragma mark - Setup Methods


- (void)setupSubviews
{
    //Initialize and add the "sides" of the card
    UIImageView *frontView = [[UIImageView alloc] initWithFrame:self.bounds];
    UIImageView *backView = [[UIImageView alloc] initWithFrame:self.bounds];
    
    frontView.image = [UIImage imageNamed:@"Cards_Big_Blank.png"];
    backView.image = [UIImage imageNamed:@"Cards_Big_Back"];
    
    [self insertSubview:frontView aboveSubview:self];
    [self insertSubview:backView aboveSubview:frontView];
    
    self.frontOfCardView = frontView;
    self.backOfCardView = backView;
    
    [self setupCardFront];
    
    self.isFaceup = NO;
    self.imageBased = NO;
    self.subviewsAreSetup = YES;
    
}

- (void)setupImageSubviews
{
    //Initialize and add the "sides" of the card
    UIImageView *frontView = [[UIImageView alloc] initWithFrame:self.bounds];
    UIImageView *backView = [[UIImageView alloc] initWithFrame:self.bounds];
    
    if (self.isSmall)
    {
        frontView.image = [UIImage imageNamed:@"Cards_Small_Blank.png"];
        backView.image = [UIImage imageNamed:@"Cards_Small_Back"];
    }
    else
    {
        frontView.image = [UIImage imageNamed:@"Cards_Big_Blank.png"];
        backView.image = [UIImage imageNamed:@"Cards_Big_Back"];
    }
    
    [self insertSubview:frontView aboveSubview:self];
    [self insertSubview:backView aboveSubview:frontView];
    
    self.frontOfCardView = frontView;
    self.backOfCardView = backView;
    
    self.isFaceup = NO;
    self.imageBased = YES;
    self.subviewsAreSetup = YES;
    
}


- (void)setupCardFront
{
    [self setupRankLabels];
    [self setupSuitLabels];
    [self setupCardFace];
    
}


- (void)setupRankLabels
{
    //Check for being already setup
    if (!self.subviewsAreSetup)
    {
        //Initialize and size the rank labels for the front of the card
        float padding = .02 * self.frame.size.height;
        
        float rankWidth = .2 * self.frame.size.width;
        float rankHeight = .12 * self.frame.size.height;
        
        UILabel *topRankLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0 + padding, rankWidth, rankHeight)];
        
        float bottomRankX = self.frame.size.width - rankWidth;
        float bottomRankY = self.frame.size.height - rankHeight;
        UILabel *bottomRankLabel = [[UILabel alloc]initWithFrame:CGRectMake(bottomRankX, bottomRankY - padding, rankWidth, rankHeight)];
        
        //Set up the fonts for the ranks
        float rankFontSize = roundf(rankHeight)-1.0;
        topRankLabel.font = [UIFont fontWithName:@"American Typewriter" size:rankFontSize];
        topRankLabel.textAlignment = NSTextAlignmentCenter;
        bottomRankLabel.font = [UIFont fontWithName:@"American Typewriter" size:rankFontSize];
        bottomRankLabel.textAlignment = NSTextAlignmentCenter;
        
        //Rotate the bottom one
        [bottomRankLabel setTransform:CGAffineTransformMakeRotation(-M_PI)];
        
        //Add the rank labels
        [self.frontOfCardView addSubview:topRankLabel];
        [self.frontOfCardView addSubview:bottomRankLabel];
        
        self.topRankLabel = topRankLabel;
        self.bottomRankLabel = bottomRankLabel;

    }
}

- (void)setupSuitLabels
{
    //Check for already being setup
    if (!self.subviewsAreSetup)
    {
        //Initialize and size the suit labels
        float suitWidth = .2 * self.frame.size.width;
        float suitHeight = .12 * self.frame.size.height;
        
        float topSuitX = 0;
        float topSuitY = suitHeight;
        
        UILabel *topSuitLabel = [[UILabel alloc] initWithFrame:CGRectMake(topSuitX, topSuitY, suitWidth, suitHeight)];
        
        float bottomSuitX = self.frame.size.width - suitWidth;
        float bottomSuitY = self.frame.size.height - (2 * suitHeight);
        UILabel *bottomSuitLabel = [[UILabel alloc] initWithFrame:CGRectMake(bottomSuitX, bottomSuitY, suitWidth, suitHeight)];
        
        //Set up the fonts for the suits
        float suitFontSize = roundf(suitHeight);
        topSuitLabel.font = [UIFont fontWithName:@"American Typewriter" size:suitFontSize];
        topSuitLabel.textAlignment = NSTextAlignmentCenter;
        bottomSuitLabel.font = [UIFont fontWithName:@"American Typewriter" size:suitFontSize];
        bottomSuitLabel.textAlignment = NSTextAlignmentCenter;
        
        //Rotate the bottom one
        [bottomSuitLabel setTransform:CGAffineTransformMakeRotation(-M_PI)];
        
        //Add the suit labels
        [self.frontOfCardView addSubview:topSuitLabel];
        [self.frontOfCardView addSubview:bottomSuitLabel];
        
        self.topSuitLabel = topSuitLabel;
        self.bottomSuitLabel = bottomSuitLabel;
        
    }
}


- (void)setupCardFace
{
    //360x605   
    //Check for already being setup
    if (!self.subviewsAreSetup)
    {
        //Initialize and size the face view
        float faceX = self.topRankLabel.frame.size.width;
        float faceY = self.topRankLabel.frame.size.height;
        float faceWidth = self.frontOfCardView.frame.size.width - (2*self.topRankLabel.frame.size.width);
        float faceHeight = self.frontOfCardView.frame.size.height - (2*self.topRankLabel.frame.size.height);
        
        UIImageView *faceView = [[UIImageView alloc] initWithFrame: CGRectMake(faceX, faceY, faceWidth, faceHeight)];
        
        //Add the image
        //TODO
        
        //Add the view
        [self.frontOfCardView insertSubview:faceView atIndex:0];
        
        self.cardFaceImageView = faceView;
    }
    
}

#pragma mark - Actions

- (void)flipCard
{
    if (self.isFaceup)
    {
        self.frontOfCardView.hidden = YES; self.backOfCardView.hidden = NO;
        //[self.frontOfCardView removeFromSuperview]; [self.cardParentView addSubview:self.backOfCardView];
        self.isFaceup = NO;
        
    }
    else
    {
        self.backOfCardView.hidden = YES; self.frontOfCardView.hidden = NO;
        //[self.backOfCardView removeFromSuperview]; [self.cardParentView addSubview:self.frontOfCardView];
        self.isFaceup = YES;
    }
}

- (void)flipCardAnimated
{
    [self flipCardAnimatedwithCompletion:nil];
}

- (void)flipCardAnimatedwithCompletion:(void(^)(void))afterFlip
{

    [UIView transitionWithView:self
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        
                        if (self.isFaceup)
                        {
                            self.frontOfCardView.hidden = YES; self.backOfCardView.hidden = NO;
                            //[self.frontOfCardView removeFromSuperview]; [self.cardParentView addSubview:self.backOfCardView];
                            self.isFaceup = NO;
                            
                        }
                        else
                        {
                            self.backOfCardView.hidden = YES; self.frontOfCardView.hidden = NO;
                            //[self.backOfCardView removeFromSuperview]; [self.cardParentView addSubview:self.frontOfCardView];
                            self.isFaceup = YES;
                        }
                        
                    }
                    completion:^(BOOL finished) {
                        if (afterFlip)
                        {
                            afterFlip();
                        }
                    }
     ];
    
}

#pragma mark - Rank and Suit Setters

- (void)setRankAndSuitFromCard:(PokerCard *)card
{
    if (self.imageBased)
    {
        NSString *imageName = @"Cards_";
        if (self.isSmall) {
            imageName = [imageName stringByAppendingString:@"Small_"];
        }
        else
        {
            imageName = [imageName stringByAppendingString:@"Big_"];
        }
        
        imageName = [imageName stringByAppendingString:card.rank];
        imageName = [imageName stringByAppendingString:card.suitAsInitial];
        
        imageName = [imageName stringByAppendingString:@".png"];
        
        self.frontOfCardView.image = [UIImage imageNamed:imageName];
    }
    
    else
    {
        [self setRank:card.rank andSuit:[card suitAsUnicodeCharacter]];
    }
}

- (void)setRank:(NSString *)rank andSuit:(NSString *)suit
{
    [self setRank:rank];
    [self setSuit:suit];
}

- (void)setRank:(NSString *)rank
{
    self.topRankLabel.text = rank;
    self.bottomRankLabel.text = rank;
}

- (void)setSuit:(NSString *)suit
{
    self.topSuitLabel.text = suit;
    self.bottomSuitLabel.text = suit;
    
    self.currentSuit = suit;
    
    [self updateSuitColor];
    
}

- (void)makeLarge
{
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.isSmall = NO;
    
    [self setupImageSubviews];
    
}

#pragma mark - Refresh Methods

- (void)updateSuitColor
{
    if ([self.currentSuit isEqualToString: @"♦" ] || [self.currentSuit isEqualToString:@"♥"])
    {
        self.topSuitLabel.textColor = [UIColor redColor];
        self.topRankLabel.textColor = [UIColor redColor];
        
        self.bottomSuitLabel.textColor = [UIColor redColor];
        self.bottomRankLabel.textColor = [UIColor redColor];
    }
    else
    {
        self.topSuitLabel.textColor = [UIColor blackColor];
        self.topRankLabel.textColor = [UIColor blackColor];
        
        self.bottomSuitLabel.textColor = [UIColor blackColor];
        self.bottomRankLabel.textColor = [UIColor blackColor];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
