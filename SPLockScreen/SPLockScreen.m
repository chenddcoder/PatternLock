//
//  SPLockScreen.m
//  SuQian
//
//  Created by Suraj on 24/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import "SPLockScreen.h"
#import "NormalCircle.h"
#import "SPLockOverlay.h"

#define kSeed									23
#define kAlterOne							1234
#define kAlterTwo							4321
#define kTagIdentifier				22222

#define kOuterColor			[UIColor colorWithRed:128.0/255.0 green:127.0/255.0 blue:123.0/255.0 alpha:0.9]
#define kInnerColor			[UIColor colorWithRed:43.0/255.0 green:43.0/255.0 blue:43.0/255.0 alpha:0.75]
#define kHighlightColor	[UIColor colorWithRed:255.0/255.0 green:252.0/255.0 blue:78.0/255.0 alpha:0.9]
#define kLineColor			[UIColor colorWithRed:255.0/255.0 green:252.0/255.0 blue:78.0/255.0 alpha:0.9]
#define kLineGridColor  [UIColor colorWithRed:255.0/255.0 green:252.0/255.0 blue:233.0/255.0 alpha:1.0]
#define kOuterRadius 30.0f
#define kNodeRadius 14.0f
@interface SPLockScreen()
@property (nonatomic, strong) NormalCircle *selectedCell;
@property (nonatomic, strong) SPLockOverlay *overLay;
@property (nonatomic) NSInteger oldCellIndex,currentCellIndex;
@property (nonatomic, strong) NSMutableDictionary *drawnLines;
@property (nonatomic, strong) NSMutableArray *finalLines, *cellsInOrder;

@property (nonatomic, strong) UIColor * outerColor;//圈外Color
@property (nonatomic, strong) UIColor * innerColor;//圈内Color
@property (nonatomic, strong) UIColor * highlightColor;//高亮Color
@property (nonatomic, strong) UIColor * lineColor;//连线Color
@property (nonatomic, strong) UIColor * lineGridColor;//连线交点Color
@property (nonatomic, assign) CGFloat outerRadius;//外圈大小
@property (nonatomic, assign) CGFloat nodeRadius;//选中点大小
- (void)resetScreen;

@end

@implementation SPLockScreen
@synthesize delegate,selectedCell,overLay,oldCellIndex,currentCellIndex,drawnLines,finalLines,cellsInOrder,allowClosedPattern;

- (id)init{
    _outerRadius=kOuterRadius;
    _outerColor=kOuterColor;
    _innerColor=kInnerColor;
    _highlightColor=kHighlightColor;
    _lineColor=kLineColor;
    _lineGridColor=kLineGridColor;
	CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
	self = [super initWithFrame:frame];
	if (self) {
		[self setNeedsDisplay];
		[self setUpTheScreen];
		[self addGestureRecognizer];
	}
	return self;
}

- (id)initWithDelegate:(id<LockScreenDelegate>)lockDelegate
{
	self = [self init];
	self.delegate = lockDelegate;
	
	return self;
}
- (id)initWithFrame:(CGRect)frame{
    _nodeRadius=kNodeRadius;
    _outerRadius=kOuterRadius;
    _outerColor=kOuterColor;
    _innerColor=kInnerColor;
    _highlightColor=kHighlightColor;
    _lineColor=kLineColor;
    _lineGridColor=kLineGridColor;
    frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsDisplay];
        [self setUpTheScreen];
        [self addGestureRecognizer];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
      andNodeRadius:(CGFloat)nodeRadius
     andOuterRadius:(CGFloat)outerRadius
        andOutColor:(UIColor*)outerColor
      andInnerColor:(UIColor*)innerColor
  andHighlightColor:(UIColor*)highlightColor
       andLineColor:(UIColor*)lineColor
   andLineGridColor:(UIColor*)lineGridColor
{
    _nodeRadius=nodeRadius;
    _outerRadius=outerRadius;
    _outerColor=outerColor;
    _innerColor=innerColor;
    _highlightColor=highlightColor;
    _lineColor=lineColor;
    _lineGridColor=lineGridColor;
	frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    self = [super initWithFrame:frame];
    if (self) {
			[self setNeedsDisplay];
			[self setUpTheScreen];
			[self addGestureRecognizer];
    }
    return self;
}

