//
//  Foursquare.m
//  tumbleweed
//
//  Created by Ian Parker on 2/2/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Foursquare.h"

static int vDate = 20120927;

@implementation Foursquare

+ (void)getUserIdWithBlock:(void (^)(NSDictionary *userCred, NSError *error))block
{
    
    [[AFFoursquareAPIClient sharedClient] getPath:@"users/self" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"] forKey:@"oauth_token"]
                                          success:^(AFHTTPRequestOperation *operation, id response) {
                                              NSDictionary *results = [[response objectForKey:@"response"] objectForKey:@"user"];
                                              //NSLog(@"results = %@", results);
                                              //userId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
                                              NSString *foursquare_first_name = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"firstName"];
                                              NSString *foursquare_last_name = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"lastName"];
                                              //create Tumbleweed id
                                              //everything should be off by default on tumbleweedviewcontroller
                                              NSLog(@"first: %@, last: %@", foursquare_first_name, foursquare_last_name);
                                              
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Error!");
                                              NSLog(@"%@", error);
                                          }];
}

+ (void)searchVenuesNearByLatitude:(NSString*)lat
                         longitude:(NSString*)lon
                        categoryId:(NSString*)category
                         WithBlock:(void (^)(NSArray *venues, NSError *error))block
{
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%@,%@", lat, lon], @"ll",
                                 @"10", @"limit",
                                 @"500", @"radius",
                                 category, @"categoryId",
                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"], @"oauth_token",
                                 [NSNumber numberWithInt:vDate], @"v", nil];
    [[AFFoursquareAPIClient sharedClient] getPath:@"venues/search" parameters:queryParams
                                          success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSMutableArray *mutableVenues = [NSMutableArray arrayWithCapacity:[JSON count]];
        NSArray *results = [[JSON objectForKey:@"response"] objectForKey:@"venues"];
        //NSLog(@"response from search= %@", results);
        for (NSDictionary *attributes in results) {
            [mutableVenues addObject:attributes];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableVenues], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
            NSLog(@"error from query %@", error);
        }
    }];
}

+ (void)cancelSearchVenues
{
    [[AFFoursquareAPIClient sharedClient] cancelAllHTTPOperationsWithMethod:@"get" path:@"venues/search"];

}

+ (void)checkIn:(NSString*)venueId
          shout:(NSString *) shoutText
      WithBlock:(void (^)(NSDictionary *checkInResponse, NSError *error))block
{
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"], @"oauth_token",
                                 venueId, @"venueId",
                                 shoutText, @"shout",
                                 @"private", @"broadcast",
                                 [NSNumber numberWithInt:vDate], @"v", nil];
    NSString *url = [NSString stringWithFormat:@"checkins/add?oauth_token=%@&venueId=%@&broadcast=private&shout=%@&v=%i", [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"], venueId, shoutText, vDate];
    [[AFFoursquareAPIClient sharedClient] postPath:url parameters:nil
                                          success:^(AFHTTPRequestOperation *operation, id JSON) {
                                              if (block) {
                                                  block(JSON, nil);
                                              }
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              if (block) {
                                                  block([NSDictionary dictionary], error);
                                                  NSLog(@"error from checkin %@", error);
                                              }
                                          }];
}


@end
