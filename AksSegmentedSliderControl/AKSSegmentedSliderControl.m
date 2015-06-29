//
//  AKSSegmentedSliderControl.m
//  Betify
//
//  Created by Alok on 28/06/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "AKSSegmentedSliderControl.h"

@interface AKSSegmentedSliderControl () <UIGestureRecognizerDelegate>

@end

@implementation AKSSegmentedSliderControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        firstTimeOnly = TRUE;
        _spaceBetweenPoints = 40.0;
        _numberOfPoints = 5.0;
        _heightLine = 10.0;
        _radiusPoint = 10.0;
        _shadowSize = CGSizeMake(2.0, 2.0);
        _shadowBlur = 2.0;
        _strokeSize = 1.0;
        _strokeColor = [UIColor blackColor];
        _shadowColor = [UIColor colorWithWhite:0.0 alpha:0.30];
        _radiusCircle = 2.0;
        _moveFinalIndex = 0;
        _currentIndex = 0;
        _touchEnabled = YES;
        
        _strokeColorForeground = [UIColor colorWithWhite:0.3 alpha:1.0];
        _strokeSizeForeground = 1.0;
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        NSArray *gradientColors = [NSArray arrayWithObjects:
                                   (id)[UIColor whiteColor].CGColor,
                                   (id)[UIColor colorWithWhite : 0.793 alpha : 1.000].CGColor, nil];
        CGFloat gradientLocations[] = { 0, 1 };
        _gradientForeground = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
        
        _positionPoints = [NSMutableArray array];
        
        CGColorSpaceRelease(colorSpace);
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bgView.userInteractionEnabled = YES;
        [self addSubview:bgView];
        [self bringSubviewToFront:bgView];
        
        holderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        holderView.backgroundColor = [UIColor whiteColor];
        holderView.layer.cornerRadius = 5;
        [self addSubview:holderView];
        [self bringSubviewToFront:holderView];
        [holderView setUserInteractionEnabled:TRUE];
        [holderView setCenter:CGPointZero];
        
        self.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

#pragma mark -
#pragma mark Drawing

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.spaceBetweenPoints = (CGRectGetWidth(self.bounds)  - (_numberOfPoints * _radiusPoint * 2) - _radiusPoint) / (_numberOfPoints - 1);
    [self backgroundPath];
    [self moveToIndex:self.currentIndex];
}

- (void)drawRect:(CGRect)rect {
    _context = UIGraphicsGetCurrentContext();
    _drawPath = [self backgroundPath];
    
    [_strokeColor setStroke];
    
    CGContextSaveGState(_context);
    CGContextSetShadowWithColor(_context, _shadowSize, _shadowBlur, _shadowColor.CGColor);
    [_drawPath setLineWidth:_strokeSize];
    [_drawPath fill];
    [_drawPath stroke];
    [_drawPath addClip];
    
    
    CGRect drawingRect = [self bounds];
    
    CGPoint center;
    
    if (CGPointEqualToPoint([holderView center], CGPointZero)) {
        center = [[_positionPoints objectAtIndex:_currentIndex]CGPointValue];
    } else {
        center = [holderView center];
    }
    
    drawingRect  = CGRectMake(drawingRect.origin.x, drawingRect.origin.y, center.x, drawingRect.size.height);
    [self fillRect:drawingRect withColor:self.tintColor.CGColor onContext:_context];
    
    drawingRect  = CGRectMake(drawingRect.origin.x + center.x, drawingRect.origin.y, self.frame.size.width, drawingRect.size.height);
    [self fillRect:drawingRect withColor:self.disabledBackgroundColor.CGColor onContext:_context];
    
    CGContextRestoreGState(_context);
    
    if (firstTimeOnly) [holderView setCenter:[[_positionPoints objectAtIndex:_currentIndex]CGPointValue]];
    
    firstTimeOnly = FALSE;
}

- (void)fillRect:(CGRect)rect withColor:(CGColorRef)color onContext:(CGContextRef)currentGraphicsContext {
    CGContextAddRect(currentGraphicsContext, rect);
    CGContextSetFillColorWithColor(currentGraphicsContext, color);
    CGContextFillRect(currentGraphicsContext, rect);
}

