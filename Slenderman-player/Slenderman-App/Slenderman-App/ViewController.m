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
    
    UIButton *killButton;
    
    int timerInt;
    NSTimer *slenderTimer;
    BOOL shouldTimerFire;
    
    CLBeacon *beacon1;
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
    
    killButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 200)];
    [killButton addTarget:self action:@selector(kill) forControlEvents:UIControlEventTouchUpInside];
    [killButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [killButton setTitle:@"Kill" forState:UIControlStateNormal];
    [killButton setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:killButton];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    lastMajor = @"";
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
    
    if(beacon1.accuracy < 0.8) {
        if([[NSString stringWithFormat:@"%@", beacon1.major] isEqualToString:@"961"]) {
            [self.view setBackgroundColor:[UIColor purpleColor]];
        } else if([[NSString stringWithFormat:@"%@", beacon1.major] isEqualToString:@"54024"]) {
            [self.view setBackgroundColor:[UIColor greenColor]];
        } else if([[NSString stringWithFormat:@"%@", beacon1.major] isEqualToString:@"28369"]) {
            [self.view setBackgroundColor:[UIColor blueColor]];
        } else {
            [self.view setBackgroundColor:[UIColor whiteColor]];
        }
    } else {
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
}



-(void) kill {
    NSString *bodyData = [NSString stringWithFormat:@"%@%@%@%@%f", @"?who=0", @"&beacon=", beacon1.major, @"&distance=", beacon1.accuracy];
    NSString *completeString = [NSString stringWithFormat:@"%@%@", @"http://www.hiddestatema.com/slenderman/post/", bodyData];
    
    NSURL *postRequest = [NSURL URLWithString:completeString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postRequest cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyData dataUsingEncoding:NSUTF8StringEncoding]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