- (void)setUpTheScreen{
    
	CGFloat gap = (self.frame.size.width - 6 * _outerRadius )/4;
	CGFloat topOffset = _outerRadius;
	
	for (int i=0; i < 9; i++) {
		NormalCircle *circle = [[NormalCircle alloc]initwithRadius:_outerRadius andOutColor:_outerColor andInnerColor:_innerColor andHighlightColor:_highlightColor];
		int column =  i % 3;
		int row    = i / 3;
		CGFloat x = (gap + _outerRadius) + (gap + 2*_outerRadius)*column;
		CGFloat y = (row * gap + row * 2 * _outerRadius) + topOffset;
		circle.center = CGPointMake(x, y);
		circle.tag = (row+kSeed)*kTagIdentifier + (column + kSeed);
		[self addSubview:circle];
	}
	self.drawnLines = [[NSMutableDictionary alloc]init];
	self.finalLines = [[NSMutableArray alloc]init];
	self.cellsInOrder = [[NSMutableArray alloc]init];
	// Add an overlay view
	self.overLay = [[SPLockOverlay alloc]initWithFrame:self.frame
                    andNodeRadius:_nodeRadius
                                          andLineColor:_lineColor
                                      andLineGridColor:_lineGridColor];
	[self.overLay setUserInteractionEnabled:NO];
	[self addSubview:self.overLay];
	// set selected cell indexes to be invalid
	self.currentCellIndex = -1;
	self.oldCellIndex = self.currentCellIndex;
}

#pragma - helper methods

- (NSInteger )indexForPoint:(CGPoint)point
{
	for(UIView *view in self.subviews)
	{
		if([view isKindOfClass:[NormalCircle class]])
		{
			if(CGRectContainsPoint(view.frame, point)){
				NormalCircle *cell = (NormalCircle *)view;
				
				if(cell.selected == NO)	{
					[cell highlightCell];
					self.currentCellIndex = [self indexForCell:cell];
					self.selectedCell = cell;
				}
				
				else if (cell.selected == YES && self.allowClosedPattern == YES) {
					self.currentCellIndex = [self indexForCell:cell];
					self.selectedCell = cell;
				}
				
				int row = view.tag/kTagIdentifier - kSeed;
				int column = view.tag % kTagIdentifier - kSeed;
				return row * 3 + column;
			}
		}
	}
	return -1;
}

- (NSInteger) indexForCell:(NormalCircle *)cell
{
	if([cell isKindOfClass:[NormalCircle class]] == NO || [cell.superview isEqual:self] == NO) return -1;
	else
		return (cell.tag/kTagIdentifier - kSeed)*3 + (cell.tag % kTagIdentifier - kSeed);
}

- (NormalCircle *)cellAtIndex:(NSInteger)index
{
	if(index<0 || index > 8) return nil;
	return (NormalCircle *)[self viewWithTag:((index/3+kSeed)*kTagIdentifier + index % 3 + kSeed)];
}

- (NSNumber *) uniqueLineIdForLineJoiningPoint:(NSInteger)A AndPoint:(NSInteger)B
{
	return @(abs(A+B)*kAlterOne + abs(A-B)*kAlterTwo);
}