- (UIBezierPath *)backgroundPath {
    [_positionPoints removeAllObjects];
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    float angle = _heightLine / 2.0 / _radiusPoint;
    
    for (int i = 0; i < (_numberOfPoints - 2) * 2 + 2; i++) {
        int pointNbr = (i >= _numberOfPoints) ? (_numberOfPoints - 2) - (i - _numberOfPoints) : i;
        
        CGPoint centerPoint = CGPointMake(_radiusPoint + _spaceBetweenPoints * pointNbr + _radiusPoint * 2.0 * pointNbr + _strokeSize, _radiusPoint + _strokeSize);
        
        if (i == 0) {
            [_positionPoints addObject:[NSValue valueWithCGPoint:centerPoint]];
            [path addArcWithCenter:centerPoint radius:_radiusPoint startAngle:angle endAngle:angle * -1.0 clockwise:YES];
            [path addLineToPoint:CGPointMake(centerPoint.x + _radiusPoint + _spaceBetweenPoints, centerPoint.y - _heightLine / 2.0)];
        } else if (i == _numberOfPoints - 1) {
            [_positionPoints addObject:[NSValue valueWithCGPoint:centerPoint]];
            [path addArcWithCenter:centerPoint radius:_radiusPoint startAngle:M_PI + angle endAngle:M_PI - angle clockwise:YES];
            [path addLineToPoint:CGPointMake(centerPoint.x - _radiusPoint - _spaceBetweenPoints - ((i == (_numberOfPoints - 2) * 2 + 1) ? (_radiusPoint * (1.0 - cosf(angle))) : 0), centerPoint.y + _heightLine / 2.0)];
        } else if (i < _numberOfPoints - 1) {
            [_positionPoints addObject:[NSValue valueWithCGPoint:centerPoint]];
            [path addArcWithCenter:centerPoint radius:_radiusPoint startAngle:M_PI + angle endAngle:angle * -1.0 clockwise:YES];
            [path addLineToPoint:CGPointMake(centerPoint.x + _radiusPoint + _spaceBetweenPoints, centerPoint.y - _heightLine / 2.0)];
        } else if (i >= _numberOfPoints) {
            [_positionPoints addObject:[NSValue valueWithCGPoint:centerPoint]];
            [path addArcWithCenter:centerPoint radius:_radiusPoint startAngle:angle endAngle:M_PI - angle clockwise:YES];
            [path addLineToPoint:CGPointMake(centerPoint.x - _radiusPoint - _spaceBetweenPoints - ((i == (_numberOfPoints - 2) * 2 + 1) ? (_radiusPoint * (1.0 - cosf(angle))) : 0), centerPoint.y + _heightLine / 2.0)];
        }
    }
    
    return path;
}

