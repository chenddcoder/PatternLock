//
//  SPLockOverlay.h
//  SuQian
//
//  Created by Suraj on 25/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPLine.h"

@interface SPLockOverlay : UIView

@property (nonatomic, strong) NSMutableArray *pointsToDraw;
- (id)initWithFrame:(CGRect)frame
      andNodeRadius:(CGFloat)nodeRadius
       andLineColor:(UIColor*)lineColor
   andLineGridColor:(UIColor*)lineGridColor;
@end
