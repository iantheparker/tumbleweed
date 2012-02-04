//
//  CheckInController.h
//  tumbleweed
//
//  Created by Ian Parker on 2/3/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckInController : UIViewController{
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
