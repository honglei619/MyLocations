//
//  HudView.h
//  MyLocations
//
//  Created by Lei on 15/5/27.
//  Copyright (c) 2015年 honglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

+(instancetype)hudInView:(UIView*) view animated:(BOOL)animated;
@property(nonatomic,strong)NSString *text;


@end
