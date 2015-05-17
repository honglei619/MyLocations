//
//  FirstViewController.h
//  MyLocations
//
//  Created by Lei on 15/5/18.
//  Copyright (c) 2015年 honglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CurrentLocationViewController : UIViewController<CLLocationManagerDelegate>

@property(nonatomic,weak)IBOutlet UILabel *messageLabel;
@property(nonatomic,weak)IBOutlet UILabel *latitudeLabel;
@property(nonatomic,weak)IBOutlet UILabel *longtitudeLabel;
@property(nonatomic,weak)IBOutlet UILabel *adderessLabel;
@property (nonatomic,weak) IBOutlet UIButton *tagButton;
@property(nonatomic,weak)IBOutlet UIButton *getButton;
-(IBAction)getLocaton:(id)sender;
@end

