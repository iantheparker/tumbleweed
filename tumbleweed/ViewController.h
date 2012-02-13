//
//  ViewController.h
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>

// Foursquare category IDs
#define GAS_TRAVEL_catId    @"4bf58dd8d48988d113951735,4d4b7105d754a06379d81259"
#define DEAL_catId          @"4d4b7105d754a06378d81259"
#define NIGHTLIFE_catId     @"4d4b7105d754a06376d81259"
#define OUTDOORS_catId      @"4d4b7105d754a06377d81259"

@interface ViewController : UIViewController <UIScrollViewDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *map;
    IBOutlet UIImageView *avatar;
    NSMutableArray *sprites;
    IBOutlet UIButton *gasStationButton;
    IBOutlet UIButton *foursquareConnectButton;
    int lastContentOffset;
    BOOL walkingForward;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *map;
@property (nonatomic, retain) UIImageView *avatar;
@property (nonatomic, retain) NSMutableArray *sprites;
@property BOOL walkingForward;
@property (nonatomic, retain) UIButton *gasStationButton;
@property (nonatomic, retain) UIButton *foursquareConnectButton;

//-- instance methods
- (void) renderJane: (BOOL) direction;
- (UIImage *) selectAvatarImage:(float) position;
- (void) saveAvatarPosition;

//-- event handlers
- (IBAction) foursquareConnect:(UIButton *)sender;
- (IBAction) gasStationPressed:(UIButton *)sender;
- (IBAction) dealPressed:(UIButton *)sender;
- (IBAction) barPressed:(UIButton *)sender;
- (IBAction) riverbedPressed:(UIButton *)sender;




@end
