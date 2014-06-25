//
//  ViewController.m
//  Slenderman-App
//
//  Created by Rizki Calame on 10-06-14.
//  Copyright (c) 2014 Rizki Calame. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSString *lastMajor;
    NSString *apiReq;
    
    UILabel *deadLabel;
    UIImageView *slenderView;
    
    UIButton *killButton;
    
    int timerInt;
    NSTimer *slenderTimer;
    BOOL shouldTimerFire;
    
    CLBeacon *beacon1;
    
    NSTimer *checkSlender;
    NSTimer *timeoutKill;
    
    NSMutableData *responseData;
    
    UILabel *labelHitWarning;
    
    AVAudioPlayer *audioPlayer;
    AVAudioPlayer *audioPlayer2;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
    slenderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slenderman.png"]];
    [slenderView setFrame:self.view.frame];
    [slenderView setAlpha:.2];
    [self.view addSubview:slenderView];
    
    killButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [killButton addTarget:self action:@selector(kill) forControlEvents:UIControlEventTouchUpInside];
    [killButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [killButton setTitle:@"KILL" forState:UIControlStateNormal];
    [killButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:64]];
    [killButton setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:killButton];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    lastMajor = @"";
    
    checkSlender = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(check) userInfo:nil repeats:YES];
    
    responseData = [NSMutableData data];
    
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"background2" withExtension:@"wav"];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [audioPlayer setNumberOfLoops:0];
    [audioPlayer play];
    
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    
    labelHitWarning = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    [labelHitWarning setText:@" "];
    [labelHitWarning setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:32]];
    [labelHitWarning setTextColor:[UIColor whiteColor]];
    [labelHitWarning setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:labelHitWarning];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)initRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.creatinq.slenderbeacon"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    beacon1 = [[CLBeacon alloc] init];
    
    beacon1 = [beacons objectAtIndex:0];
    
    
    // Check of dichtstbijzijnde bacon anders is dan laatste bacon
    if([lastMajor isEqualToString:[NSString stringWithFormat:@"%@", beacon1.major]]) {
        // Staat nog bij oude bacon
        NSLog(@"Oude beacon");
    } else {
        // Nieuwe bacon dichtstbijzijnde
        NSLog(@"Nieuwe beacon");
        shouldTimerFire = YES;
        
        lastMajor = [NSString stringWithFormat:@"%@", beacon1.major];
    }
    
//    if(beacon1.accuracy < 0.8) {
//        if([[NSString stringWithFormat:@"%@", beacon1.major] isEqualToString:@"961"]) {
//            [self.view setBackgroundColor:[UIColor purpleColor]];
//        } else if([[NSString stringWithFormat:@"%@", beacon1.major] isEqualToString:@"54024"]) {
//            [self.view setBackgroundColor:[UIColor greenColor]];
//        } else if([[NSString stringWithFormat:@"%@", beacon1.major] isEqualToString:@"28369"]) {
//            [self.view setBackgroundColor:[UIColor blueColor]];
//        } else {
//            [self.view setBackgroundColor:[UIColor whiteColor]];
//        }
//    } else {
//        [self.view setBackgroundColor:[UIColor whiteColor]];
//    }
}

- (void) check {
    NSString *postURL = [NSString stringWithFormat:@"http://www.hiddestatema.com/slenderman/get/"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:postURL]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    responseData = [NSMutableData data];
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSString *warning = [NSString stringWithFormat:@"%@", [[[res objectForKey:@"data"] objectForKey:@"player1"] objectForKey:@"warning"]];
    NSString *death = [NSString stringWithFormat:@"%@", [[[res objectForKey:@"data"] objectForKey:@"player1"] objectForKey:@"death"]];
    
    if(![warning isEqualToString:@"0"] && [death isEqualToString:@"0"]) {
        [labelHitWarning setText:@"YOU HIT SOMEONE"];
    
    } else if(![death isEqualToString:@"0"]) {
        [labelHitWarning setText:@"YOU KILLED SOMEONE"];
    
    } else {
        [labelHitWarning setText:@" "];
    }
    
}



-(void) kill {
    NSString *bodyData = [NSString stringWithFormat:@"%@%@%@%@%f", @"?who=0", @"&beacon=", beacon1.major, @"&distance=", beacon1.accuracy];
    NSString *completeString = [NSString stringWithFormat:@"%@%@", @"http://www.hiddestatema.com/slenderman/post/", bodyData];
    
    NSURL *postRequest = [NSURL URLWithString:completeString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postRequest cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request delegate:nil];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self disableButton];
    
    timeoutKill = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(enableButton) userInfo:nil repeats:NO];
}

- (void) disableButton {
    [killButton setTitle:@" " forState:UIControlStateNormal];
    [killButton setEnabled:NO];
}

- (void) enableButton {
    [killButton setTitle:@"KILL" forState:UIControlStateNormal];
    [killButton setEnabled:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
