//
//  SPLockOverlay.m
//  SuQian
//
//  Created by Suraj on 25/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import "SPLockOverlay.h"

@interface SPLockOverlay()
@property (nonatomic, assign) CGFloat nodeRadius;
@property (nonatomic, strong) UIColor * lineColor;
@property (nonatomic, strong) UIColor * lineGridColor;
@end
@implementation SPLockOverlay

@synthesize pointsToDraw;

- (id)initWithFrame:(CGRect)frame
      andNodeRadius:(CGFloat)nodeRadius
       andLineColor:(UIColor*)lineColor
   andLineGridColor:(UIColor*)lineGridColor
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
			self.backgroundColor = [UIColor clearColor];
			self.pointsToDraw = [[NSMutableArray alloc]init];
        _nodeRadius=nodeRadius;
        _lineColor=lineColor;
        _lineGridColor=lineGridColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat lineWidth = 5.0;
	
	CGContextSetLineWidth(context, lineWidth);
	CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    for(SPLine *line in self.pointsToDraw)
		{			
			CGContextMoveToPoint(context, line.fromPoint.x, line.fromPoint.y);
			CGContextAddLineToPoint(context, line.toPoint.x, line.toPoint.y);
			CGContextStrokePath(context);
			
			CGFloat nodeRadius = _nodeRadius;
			
			CGRect fromBubbleFrame = CGRectMake(line.fromPoint.x- nodeRadius/2, line.fromPoint.y - nodeRadius/2, nodeRadius, nodeRadius);
			CGContextSetFillColorWithColor(context, _lineGridColor.CGColor);
			CGContextFillEllipseInRect(context, fromBubbleFrame);
			
			if(line.isFullLength){
			CGRect toBubbleFrame = CGRectMake(line.toPoint.x - nodeRadius/2, line.toPoint.y - nodeRadius/2, nodeRadius, nodeRadius);
			CGContextFillEllipseInRect(context, toBubbleFrame);
			}
		}
}
@end
