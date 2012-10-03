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

@synthesize userId = _userId;
@synthesize userFirstName = _userFirstName;
@synthesize userLastName = _userLastName;


+(ASIFormDataRequest*) checkInFoursquare:(NSString *) venueId shout:(NSString *)shoutText
{
    NSLog(@"checking in to %@", venueId);
    NSString *access_token = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"];
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/checkins/add"];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:access_token forKey:@"oauth_token"];
    [request setPostValue:venueId forKey:@"venueId"];
    [request setPostValue:shoutText forKey:@"shout"];
    [request setPostValue:@"private" forKey:@"broadcast"];
    [request setPostValue:[NSNumber numberWithInt:vDate] forKey:@"v"];
    NSLog(@"%@", [NSString stringWithFormat:@"%@?oauth_token=%@&venueId=%@&broadcast=private&v=%i",urlString, access_token, venueId, vDate]);
    request.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"checkin", @"operation", nil]; 
    return request;

}

+(ASIHTTPRequest*)searchVenuesNearByLatitude:(NSString*)lat
						longitude:(NSString*)lon
                       categoryId:(NSString*)category
{
	
    NSString *access_token = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"];
    NSString *searchVenueURL = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search"];
    NSString *urlString = [NSString stringWithFormat:@"%@?oauth_token=%@&categoryId=%@&ll=%@,%@&limit=10&radius=500&v=%i",searchVenueURL, access_token, category, lat, lon, vDate];
    NSLog(@"hitting %@", urlString);    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    request.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"searchVenues", @"operation", nil]; 
    return request;

}

+(ASIHTTPRequest*) getUserId
{
    NSString *access_token = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"];
    NSString *getUserURL = [NSString stringWithFormat:@"https://api.foursquare.com/v2/users/self"];
    NSString *urlString = [NSString stringWithFormat:@"%@?oauth_token=%@&v=%i",getUserURL, access_token, vDate];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSLog(@"userid request url %@",urlString);
    request.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"user_id", @"operation", nil]; 
    return request; 

}


- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _userId = [attributes valueForKeyPath:@"id"];
    _userFirstName = [attributes valueForKeyPath:@"firstName"];
    _userLastName = [attributes valueForKeyPath:@"lastName"];
    
    return self;
}


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
                                              Foursquare *fsq = [[Foursquare alloc] initWithAttributes:results];
                                              NSLog(@"first: %@, last: %@", fsq.userFirstName, fsq.userLastName);
                                              
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
    [[AFFoursquareAPIClient sharedClient] setParameterEncoding:AFJSONParameterEncoding];
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
    //[[AFFoursquareAPIClient sharedClient] setParameterEncoding:AFFormURLParameterEncoding];
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
