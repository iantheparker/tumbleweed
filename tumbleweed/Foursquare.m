//
//  Foursquare.m
//  tumbleweed
//
//  Created by Ian Parker on 2/2/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Foursquare.h"



@implementation Foursquare

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
    request.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"checkin", @"operation", nil]; 
    return request;

}

+(ASIHTTPRequest*)searchVenuesNearByLatitude:(NSString*)lat
						longitude:(NSString*)lon
                       categoryId:(NSString*)category
{
	
    NSString *access_token = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"];
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?oauth_token=%@&categoryId=%@&ll=%@,%@&limit=5",access_token, category, lat, lon];
    NSLog(@"hitting %@", urlString);    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    request.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"searchVenues", @"operation", nil]; 
    return request;

}


    



@end
