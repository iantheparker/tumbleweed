//
//  Foursquare.h
//  tumbleweed
//
//  Created by Ian Parker on 2/2/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFFoursquareAPIClient.h"
#import <AFHTTPRequestOperation.h>


@interface Foursquare : NSObject

+ (BOOL)startAuthorization;

+ (BOOL)handleOpenURL:(NSURL *)url
WithBlock:(void (^)(NSString *access_token))block;

+ (void)getUserIdWithBlock:(void (^)(NSDictionary *userCred, NSError *error))block;

+ (void)searchVenuesNearByLatitude:(NSString*)lat
                         longitude:(NSString*)lon
                        categoryId:(NSString*)category
WithBlock:(void (^)(NSArray *venues, NSError *error))block;

+ (void)exploreVenuesNearByLatitude:(NSString*)lat
                         longitude:(NSString*)lon
                        sectionId:(NSString*)section
                          noveltyId:(NSString*)novelty
                         WithBlock:(void (^)(NSArray *venues, NSError *error))block;

+ (void)cancelSearchVenues;

+ (void)checkIn:(NSString*)venueId
          shout:(NSString *) shoutText
      broadcast:(NSString*) broadcastType
    WithBlock:(void (^)(NSDictionary *checkInResponse, NSError *error))block;

+ (void)addPhoto:(UIImage*) image
         checkin:(NSString*) checkInId
       broadcast:(NSString*) broadcastType;


@end
