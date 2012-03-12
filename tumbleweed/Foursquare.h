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


@interface Foursquare : NSObject 
{
    
}


+(ASIFormDataRequest*) checkInFoursquare:(NSString *) venueId 
                                shout:(NSString *) shoutText;
+(ASIHTTPRequest*)searchVenuesNearByLatitude:(NSString*)lat
						longitude:(NSString*)lon
                       categoryId:(NSString*)category;


@end
