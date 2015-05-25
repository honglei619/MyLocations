//
//  FirstViewController.m
//  MyLocations
//
//  Created by Lei on 15/5/18.
//  Copyright (c) 2015年 honglei. All rights reserved.
//

#import "CurrentLocationViewController.h"

#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)

@interface CurrentLocationViewController ()

@end

@implementation CurrentLocationViewController{
    CLLocationManager *_locationManager;
    CLLocation *_location;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    BOOL _performingReverseGeocoding;
    NSError *_lastGeocodingError;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if((self = [super initWithCoder:aDecoder])){
        _locationManager = [[CLLocationManager alloc]init];
        _geocoder = [[CLGeocoder alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLabels];
    [self configureGetButton];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)getLocaton:(id)sender{
    if (_updatingLocation) {
        [self stopLocationManager];
    }else{
        _location = nil;
        _lastLocationError = nil;
        _placemark = nil;
        _lastGeocodingError = nil;
        [self startLocaltionManager];
    }
    [self updateLabels];
    [self configureGetButton];

}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"TagLocation"]){
        UINavigationController *navitationController = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController*)navitationController.topViewController;
        controller.coordinate = _location.coordinate;
        controller.placemark = _placemark;
         }
}
#pragma mark -CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位失败:%@",error);
    if(error.code == kCLErrorLocationUnknown){
        return;
    }
    [self stopLocationManager];
    _lastLocationError = error;
    [self updateLabels];
    [self configureGetButton];
}

-(void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"已更新坐标，当前位置是:%@",newLocation);
    //[self updateLabels];
    if ([newLocation.timestamp timeIntervalSinceNow]<-5.0) {
        return;
    }
    if (newLocation.horizontalAccuracy<0) {
        return;
    }
    CLLocationDistance distance =MAXFLOAT;
    if (_location !=nil) {
        distance = [newLocation distanceFromLocation:_location];
    }
    
    if (_location == nil||_location.horizontalAccuracy>newLocation.horizontalAccuracy) {
        _lastLocationError = nil;
        _location = newLocation;
        [self updateLabels];
        if (newLocation.horizontalAccuracy<=_locationManager.desiredAccuracy) {
            NSLog(@"目标定位完成");
            //[self updateLabels];
            [self stopLocationManager];
            [self configureGetButton];
        }
        if (distance >0) {
            _performingReverseGeocoding = NO;
        }
        if (!_performingReverseGeocoding) {
            NSLog(@"*** Going to geocode");
            _performingReverseGeocoding = YES;
            [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks,NSError *error){
                NSLog(@"found placemarks:%@,error:%@",placemarks,error);
                _lastGeocodingError = error;
                if (error == nil && [placemarks count]>0){
                    _placemark = [placemarks lastObject];
                }else{
                    _placemark = nil;
                }
                _performingReverseGeocoding = NO;
                [self updateLabels];
            }];
        }
    
    }else if (distance <1.0){
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:_location.timestamp];
        if (timeInterval >10) {
            NSLog(@"***强制完成");
            [self stopLocationManager];
            [self updateLabels];
            [self configureGetButton];
        }
    }

}

-(void)updateLabels{
    if(_location != nil){
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f",_location.coordinate.latitude];
        self.longtitudeLabel.text = [NSString stringWithFormat:@"%.8f",_location.coordinate.longitude];
        self.tagButton.hidden = NO;
        self.messageLabel.text = @"";
        if (_placemark !=nil) {
            self.adderessLabel.text = [self stringFromPlacemark:_placemark];
        }else if(_performingReverseGeocoding){
            self.adderessLabel.text = @"寻找中...";
        }else if(_lastGeocodingError!=nil){
            self.adderessLabel.text = @"出错了";
        }else{
            self.adderessLabel.text = @"啥都没找到";
        }
    }else{
        self.latitudeLabel.text = @"";
        self.longtitudeLabel.text = @"";
        self.adderessLabel.text = @"";
        self.tagButton.hidden = YES;
        self.messageLabel.text = @"请按按钮开始定位";
        
        NSString *statusMessage;
        if (_lastLocationError != nil) {
            if([_lastLocationError.domain isEqualToString:kCLErrorDomain]&& _lastLocationError.code == kCLErrorDenied){
                statusMessage = @"对不起，用户已关闭定位服务";
            }else{
                statusMessage = @"对不起，定位失败";
            }
        }else if(![CLLocationManager locationServicesEnabled]){
            statusMessage = @"对不起，用户已关闭定位服务";
        }else if(_updatingLocation){
            statusMessage = @"正在获取地址...";
        }else{
            statusMessage = @"请按按钮开始定位";
        }
        self.messageLabel.text = statusMessage;
    }
}

-(void)stopLocationManager{
    if(_updatingLocation){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _updatingLocation = NO;
    }
}

-(void)startLocaltionManager{
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [_locationManager startUpdatingLocation];
        _updatingLocation = YES;
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

-(void)configureGetButton{
    if(_updatingLocation){
        [self.getButton setTitle:@"停止定位" forState:UIControlStateNormal];
    }else{
        [self.getButton setTitle:@"获取当前位置" forState:UIControlStateNormal];
    }
}

-(NSString*)stringFromPlacemark:(CLPlacemark*)thePlacemark{
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@",thePlacemark.administrativeArea,thePlacemark.locality,thePlacemark.thoroughfare,thePlacemark.subThoroughfare,thePlacemark.postalCode];
}

-(void)didTimeOut:(id)obj{
    NSLog(@"*** oops，超时了");
    if (_location == nil) {
        [self stopLocationManager];
        _lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
        [self updateLabels];
        [self configureGetButton];
    }
}
@end
