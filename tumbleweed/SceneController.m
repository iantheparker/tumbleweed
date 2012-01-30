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

@synthesize venueView, venueScrollView;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"];
    
    // build the url with query string
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?oauth_token=%@&ll=%@",access_token, @"40.759011,-73.9844722"];
    NSLog(@"hitting %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *err;
    
    // fetch the data (TODO async)
    NSString *venues = [NSString stringWithContentsOfURL:url 
                                                encoding:NSUTF8StringEncoding 
           
                                                   error:&err];
    // parse into dict
    NSDictionary *venuesDict = [NSDictionary dictionaryWithJSONString:venues 
                                                                error:&err];


    NSLog(@"processing foursquare venues");
    NSDictionary *response = [venuesDict objectForKey:@"response"];
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
        UILabel *venueLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(offset, 0.0, 100.0, 30.0) ];
        
        offset += 120;
        [venueLabel setText:name];
        [venueView addSubview:venueLabel];
        // NSLog(@"item %d is called %@", i, name);
    }
   
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
