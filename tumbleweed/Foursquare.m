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
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"], @"oauth_token",
                                 [NSNumber numberWithInt:vDate], @"v", nil];
    [[AFFoursquareAPIClient sharedClient] getPath:@"users/self" parameters:queryParams
                                          success:^(AFHTTPRequestOperation *operation, id response) {
                                              NSDictionary *results = [[response objectForKey:@"response"] objectForKey:@"user"];
                                              //NSLog(@"user = %@", results);
                                              if (block) {
                                                  block(results, nil);
                                              }
                                              
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              if (block) {
                                                  block([NSDictionary dictionary], error);
                                                  NSLog(@"error from getUser %@", error);
                                              }
                                          }];
}

+ (void)searchVenuesNearByLatitude:(NSString*)lat
                         longitude:(NSString*)lon
                        categoryId:(NSString*)category
                         WithBlock:(void (^)(NSArray *venues, NSError *error))block
{
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%@,%@", lat, lon], @"ll",
                                 @"5", @"limit",
                                 @"200", @"radius",
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
      broadcast:(NSString*) broadcastType
      WithBlock:(void (^)(NSDictionary *checkInResponse, NSError *error))block
{
    if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuration"] isEqualToString:@"Debug"]) broadcastType = @"private";
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 venueId, @"venueId",
                                 shoutText, @"shout",
                                 broadcastType, @"broadcast",
                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"], @"oauth_token",
                                 [NSNumber numberWithInt:vDate], @"v", nil];
    [[AFFoursquareAPIClient sharedClient] setParameterEncoding:AFFormURLParameterEncoding];
    [[AFFoursquareAPIClient sharedClient] postPath:@"checkins/add" parameters:queryParams
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

+ (void)addPhoto:(UIImage*) image
         checkin:(NSString*) checkInId
       broadcast:(NSString*) broadcastType
{
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 checkInId, @"checkinId",
                                 broadcastType, @"broadcast",
                                 [NSNumber numberWithInt:1], @"public",
                                 [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"], @"oauth_token",
                                 [NSNumber numberWithInt:vDate], @"v", nil];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    NSMutableURLRequest *request = [[AFFoursquareAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                                   path:@"photos/add"
                                                                                             parameters:queryParams
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"foursquare photo added!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"foursquare photo error %@", error);
    }];
    [[AFFoursquareAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
}


@end
