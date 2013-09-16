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

+ (void)searchVenuesNearByLatitude:(float)lat
                         longitude:(float)lon
                        categoryId:(NSString*)category
WithBlock:(void (^)(NSArray *venues, NSError *error))block;

+ (void)exploreVenuesNearByLatitude:(float)lat
                         longitude:(float)lon
                        sectionId:(NSString*)section
                          noveltyId:(NSString*)novelty
                           distance:(NSString*)radius
                       friendVisits:(NSString*)visited
                         WithBlock:(void (^)(NSArray *venues, NSError *error))block;

+ (void)cancelSearchVenues;

+ (void)checkIn:(NSString*)venueId
          shout:(NSString *) shoutText
      broadcast:(NSString*) broadcastType
    WithBlock:(void (^)(NSDictionary *checkInResponse, NSError *error))block;

+ (void)addPhoto:(UIImage*) image
         checkin:(NSString*) checkInId
       broadcast:(NSString*) broadcastType;

+ (void)addList:(NSString*) name
    description:(NSString*) desc
WithBlock:(void (^)(NSDictionary *listResponse, NSError *error))block;

+ (void)addListItem:(NSString*) listId
              venue:(NSString*) venueId
           itemText:(NSString*) text;


@end
