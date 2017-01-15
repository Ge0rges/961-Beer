//
//  ViewController.h
//  961 Beer
//
//  Created by Georges Kanaan on 7/7/14.
//  Copyright (c) 2014 Gravity Brewing SAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#include <CoreLocation/CoreLocation.h>
#include <MessageUI/MessageUI.h>
#import "BarDetailViewController.h"
#import "UISegmentedControlExtension.h"

@interface ViewController : UIViewController <MKMapViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UISegmentedControl *filterSC;
@property (strong, nonatomic) IBOutlet MKMapView *map;

@end

