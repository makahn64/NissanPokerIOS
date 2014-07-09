//
//  PlayingCard.h
//  NissanPoker
//
//  Created by Mitchell Kahn on 7/9/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Customer;

@interface PlayingCard : NSManagedObject

@property (nonatomic, retain) NSString * rank;
@property (nonatomic, retain) NSString * suit;
@property (nonatomic, retain) Customer *myCustomer;

@end
