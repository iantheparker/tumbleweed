//
//  ViewController.h
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Scene.h"
#import "Tumbleweed.h"



@interface TumbleweedViewController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate>
{
    Tumbleweed *weed;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *sky;
    IBOutlet UIImageView *map1;
    IBOutlet UIImageView *map2;
    IBOutlet UIImageView *map4;
    IBOutlet UIImageView *avatar;
    NSMutableArray *sprites;
    int lastContentOffset;
    BOOL walkingForward;
    //-- buttons
    IBOutlet UIButton *foursquareConnectButton;
    IBOutlet UIButton *gasStationButton;
    IBOutlet UIButton *dealButton;
    IBOutlet UIButton *barButton;
    IBOutlet UIButton *riverBed1Button;
    IBOutlet UIButton *riverBed2Button;
    IBOutlet UIButton *desertChaseButton;
    IBOutlet UIButton *desertLynchButton;
    IBOutlet UIButton *campFireButton;

    
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *sky;
@property (nonatomic, retain) UIImageView *map1;
@property (nonatomic, retain) UIImageView *map2;
@property (nonatomic, retain) UIImageView *map4;
@property (nonatomic, retain) UIImageView *avatar;
@property (nonatomic, retain) NSMutableArray *sprites;
@property BOOL walkingForward;
@property (nonatomic, retain) Tumbleweed *weed;
@property (nonatomic, retain) CLLocationManager *locationManager;


//-- buttons
@property (nonatomic, retain) UIButton *foursquareConnectButton;
@property (nonatomic, retain) UIButton *gasStationButton;
@property (nonatomic, retain) UIButton *dealButton;
@property (nonatomic, retain) UIButton *barButton;
@property (nonatomic, retain) UIButton *riverBed1Button;
@property (nonatomic, retain) UIButton *riverBed2Button;
@property (nonatomic, retain) UIButton *desertChaseButton;
@property (nonatomic, retain) UIButton *desertLynchButton;
@property (nonatomic, retain) UIButton *campFireButton;

//-- instance methods
- (void) renderScreen: (BOOL) direction;
- (UIImage *) selectAvatarImage:(float) position;
- (void) saveAvatarPosition;

//-- event handlers
- (IBAction) foursquareConnect:(UIButton *)sender;
- (IBAction) gasStationPressed:(UIButton *)sender;
- (IBAction) dealPressed:(UIButton *)sender;
- (IBAction) barPressed:(UIButton *)sender;
- (IBAction) riverbed1Pressed:(UIButton *)sender;
- (IBAction) riverbed2Pressed:(UIButton *)sender;
- (IBAction) desertChasePressed:(UIButton *)sender;
- (IBAction) desertLynchPressed:(UIButton *)sender;
- (IBAction) campFirePressed:(UIButton *)sender;

//--game state
- (void) gameState;
- (void)scheduleNotificationWithDate:(NSDate *)date intervalTime:(int) timeinterval;
- (void)startSignificantChangeUpdates;




@end
