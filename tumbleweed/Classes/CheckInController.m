//
//  CheckInController.m
//  tumbleweed
//
//  Created by Ian Parker on 2/3/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "CheckInController.h"

@interface UIView (FindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder;
@end
@implementation UIView (FindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}
@end

@implementation CheckInController{
@private
    UIColor *beigeC;
    UIColor *redC;
    UIColor *brownC;
}

@synthesize venueDetails, venueNameLabel, shoutText, characterCounter, shoutTextView, sceneControllerId, photoButton, facebookButton, twitterButton;


#pragma mark Initializers

- (id) initWithSenderId: (SceneController *) sender
{
    self = [super init];
    // Did the superclass's designated initializer succeed?
    if (self) {
        sceneControllerId = sender;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

#pragma mark Event Handlers


- (IBAction)dismissModal:(id)sender
{
    //NSLog(@"dismissing modal");
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)toggleFacebookShare:(id)sender
{
    facebookButton.selected = !facebookButton.selected;
}

- (IBAction)toggleTwitterShare:(id)sender
{
    twitterButton.selected = !twitterButton.selected;
}

- (IBAction)checkIn:(id)sender
{
    [activityIndicator startAnimating];
    NSString *broadcastType;// = [NSString stringWithFormat:@"public,%@,%@", facebookButton.selected ? @"facebook" : @"", twitterButton.selected ? @"twitter" : @""];
    NSLog(@"broadcast type %@", broadcastType);
    if (photoButton.selected){
        broadcastType = @"public";
    }
    else{
        broadcastType = [NSString stringWithFormat:@"public,%@,%@", facebookButton.selected ? @"facebook" : @"", twitterButton.selected ? @"twitter" : @""];
    }
    
    [Foursquare checkIn:[venueDetails objectForKey:@"id"] shout:shoutText broadcast:broadcastType WithBlock:^(NSDictionary *checkInResponse, NSError *error) {
        if (error) {
            NSLog(@"error checking in %@", error);
        }
        else {
            [[Tumbleweed sharedClient] setTumbleweedLevel:(sceneControllerId.scene.level + 1)];
            
            [self dismissViewControllerAnimated:YES completion:^{
                //sceneControllerId.scene.checkInResponse = checkInResponse;
                //sceneControllerId.scene.unlocked = YES;
                //idempotence - set the gamestate level to the level of this scene
                if (photoButton.selected){
                    NSString *_broadcastType = [NSString stringWithFormat:@"%@,%@", facebookButton.selected ? @"facebook" : @"", twitterButton.selected ? @"twitter" : @""];
                    NSString *checkInId = [[[checkInResponse objectForKey:@"response"] objectForKey:@"checkin"]  objectForKey:@"id"];
                    [Foursquare addPhoto:[photoButton imageForState:UIControlStateSelected] checkin:checkInId broadcast:_broadcastType];
                }
                [sceneControllerId animateRewards];
                //NSLog(@"foursquare checkinresponse %@", checkInResponse);

            }];
            
        }
    }];
}

- (IBAction)photoActionTapped:(id)sender
{
    [shoutTextView resignFirstResponder];
	//show the app menu
	[[[UIActionSheet alloc] initWithTitle:@"Add a photo to this Foursquare check-in" delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Take photo", @"Choose From Library", @"Remove Last Photo", nil]
	 showInView:self.view];
}

-(void)takePhoto: (NSInteger)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    switch (sourceType) {
        case UIImagePickerControllerSourceTypeCamera:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case UIImagePickerControllerSourceTypePhotoLibrary:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
    }
    imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    
    [self presentModalViewController:imagePickerController animated:YES];
}

#pragma mark -
#pragma mark - Image picker delegate methods
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // Resize the image from the camera
	//UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(photoButton.frame.size.width, photoButton.frame.size.height) interpolationQuality:kCGInterpolationHigh];
    // Crop the image to a square (yikes, fancy!)
    //UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -photo.frame.size.width)/2, (scaledImage.size.height -photo.frame.size.height)/2, photo.frame.size.width, photo.frame.size.height)];
    // Show the photo on the screen
    //photo.image = croppedImage;
    [photoButton setImage:image forState:UIControlStateSelected];
    photoButton.selected = YES;
    [picker dismissModalViewControllerAnimated:NO];
    [photoButton.layer setBorderColor:[redC CGColor]];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark UIActionSheetDelegate protocol
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self takePhoto:UIImagePickerControllerSourceTypeCamera];
			break;
        case 1:
            [self takePhoto:UIImagePickerControllerSourceTypePhotoLibrary];
			break;
        case 2:
            //clear old photo
            [photoButton.layer setBorderColor:[beigeC CGColor]];
            photoButton.selected = NO;
            break;

    }
}

#pragma mark -
#pragma mark UITextViewDelegate protocol


- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{    
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    shoutText = shoutTextView.text;
    NSLog(@"%@", shoutText);

    [txtView resignFirstResponder];
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    characterCounter.text = [NSString stringWithFormat:@"%d/140", (140 - shoutTextView.text.length)];
    [shoutTextView setTextColor:brownC];
    [shoutTextView.layer setBorderColor:[redC CGColor]];

}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view findAndResignFirstResponder];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //Set UIColors
    brownC = [UIColor colorWithRed:62.0/255.0 green:43.0/255.0 blue:26.0/255.0 alpha:1.0];
    beigeC = [UIColor colorWithRed:163.0/255.0 green:151.0/255.0 blue:128.0/255.0 alpha:1.0];
    redC = [UIColor colorWithRed:212.0/255.0 green:83.0/255.0 blue:88.0/255.0 alpha:1.0];
    
    NSString *venueName = [venueDetails objectForKey:@"name"];
    [venueNameLabel setText:venueName];
    [venueNameLabel setFont:[UIFont fontWithName:@"rockwell-bold" size:30]];
    [venueNameLabel setTextColor:brownC];
    
    shoutText = @"Woah! I just unlocked a scene from the movie No Man's Land with this check-in. Thanks tumbleweed!";
    shoutTextView.text = shoutText;
    NSLog(@"shoutText is %@", shoutText);
    shoutTextView.layer.cornerRadius = 10.0;
    shoutTextView.clipsToBounds = YES;
    [shoutTextView.layer setBorderColor:[beigeC CGColor]];
    [shoutTextView.layer setBorderWidth:3.0];
    [shoutTextView setFont:[UIFont fontWithName:@"Rockwell" size:15]];
    [shoutTextView setTextColor:beigeC];
    [characterCounter setTextColor:[UIColor grayColor]];
    
    photoButton.layer.cornerRadius = 10.0;
    photoButton.clipsToBounds = YES;
    [photoButton.layer setBorderColor:[beigeC CGColor]];
    [photoButton.layer setBorderWidth:3.0];

    
}

- (void)viewDidUnload
{
    venueNameLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);

}

@end
