//
//  Scene.h
//  tumbleweed
//
//  Created by Ian Parker on 2/21/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scene : NSObject{
    
    NSString *name;
    NSString *categoryId;
    NSURL *moviePath;        //or movie?
    UIImage *movieThumbnail;
    UIImage *posterArt;         
    BOOL unlocked;
    BOOL watched;
    NSDictionary *checkInResponse;
    NSDictionary *recentSearchVenueResults;
    NSDate *date;

}

@property (nonatomic, retain) NSString *name; 
@property (nonatomic, retain) NSString *categoryId; 
@property (nonatomic, retain) NSURL *moviePath;        //or movie?
@property (nonatomic, retain) UIImage *movieThumbnail;
@property (nonatomic, retain) UIImage *posterArt;         
@property (nonatomic) BOOL unlocked;
@property (nonatomic) BOOL watched;
@property (nonatomic, retain) NSDictionary *checkInResponse;
@property (nonatomic, retain) NSDictionary *recentSearchVenueResults;
@property (nonatomic, retain) NSDate *date;


@end