#pragma mark -
#pragma mark User touch

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureRecognizer.view.superview];
        return fabs(translation.x) > fabs(translation.y);
    }
    return YES;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    if (_touchEnabled) {
        CGPoint touchPoint = [gesture locationInView:self];
        
        float x = touchPoint.x;
        x -= _strokeSize;
        
        for (int i = 0; i < [_positionPoints count]; i++) {
            CGPoint point = [[_positionPoints objectAtIndex:i] CGPointValue];
            
            double diggerence  = fabs(point.x - x);
            
            if (diggerence <= _radiusPoint * 3) {
                if ([_delegate respondsToSelector:@selector(timeSlider:didSelectPointAtIndex:)]) {
                    [_delegate timeSlider:self didSelectPointAtIndex:i];
                }
                
                [self moveToIndex:i];
                return;
            }
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recogniser {
    if (_touchEnabled) {
        CGPoint location = [recogniser locationInView:self];
        location.y = holderView.center.y;
        
        CGPoint leftMargin = [self getMostLeftPossibleLocation];
        CGPoint rightMargin = [self getMostRightPossibleLocation];
        
        if ((location.x >= leftMargin.x) && (location.x <= rightMargin.x)) {
            [holderView setCenter:location];
        }
        else if(location.x <= leftMargin.x){
            [holderView setCenter:leftMargin];
        }
        else if(location.x >= rightMargin.x){
            [holderView setCenter:rightMargin];
        }
        
        if ([recogniser state] == UIGestureRecognizerStateEnded) {
            [self updatePositions];
        }
    }
    [self setNeedsDisplay];
}

- (void)updatePositions {
    CGPoint nearestLeft  = [self getNearestLeftPossibleLocation];
    CGPoint nearestRight = [self getNearestRightPossibleLocation];
    
    if ((holderView.center.x - nearestLeft.x) < (nearestRight.x - holderView.center.x))
        [holderView setCenter:nearestLeft];
    else
        [holderView setCenter:nearestRight];
    
    
    float x = holderView.center.x;
    x -= _strokeSize;
    
    for (int i = 0; i < [_positionPoints count]; i++) {
        CGPoint point = [[_positionPoints objectAtIndex:i] CGPointValue];
        
        if (fabs(point.x - x) <= _radiusPoint) {
            if ([_delegate respondsToSelector:@selector(timeSlider:didSelectPointAtIndex:)]) {
                [_delegate timeSlider:self didSelectPointAtIndex:i];
            }
            
            [self moveToIndex:i];
            return;
        }
    }
}

- (CGPoint)getNearestLeftPossibleLocation {
    CGPoint location = CGPointZero;
    int difference = 10240;
    for (int i = 0; i < [_positionPoints count]; i++) {
        CGPoint point = [[_positionPoints objectAtIndex:i] CGPointValue];
        if (holderView.center.x >= point.x) {
            if (CGPointEqualToPoint(location, CGPointZero)) {
                location = point;
            }
            
            if (difference > (holderView.center.x - point.x)) {
                difference = holderView.center.x - point.x;
                location = point;
            }
        }
    }
    return location;
}

- (CGPoint)getNearestRightPossibleLocation {
    CGPoint location = CGPointZero;
    int difference = 10240;
    for (int i = 0; i < [_positionPoints count]; i++) {
        CGPoint point = [[_positionPoints objectAtIndex:i] CGPointValue];
        if (holderView.center.x <= point.x) {
            if (CGPointEqualToPoint(location, CGPointZero)) {
                location = point;
            }
            
            if (difference > (point.x - holderView.center.x)) {
                difference = point.x - holderView.center.x;
                location = point;
            }
        }
    }
    return location;
}

- (CGPoint)getMostLeftPossibleLocation {
    static CGPoint mostLeftFound;
    if (CGPointEqualToPoint(mostLeftFound, CGPointZero)) {
        for (int i = 0; i < [_positionPoints count]; i++) {
            CGPoint point = [[_positionPoints objectAtIndex:i] CGPointValue];
            if (CGPointEqualToPoint(mostLeftFound, CGPointZero)) {
                mostLeftFound = point;
            } else if (point.x < mostLeftFound.x) {
                mostLeftFound = point;
            }
        }
    }
    return mostLeftFound;
}

- (CGPoint)getMostRightPossibleLocation {
    static CGPoint mostRightFound;
    
    if (CGPointEqualToPoint(mostRightFound, CGPointZero)) {
        for (int i = 0; i < [_positionPoints count]; i++) {
            CGPoint point = [[_positionPoints objectAtIndex:i] CGPointValue];
            if (CGPointEqualToPoint(mostRightFound, CGPointZero)) {
                mostRightFound = point;
            } else if (point.x > mostRightFound.x) {
                mostRightFound = point;
            }
        }
    }
    return mostRightFound;
}

#pragma mark -
#pragma mark Move the index

- (void)moveToIndex:(int)index {
    _moveFinalIndex = index;
    _currentIndex = index;
    
    if ([_positionPoints count] > index) [holderView setCenter:[[_positionPoints objectAtIndex:_currentIndex]CGPointValue]];
    
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Getters

- (CGPoint)positionForPointAtIndex:(int)index {
    return [[_positionPoints objectAtIndex:index] CGPointValue];
}

#pragma mark -
#pragma mark Setters

- (void)setGradientForeground:(CGGradientRef)gradientForeground {
    _gradientForeground = gradientForeground;
    [self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self setNeedsDisplay];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    [self setNeedsDisplay];
}

- (void)setShadowSize:(CGSize)shadowSize {
    _shadowSize = shadowSize;
    [self setNeedsDisplay];
}

- (void)setShadowBlur:(float)shadowBlur {
    _shadowBlur = shadowBlur;
    [self setNeedsDisplay];
}

- (void)setStrokeSize:(float)strokeSize {
    _strokeSize = strokeSize;
    [self setNeedsDisplay];
}

- (void)setStrokeSizeForeground:(float)strokeSizeForeground {
    _strokeSizeForeground = strokeSizeForeground;
    [self setNeedsDisplay];
}

- (void)setRadiusPoint:(float)radiusPoint {
    _radiusPoint = radiusPoint;
    [self setNeedsDisplay];
}

- (void)setNumberOfPoints:(float)numberOfPoints {
    float minNumberOfPoints = (_currentIndex + 1) > 2 ? (_currentIndex + 1) : 2;
    
    if (numberOfPoints < minNumberOfPoints) {
        _numberOfPoints = minNumberOfPoints;
    } else {
        _numberOfPoints = (int)numberOfPoints;
    }
    
    [self setNeedsDisplay];
}

- (void)setHeightLine:(float)heightLine {
    if (heightLine > _radiusPoint * 2) {
        heightLine = _radiusPoint * 2;
    }
    
    _heightLine = heightLine;
    [self setNeedsDisplay];
}

- (void)setRadiusCircle:(float)radiusCircle {
    _radiusCircle = radiusCircle;
    [self setNeedsDisplay];
}

- (void)setSpaceBetweenPoints:(float)spaceBetweenPoints {
    _spaceBetweenPoints = spaceBetweenPoints;
    [self setNeedsDisplay];
}

@end
