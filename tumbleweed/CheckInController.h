//
//  CheckInController.h
//  tumbleweed
//
//  Created by Ian Parker on 2/3/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foursquare.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIFormDataRequest.h"
#import "NSDictionary_JSONExtensions.h"

@interface CheckInController : UIViewController <ASIHTTPRequestDelegate>{
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *photoButton;
    IBOutlet UILabel *characterCounter;
    NSDictionary *venueDetails;
    IBOutlet UILabel *venueNameLabel;
}

@property (nonatomic, retain) NSDictionary *venueDetails;
@property (nonatomic, retain) UILabel *venueNameLabel;

- (IBAction)checkIn:(id)sender;
- (IBAction)dismissModal:(id)sender;



@end
