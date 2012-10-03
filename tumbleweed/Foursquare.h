//
//  Foursquare.h
//  tumbleweed
//
//  Created by Ian Parker on 2/2/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "AFFoursquareAPIClient.h"

@interface Foursquare : NSObject 

@property (readonly, retain) NSString *userId;
@property (readonly, retain) NSString *userFirstName;
@property (readonly, retain) NSString *userLastName;

- (id)initWithAttributes:(NSDictionary *)attributes;

+(ASIFormDataRequest*) checkInFoursquare:(NSString *) venueId 
                                shout:(NSString *) shoutText;
+(ASIHTTPRequest*)searchVenuesNearByLatitude:(NSString*)lat
						longitude:(NSString*)lon
                       categoryId:(NSString*)category;
+(ASIHTTPRequest*) getUserId;



+ (void)getUserIdWithBlock:(void (^)(NSDictionary *userCred, NSError *error))block;

+ (void)searchVenuesNearByLatitude:(NSString*)lat
                         longitude:(NSString*)lon
                        categoryId:(NSString*)category
WithBlock:(void (^)(NSArray *venues, NSError *error))block;
+ (void)cancelSearchVenues;

+ (void)checkIn:(NSString*)venueId
          shout:(NSString *) shoutText
    WithBlock:(void (^)(NSDictionary *checkInResponse, NSError *error))block;

@end
