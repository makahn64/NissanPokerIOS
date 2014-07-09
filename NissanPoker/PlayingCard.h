//
//  PlayingCard.h
//  NissanPoker
//
//  Created by Jasper Kahn on 7/7/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PlayingCard : NSManagedObject

@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSString * suit;
@property (nonatomic, retain) NSManagedObject *myCustomer;

@end