- (void)handlePanAtPoint:(CGPoint)point
{
	self.oldCellIndex = self.currentCellIndex;
	NSInteger cellPos = [self indexForPoint:point];
	
    if(cellPos >=0 && cellPos != self.oldCellIndex){
        //修复重复添加的bug 2016.2.26
        if (![self.cellsInOrder containsObject:@(self.currentCellIndex)]) {
            [self.cellsInOrder addObject:@(self.currentCellIndex)];
        }
    }
		
	
	if(cellPos < 0 && self.oldCellIndex < 0) return;
	
	else if(cellPos < 0) {
		SPLine *aLine = [[SPLine alloc]initWithFromPoint:[self cellAtIndex:self.oldCellIndex].center toPoint:point AndIsFullLength:NO];
		[self.overLay.pointsToDraw removeAllObjects];
		[self.overLay.pointsToDraw addObjectsFromArray:self.finalLines];
		[self.overLay.pointsToDraw addObject:aLine];
		[self.overLay setNeedsDisplay];
	}
	else if(cellPos >=0 && self.currentCellIndex == self.oldCellIndex) return;
	else if (cellPos >=0 && self.oldCellIndex == -1) return;
	else if(cellPos >= 0 && self.oldCellIndex != self.currentCellIndex)
	{
		// two situations: line already drawn, or not fully drawn yet
		NSNumber *uniqueId = [self uniqueLineIdForLineJoiningPoint:self.oldCellIndex AndPoint:self.currentCellIndex];
		
		if(![self.drawnLines objectForKey:uniqueId])
		{
			SPLine *aLine = [[SPLine alloc]initWithFromPoint:[self cellAtIndex:self.oldCellIndex].center toPoint:self.selectedCell.center AndIsFullLength:YES];
			[self.finalLines addObject:aLine];
			[self.overLay.pointsToDraw removeAllObjects];
			[self.overLay.pointsToDraw addObjectsFromArray:self.finalLines];
			[self.overLay setNeedsDisplay];
			[self.drawnLines setObject:@(YES) forKey:uniqueId];
		}
		else return;
	}
}

- (void)endPattern
{
	NSLog(@"PATTERN: %@",[self patternToUniqueId]);
	if ([self.delegate respondsToSelector:@selector(lockScreen:didEndWithPattern:)])
		[self.delegate lockScreen:self didEndWithPattern:[self patternToUniqueId]];
	
	[self resetScreen];
}

- (NSString *)patternToUniqueId
{
//	long finalNumber = 0;
//	long thisNum;
    NSMutableString * uniqueId=[[NSMutableString alloc]init];
//    NSLog(@"cellsInOrder=%d",self.cellsInOrder.count);
//    for (int i=0; i<self.cellsInOrder.count; i++) {
//        NSLog(@"%d",[[self.cellsInOrder objectAtIndex:i] integerValue] );
//    }
	for(int i = 0 ; i <self.cellsInOrder.count ; i++){
        //配合android版本改造为0～8 2016.2.26
//		thisNum = ([[self.cellsInOrder objectAtIndex:i] integerValue]) * pow(10, (self.cellsInOrder.count - i - 1));
//		finalNumber = finalNumber + thisNum;
//        NSLog(@"finalNumber=%d finalNumber=%d thisNum=%d",finalNumber,finalNumber,thisNum);
        [uniqueId appendString:[NSString stringWithFormat:@"%ld",(long)[[self.cellsInOrder objectAtIndex:i] integerValue]]];
	}
	return uniqueId;
}

- (void)resetScreen
{
	for(UIView *view in self.subviews)
	{
		if([view isKindOfClass:[NormalCircle class]])
			[(NormalCircle *)view resetCell];
	}
	[self.finalLines removeAllObjects];
	[self.drawnLines removeAllObjects];
	[self.cellsInOrder removeAllObjects];
	[self.overLay.pointsToDraw removeAllObjects];
	[self.overLay setNeedsDisplay];
	self.oldCellIndex = -1;
	self.currentCellIndex = -1;
	self.selectedCell = nil;
}


#pragma - Gesture Handler

- (void)addGestureRecognizer
{
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestured:)];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestured:)];
	[self addGestureRecognizer:pan];
	[self addGestureRecognizer:tap];
}

- (void)gestured:(UIGestureRecognizer *)gesture
{
	CGPoint point = [gesture locationInView:self];
	if([gesture isKindOfClass:[UIPanGestureRecognizer class]]){
		if(gesture.state == UIGestureRecognizerStateEnded ) {
			if(self.finalLines.count > 0)[self endPattern];
			else [self resetScreen];
		}
		else [self handlePanAtPoint:point];
	}
	else {
		NSInteger cellPos = [self indexForPoint:point];
		self.oldCellIndex = self.currentCellIndex;
		if(cellPos >=0) {
			[self.cellsInOrder addObject:@(self.currentCellIndex)];
			[self performSelector:@selector(endPattern) withObject:nil afterDelay:0.3];
		}
	}
}
@end
