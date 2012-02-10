//
//  SceneController.h
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIHTTPRequestDelegate.h"
#import <MediaPlayer/MediaPlayer.h>


@interface SceneController : UIViewController <CLLocationManagerDelegate, ASIHTTPRequestDelegate>
{
    IBOutlet UIScrollView *venueScrollView;
    IBOutlet UIView *venueDetailNib;
    IBOutlet UIScrollView *rewardScrollView;
    IBOutlet UIView *rewardView;
    CLLocationManager *locationManager;
    MPMoviePlayerViewController *moviePlayer;
    NSMutableDictionary *allVenues;
    
}

@property (nonatomic, retain) UIScrollView *venueScrollView;
@property (nonatomic, retain) UIView *venueDetailNib;
@property (nonatomic, retain) UIScrollView *rewardScrollView;
@property (nonatomic, retain) UIView *rewardView;
@property (nonatomic, retain) CLLocationManager *locationManager; 
@property (nonatomic, retain) MPMoviePlayerViewController *moviePlayer;
@property (nonatomic, retain) NSMutableDictionary *allVenues;


- (IBAction) dismissModal:(id)sender;
- (void) processVenues: (NSArray *) items;
- (void) processRewards;

// touch events
- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender;


@end
