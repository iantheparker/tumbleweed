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

// Foursquare category IDs
#define GAS_TRAVEL_catId    @"4bf58dd8d48988d113951735,4d4b7105d754a06379d81259"
#define DEAL_catId          @"4d4b7105d754a06378d81259"
#define NIGHTLIFE_catId     @"4d4b7105d754a06376d81259"
#define OUTDOORS_catId      @"4d4b7105d754a06377d81259"


@interface Foursquare : NSObject 
{
    
}


+(ASIFormDataRequest*) checkInFoursquare:(NSString *) venueId 
                                shout:(NSString *) shoutText;
+(ASIHTTPRequest*)searchVenuesNearByLatitude:(NSString*)lat
						longitude:(NSString*)lon
                       categoryId:(NSString*)category;
+(ASIHTTPRequest*) getUserId;

@end
