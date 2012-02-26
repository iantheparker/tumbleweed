//
//  Tumbleweed.m
//  tumbleweed
//
//  Created by Ian Parker on 2/20/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "Tumbleweed.h"
#import "Foursquare.h"

@implementation Tumbleweed

- (id) init
{
    self = [super init];
    if (self) {
        
        //Gas Station
        gasStation.name = @"gasStation";
        gasStation.categoryId = GAS_TRAVEL_catId;
        gasStation.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                      ofType:@"mp4"]];
        gasStation.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
        gasStation.posterArt = [UIImage imageNamed:@"bubble5.png"];
        
        //Deal Scene
        deal.name = @"deal";
        deal.categoryId = DEAL_catId;
        deal.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                ofType:@"mp4"]];
        deal.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
        deal.posterArt = [UIImage imageNamed:@"bubble5.png"];
        
        //Bar Scene
        bar.name = @"bar";
        bar.categoryId = NIGHTLIFE_catId;
        bar.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                ofType:@"mp4"]];
        bar.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
        bar.posterArt = [UIImage imageNamed:@"bubble5.png"];
        
        //Riverbed Scene 1
        riverBed1.name = @"river";
        riverBed1.categoryId = OUTDOORS_catId;
        riverBed1.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                ofType:@"mp4"]];
        riverBed1.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
        riverBed1.posterArt = [UIImage imageNamed:@"bubble5.png"];
        
        //Riverbed Scene 2
        riverBed2.name = @"deal";
        riverBed2.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                ofType:@"mp4"]];
        riverBed2.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
        riverBed2.posterArt = [UIImage imageNamed:@"bubble5.png"];
        
        //Desert Chase
        desertChase.name = @"desertChase";
        desertChase.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                ofType:@"mp4"]];
        desertChase.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
        desertChase.posterArt = [UIImage imageNamed:@"bubble5.png"];
        
        //Desert Lynch
        desertLynch.name = @"desertLynch";
        desertLynch.categoryId = OUTDOORS_catId;
        desertLynch.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                ofType:@"mp4"]];
        desertLynch.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
        desertLynch.posterArt = [UIImage imageNamed:@"bubble5.png"];
        
        //Campfire Scene
        campFire.name = @"deal";
        campFire.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                ofType:@"mp4"]];
        campFire.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
        campFire.posterArt = [UIImage imageNamed:@"bubble5.png"];
    }
    return self;
}


@end
