//
//  Foursquare.h
//  tumbleweed
//
//  Created by Ian Parker on 2/2/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFFoursquareAPIClient.h"

@interface Foursquare : NSObject 

+ (void)getUserIdWithBlock:(void (^)(NSDictionary *userCred, NSError *error))block;

+ (void)searchVenuesNearByLatitude:(NSString*)lat
                         longitude:(NSString*)lon
                        categoryId:(NSString*)category
WithBlock:(void (^)(NSArray *venues, NSError *error))block;
+ (void)cancelSearchVenues;

+ (void)checkIn:(NSString*)venueId
          shout:(NSString *) shoutText
      broadcast:(NSString*) broadcastType
    WithBlock:(void (^)(NSDictionary *checkInResponse, NSError *error))block;

@end
