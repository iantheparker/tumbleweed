//
//  SceneController.m
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "SceneController.h"

#import "CJSONDeserializer.h"
#import "NSDictionary_JSONExtensions.h"

@implementation SceneController

@synthesize venueView, venueScrollView, venueDetailNib;

//-- Event Handlers
- (IBAction)dismissModal:(id)sender
{
    NSLog(@"dismissing modal");
    [self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) processVenues: (NSDictionary *) dict
{
        
    NSLog(@"processing foursquare venues");
    NSDictionary *response = [dict objectForKey:@"response"];
    NSArray *groups = [response objectForKey:@"groups"];
    NSDictionary *group1 = [groups objectAtIndex:0];
    NSArray *items = [group1 objectForKey:@"items"];
    
    float scrollWidth = [items count] * 120;
    CGSize screenSize = CGSizeMake(scrollWidth, venueScrollView.contentSize.height);
    
    venueScrollView.contentSize = screenSize;
    
    int offset = 0;
    for (int i = 0; i < [items count]; i++) {
        NSDictionary *ven = [items objectAtIndex:i];
        NSString *name = [ven objectForKey:@"name"];
        NSDictionary *location = [ven objectForKey:@"location"];
        NSString *address = [location objectForKey:@"address"];
        NSString *distance = [location objectForKey:@"distance"];
        
        [[NSBundle mainBundle] loadNibNamed:@"ListItemScrollView" owner:self options:nil];
        UILabel *nameLabel = (UILabel *)[venueDetailNib viewWithTag:1];
        [nameLabel setText:name];
        
        float nibwidth = venueDetailNib.frame.size.width;
        float nibheight = venueDetailNib.frame.size.height; 
        int padding = 2;
        offset = (int)(nibwidth + padding) * i; 
        CGPoint nibCenter = CGPointMake(offset, nibheight/2);
        
        [venueDetailNib setCenter:nibCenter];
        [venueView addSubview:venueDetailNib];
        NSLog(@"venue %d is named %@, is at %@, which is %@ miles from you", i, name, address, distance);
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *access_token = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"];
    
    // build the url with query string
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?oauth_token=%@&ll=%@",access_token, @"40.759011,-73.9844722"];
    NSLog(@"hitting %@", urlString);
    
    // fetch the data asyncronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:urlString];
        NSError *err;
        NSLog(@"the url is %@", url);
        
        NSString *venues = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        // parse into dict
        NSDictionary *venuesDict = [NSDictionary dictionaryWithJSONString:venues error:&err];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self processVenues:venuesDict];
        });
    });
    
    

    
}

- (void)viewDidUnload
{
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
