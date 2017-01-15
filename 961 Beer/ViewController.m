//
//  ViewController.m
//  961 Beer
//
//  Created by Georges Kanaan on 7/7/14.
//  Copyright (c) 2014 Gravity Brewing SAL. All rights reserved.
//

#import "ViewController.h"

#define kTagFirst 111
#define kTagSecond 112
#define kTagThird 113
#define kTagThourth 114

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //get new json data
    [self reloadData];
    
    //set the segmented control segments text color
    //set the tags first
    [self.filterSC setTag:kTagFirst forSegmentAtIndex:0];
    [self.filterSC setTag:kTagSecond forSegmentAtIndex:1];
    [self.filterSC setTag:kTagThird forSegmentAtIndex:2];
    [self.filterSC setTag:kTagThourth forSegmentAtIndex:3];
    
    //no idea why we have to mix the colors like this to get the expected result
    [self.filterSC setTintColor:[UIColor redColor] forTag:kTagFirst];
    [self.filterSC setTintColor:[UIColor colorWithRed:0.7 green:0.0 blue:0.7 alpha:1.0] forTag:kTagSecond];
    [self.filterSC setTintColor:[UIColor blackColor] forTag:kTagThird];
    [self.filterSC setTintColor:[UIColor greenColor] forTag:kTagThourth];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //get new json data
    [self reloadData];
    
    //ask for location permission
    [[CLLocationManager new] requestWhenInUseAuthorization];
}

#pragma mark - Data Management
-(IBAction)reloadData {
    //reload the data synchronously on another thread
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //disable the refresh button so we don't get multiple requests
        self.refreshButton.enabled = NO;
        
        //start fetching the data according to the currently selected filter
        [self filterPins:self.filterSC];
        
        //enable the refresh button
        self.refreshButton.enabled = YES;
        
    });
}

#pragma mark Retrieving Data
-(NSArray *)getJsonData {
    //declare the json dict
    __block NSArray *beerData = nil;
    
    //get json data
    //get the url
    NSURL *url = [[NSURL alloc] initWithString:@"https://appdata.ge0rges.com/961Beer/961BeerData.json"];
    
    //variables to store reposne and error
    NSURLResponse *response;
    NSError *error;
    
    //send the request
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:&error];
    
    if (error || !response) {//if we got an error or the response is empty
        //attempt to get the data form the saved files
        //get the file path
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
        
        beerData = [NSArray arrayWithContentsOfFile:filePath];//get the array from the file
        
        if (!beerData || beerData.count == 0) {//if the array is empty
            //show a alert view
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No more beer in the keg. Please verify your internet connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } else if (response) {//otherwise if we got a response
        
        beerData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {//if we got an error parsing
            //attempt to get the data form the saved files
            //get the file path
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
            
            beerData = [NSArray arrayWithContentsOfFile:filePath];//get the array from the file
            
            if (!beerData || beerData.count == 0) {//if the array is empty
                //show a alert view
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No more beer in the keg. Please verify your internet connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }

            //show an alert view
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The beer was contaminated. It seems the current data isn't valid. This issue should be fixed soon. Thank you for your patience." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        } else {//otherwise
            //save it to the file for offline use
            //get the file path
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
            
            [beerData writeToFile:filePath atomically:YES];//write the array to the plist
        }
    }
    
    
    return beerData;
}

