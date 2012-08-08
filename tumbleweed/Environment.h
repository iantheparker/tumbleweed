//
//  Environment.h
//  tumbleweed
//
//  Created by Ian Parker on 8/7/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Environment : NSObject{
    
}
@property (nonatomic, retain) NSString *server_url;
@property (nonatomic, retain) NSString *foursquare_client_id;
@property (nonatomic, retain) NSString *callback_url;

+ (Environment *)sharedInstance;


@end
