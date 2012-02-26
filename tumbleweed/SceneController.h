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
#import "Scene.h"


@interface SceneController : UIViewController <CLLocationManagerDelegate, ASIHTTPRequestDelegate>
{
    IBOutlet UIView *rewardBar;
    IBOutlet UIScrollView *venueScrollView;
    IBOutlet UIView *venueDetailNib;
    IBOutlet UIImageView *movieThumbnailImageView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    CLLocationManager *locationManager;
    MPMoviePlayerViewController *moviePlayer;
    NSMutableDictionary *allVenues;
    Scene *scene;
    
}

@property (nonatomic, retain) UIScrollView *venueScrollView;
@property (nonatomic, retain) UIView *venueDetailNib;
@property (nonatomic, retain) UIImageView *movieThumbnailImageView;
@property (nonatomic, retain) CLLocationManager *locationManager; 
@property (nonatomic, retain) MPMoviePlayerViewController *moviePlayer;
@property (nonatomic, retain) NSMutableDictionary *allVenues;
@property (nonatomic, retain) Scene *scene;

//initializers
- (id) initWithScene: (Scene *) scn;

- (IBAction) dismissModal:(id)sender;
- (void) launchVideoPlayer;
- (void) processVenues: (NSArray *) items;
- (void) processRewards;
- (void) animateRewards;

// touch events
- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender;


@end