#pragma mark - MKMapView
#pragma mark MKMapViewDelegate & Showing pins
-(void)showPinsOnMapForDictionnary:(NSArray *)dicArray {
    if (dicArray) {
        //first remove the old annotations
        [self.map removeAnnotations:[self.map annotations]];
        
        for (NSDictionary *pub in dicArray) {//For each dic we find (pub)
            //create a anotation
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            //configure the annotation
            [annotation setCoordinate:CLLocationCoordinate2DMake([[pub objectForKey:@"latitude"] floatValue], [[pub objectForKey:@"longitude"] floatValue])];//set the coordinate
            
            //set the title
            [annotation setTitle:[pub objectForKey:@"name"]];
            
            //set the color reference in the title
            if ([[pub objectForKey:@"type"] isEqualToString:@"bottles"]) {
                [annotation setTitle:[NSString stringWithFormat:@"%@-purple", annotation.title]];
            
            } else if ([[pub objectForKey:@"type"] isEqualToString:@"draft"]) {
                [annotation setTitle:[NSString stringWithFormat:@"%@-red", annotation.title]];
            
            } else if ([[pub objectForKey:@"type"] isEqualToString:@"retail"]) {
                [annotation setTitle:[NSString stringWithFormat:@"%@-green", annotation.title]];
            
            }
            
            //if we have a phone number then set it as a subtitle otherwise use website
            if ([pub objectForKey:@"phone"]) {
                [annotation setSubtitle:[pub objectForKey:@"phone"]];
            
            } else if ([pub objectForKey:@"website"]) {
                [annotation setSubtitle:[pub objectForKey:@"website"]];
            }

            
            //add the annotation to map
            [self.map addAnnotation:annotation];
        }
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    //if it's the user location annotation don't customize it
    if ([annotation isMemberOfClass:[MKUserLocation class]]) return nil;

    //try and reuse a already existing view
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"BeerPin"];
    
    if (!annotationView) {//if we didn't get a annotation view
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BeerPin"];//create it
        
        //configure the view
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        
        //add a info button
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.rightCalloutAccessoryView = infoButton;

    } else {
        //set the new annotation
        annotationView.annotation = annotation;
    }
    
    //configure the annotationView pin color
    MKPointAnnotation *pin = (MKPointAnnotation *)annotation;
    
    if ([pin.title rangeOfString:@"-purple"].location != NSNotFound) {
        annotationView.pinColor = MKPinAnnotationColorPurple;
        pin.title = [pin.title stringByReplacingOccurrencesOfString:@"-purple" withString:@""];

    } else if ([pin.title rangeOfString:@"-red"].location != NSNotFound) {
        annotationView.pinColor = MKPinAnnotationColorRed;
        pin.title = [pin.title stringByReplacingOccurrencesOfString:@"-red" withString:@""];
        
    } else if ([pin.title rangeOfString:@"-green"].location != NSNotFound) {
        annotationView.pinColor = MKPinAnnotationColorGreen;
        pin.title = [pin.title stringByReplacingOccurrencesOfString:@"-green" withString:@""];
    
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    //if it's the user location annotation don't do anything
    if ([view.annotation isMemberOfClass:[MKUserLocation class]]) return;

    //get the detail view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BarDetailViewController *bdvc = [storyboard instantiateViewControllerWithIdentifier:@"BarDetail"];
    
    //get the pin
    MKPointAnnotation *pin = (MKPointAnnotation *)view.annotation;
    
    //get the json data for this pin
    NSDictionary *pub = [self getJsonDataForPinWithTitle:pin.title];
    
    //set the porperties of the vc
    bdvc.latitude = pin.coordinate.latitude;
    bdvc.longitude = pin.coordinate.longitude;
    
    bdvc.name = pin.title;
    bdvc.website = [pub objectForKey:@"website"];
    bdvc.facebook = [pub objectForKey:@"facebook"];
    bdvc.phone = [pub objectForKey:@"phone"];
    bdvc.type = [pub objectForKey:@"type"];

    //show the detail info
    [self presentViewController:bdvc animated:YES completion:nil];
}

-(NSDictionary *)getJsonDataForPinWithTitle:(NSString *)title {
    NSArray *pubs = [self getJsonData];
    for (NSDictionary *pub in pubs) {
        if ([[pub objectForKey:@"name"] isEqualToString:title]) {
            return pub;
        }
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    //hide the segmented control
    [UIView animateWithDuration:0.2 animations:^{self.filterSC.alpha = 0.0;}];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //get the touch location
    CGPoint location = [[touches anyObject] locationInView:self.view];
    
    if ([self.map pointInside:location withEvent:event]) {//if the map was tapped
        //show the filterSC
        [UIView animateWithDuration:0.2 animations:^{self.filterSC.alpha = 1.0;}];
    }
}

#pragma mark - Actions
-(IBAction)filterPins:(UISegmentedControl *)sender {
    //filter pins by the type selected
    if (self.filterSC.selectedSegmentIndex == 0) {
        //filter by bottles
        NSMutableArray *data = [[self getJsonData] mutableCopy];//get all the data
        NSMutableArray *validData = [NSMutableArray new];//create an array to store the data we want
        for (NSDictionary *pub in data) {//for each location
            if ([[pub objectForKey:@"type"] isEqualToString:@"bottles"]) {//if the type is not bottles
                [validData addObject:pub];//add it to the valid array
            }
        }
        [self showPinsOnMapForDictionnary:validData];//load the valid pins
    
    } else if (self.filterSC.selectedSegmentIndex == 1) {
        //filter by draft
        NSMutableArray *data = [[self getJsonData] mutableCopy];//get all the data
        NSMutableArray *validData = [NSMutableArray new];//create an array to store the data we want
        for (NSDictionary *pub in data) {//for each location
            if ([[pub objectForKey:@"type"] isEqualToString:@"draft"]) {//if the type is not draft
                [validData addObject:pub];//add it to the valid array
            }
        }
        [self showPinsOnMapForDictionnary:validData];//load the valid pins
    
    } else if (self.filterSC.selectedSegmentIndex == 2) {
        //filter by draft
        NSMutableArray *data = [[self getJsonData] mutableCopy];//get all the data
        NSMutableArray *validData = [NSMutableArray new];//create an array to store the data we want
        for (NSDictionary *pub in data) {//for each location
            if ([[pub objectForKey:@"type"] isEqualToString:@"retail"]) {//if the type is not retail
                [validData addObject:pub];//add it to the valid array
            }
        }
        [self showPinsOnMapForDictionnary:validData];//load the valid pins
   
    } else if (self.filterSC.selectedSegmentIndex == 3) {
        //show all
        [self showPinsOnMapForDictionnary:[self getJsonData]];//load all pins
    }
}

- (IBAction)reportNewSalePlace:(UIButton *)sender {
    if (self.map.userLocationVisible) {//make sure we have the user location
        //get the strings ready
        NSString *subject = @"New Seller";
        NSString *messageBody = [NSString stringWithFormat:@"Hello,\n\nI've noticed your map doesn't contain the following 961 Beer seller. Here is his information:\n\n Name:\nPhone Number:\nType: (draft, bottles, retail)\n Facebook:\n Website:\n Coordinates:%f,%f\n\nThank you.", self.map.userLocation.coordinate.longitude, self.map.userLocation.coordinate.latitude];
        NSArray *recipents = [NSArray arrayWithObject:@"app@961beer.com"];
        
        //create a composer
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        
        //configure it
        [mc setSubject:subject];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:recipents];
        
        //Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:^{
            //show the alertView after the presentation to not have a discolored interface
            [[[UIAlertView alloc] initWithTitle:@"Warning"message:@"For this feature to work you must be within 10 meters of the seller. Your current location will then be sent anonymously (you can check the email) to us so we can verify the seller. Your email is not stored by us." delegate:nil cancelButtonTitle:@"Ok"otherButtonTitles:nil, nil] show];
        }];
    
    } else {
        //show a alert view
        [[[UIAlertView alloc] initWithTitle:@"Error"message:@"Could not generate a 'New seller' submission email as we were not able to get your current location. Please make sure location services are enabled under Privacy > Location Services > 961 Beer in the settings app." delegate:nil cancelButtonTitle:@"Ok"otherButtonTitles:nil, nil] show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    //dismiss the email composer
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
