//
//  BarDetailViewController.h
//  961 Beer
//
//  Created by Georges Kanaan on 7/8/14.
//  Copyright (c) 2014 Gravity Brewing SAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#include <CoreLocation/CoreLocation.h>
#include <AddressBookUI/AddressBookUI.h>
#include <MessageUI/MessageUI.h>

@interface BarDetailViewController : UIViewController <MKMapViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {
    CLGeocoder *reverseGeocoder;//will be used to get the address of the pub
}

@property (strong, nonatomic) IBOutlet UIButton *reportButton;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSString *facebook;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *phone;

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UILabel *websiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *facebookLabel;

@property (strong, nonatomic) IBOutlet MKMapView *satelliteMapView;

@end
