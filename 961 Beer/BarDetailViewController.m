//
//  BarDetailViewController.m
//  961 Beer
//
//  Created by Georges Kanaan on 7/8/14.
//  Copyright (c) 2014 Gravity Brewing SAL. All rights reserved.
//

#import "BarDetailViewController.h"

@interface BarDetailViewController ()

@end

@implementation BarDetailViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  //get the address of the pub
  reverseGeocoder = [[CLGeocoder alloc] init];
  [reverseGeocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {//get a placemark from the coordinates
    if (placemarks.count > 0) {//if we got a placemark
      //get the placemark
      MKPlacemark *placemark = [placemarks lastObject];
      self.address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);//get the address and store it
    } else {
      //if we don't have any placemarks then set the address to an empty string
      self.address = @"";
    }
    
    //set the adress label text
    self.addressLabel.text = [NSString stringWithFormat:@"Address: %@", (![self.address isEqualToString:@""]) ? self.address : @"N/A"];//populate the address label
    
    //change the text color of the labels if no value is present
    UIColor *globalTint = [UIColor colorWithRed:0.0 green:0.47843137 blue:1.0 alpha:1.0];
    self.addressLabel.textColor = (![self.address isEqualToString:@""]) ? globalTint : [UIColor blackColor];
  }];
  
  //populate the labels
  self.nameLabel.text = [NSString stringWithFormat:@"%@", self.name];
  self.typeLabel.text = [NSString stringWithFormat:@"Type: %@", self.type];
  self.numberLabel.text = [NSString stringWithFormat:@"Phone Number: %@", (![self.phone isEqualToString:@""]) ? self.phone : @"N/A"];
  self.websiteLabel.text = [NSString stringWithFormat:@"Website: %@", (![self.website isEqualToString:@""]) ? self.website : @"N/A"];
  self.facebookLabel.text = [NSString stringWithFormat:@"Facebook: %@", (![self.facebook isEqualToString:@""]) ? self.facebook : @"N/A"];
  
  //change the text color of the labels if no value is present
  UIColor *globalTint = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
  self.facebookLabel.textColor = (![self.facebook isEqualToString:@""]) ? globalTint : [UIColor blackColor];
  self.numberLabel.textColor = (![self.phone isEqualToString:@""]) ? globalTint : [UIColor blackColor];
  self.websiteLabel.textColor = (![self.website isEqualToString:@""]) ? globalTint : [UIColor blackColor];
  
  //create a anotation
  MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
  //configure the annotation
  [annotation setCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude)];//set the coordinate
  
  //add the annotation to map
  [self.satelliteMapView addAnnotation:annotation];
  
  //show the location on the map
  [self.satelliteMapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.latitude, self.longitude), MKCoordinateSpanMake(0, 0))];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
  return YES;
}

#pragma mark - Actions
- (IBAction)back:(UIBarButtonItem *)sender {
  //dismiss the vc
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)call:(UITapGestureRecognizer *)sender {
  UIDevice *device = [UIDevice currentDevice];
  if (![[device model] isEqualToString:@"iPhone"] || [self.phone isEqualToString:@""]) {//if we can't make a call
    //show a alertView and stop the method
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Phone Number" message:@"We couldn't place this phone call as a number isn't available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    
    return;//stop the method
  }
  
  //place the call
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.phone]]];
}

- (IBAction)openMaps:(UITapGestureRecognizer *)sender {
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f",self.latitude,self.longitude]];
  if (![[UIApplication sharedApplication] canOpenURL:url]) {//if google maps isn't available
    //open in apple maps and stop the method
    //Apple Maps, using the MKMapItem class
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude) addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = self.name;
    [item openInMapsWithLaunchOptions:nil];
    
    return;
  }
  
  //give the user a choice of Apple or Google Maps
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Open in Maps" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Apple Maps", @"Google Maps", nil];
  [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  //coordinates for the place we want to display
  if (buttonIndex == 0) {
    //dismiss the action sheet
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
  } else if (buttonIndex == 1) {
    //Apple Maps, using the MKMapItem class
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude) addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = self.name;
    [item openInMapsWithLaunchOptions:nil];
    
  } else if (buttonIndex == 2) {
    //Google Maps
    //construct a URL using the comgooglemaps schema
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f",self.latitude,self.longitude]];
    [[UIApplication sharedApplication] openURL:url];
    
  }
}

- (IBAction)openWebsite:(UITapGestureRecognizer *)sender {
  
  if ([self.website isEqualToString:@""]) {//if we don't have a website
    //show a alertView and stop the method
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No URL for Website" message:@"We couldn't open the website as a URL isn't available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    
    return;//stop the method
  }
  
  //open website
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.website]];
}

- (IBAction)openFacebook:(id)sender {
  if ([self.facebook isEqualToString:@""]) {//if we don't have a facebook
    //show a alertView and stop the method
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No URL for Facebook" message:@"We couldn't open the facebook page as a URL isn't available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    
    return;//stop the method
  }
  
  //open facebook
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.facebook]];
}

- (IBAction)reportEmptyStock:(UIButton *)sender {
  //get the strings ready
  NSString *subject = @"Empty Stock";
  NSString *messageBody = [NSString stringWithFormat:@"Hello,\n\nI'm reporting empty stock at: %@, through your app.\n\n Thank you.", self.name];
  NSArray *recipents = [NSArray arrayWithObject:@"app@961beer.com"];
  
  //create a composer
  MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
  mc.mailComposeDelegate = self;
  
  //configure it
  [mc setSubject:subject];
  [mc setMessageBody:messageBody isHTML:NO];
  [mc setToRecipients:recipents];
  
  //Present mail view controller on screen
  [self presentViewController:mc animated:YES completion:nil];
  
}

#pragma mark - MFMailComposerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
  //dismiss the email composer
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  
  //if it's the user location annotation don't customize it
  if ([annotation isMemberOfClass:[MKUserLocation class]]) return nil;
  
  //try and reuse a already existing view
  MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"BeerPin"];
  
  if (!annotationView) {//if we didn't get a annotation view
    annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BeerPin"];//create it
    
    //configure the view
    annotationView.animatesDrop = YES;
    
  } else {
    //set the new annotation
    annotationView.annotation = annotation;
  }
  
  //configure the annotationView pin color
  if ([self.type isEqualToString:@"bottles"]) {
    annotationView.pinColor = MKPinAnnotationColorPurple;
    
  } else if ([self.type isEqualToString:@"draft"]) {
    annotationView.pinColor = MKPinAnnotationColorRed;
    
  } else if ([self.type isEqualToString:@"retail"]) {
    annotationView.pinColor = MKPinAnnotationColorGreen;
  }
  
  return annotationView;
}

@end
