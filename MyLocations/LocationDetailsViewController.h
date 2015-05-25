//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Lei on 15/5/21.
//  Copyright (c) 2015年 honglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationDetailsViewController : UITableViewController

@property(nonatomic,assign)CLLocationCoordinate2D coordinate;
@property(nonatomic,assign)CLPlacemark *placemark;

@end
