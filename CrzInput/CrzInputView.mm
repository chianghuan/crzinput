//
//  CrzInputView.m
//  crzinput_ios
//
//  Created by huanjiang on 13-1-23.
//  Copyright (c) 2013年 huanjiang. All rights reserved.
//

#import "CrzInputView.h"

#include <cstdio>

#import "DDFileReader.h"

#define KeyboardHSpacing         6
#define KeyboardVSpacing        12
#define KeyHeight               40
#define KeyWidth                26

#define buttonPanelTag           1
#define buttonOkTag              2

#define EqualThresh          0.001

NSString *keyboardChar = @"qwertyuiopasdfghjklzxcvbnm";
const int const lineCharCnt[3] = {10, 9, 7};

@implementation CrzInputView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pointSequence = [[NSMutableArray alloc] initWithCapacity:25];
        _delegate = nil;
        
        self.backgroundColor = [UIColor whiteColor];
        
        _buttonPanel = [[UIButton alloc] initWithFrame:self.bounds];
        _buttonPanel.tag = buttonPanelTag;
        [_buttonPanel addTarget:self action:@selector(touchesBegan:withEvent:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_buttonPanel];
        
        const CGFloat boundWidth = self.bounds.size.width;
        const CGFloat boundHeight = self.bounds.size.height;
        
        int charIndex = 0;
        CGFloat buttonY = (boundHeight - (4 * KeyHeight + 3 * KeyboardVSpacing)) / 2;
        
        for (int i = 0; i < 3; i++) {
            const int cnt = lineCharCnt[i];
            CGFloat buttonX = (boundWidth - (cnt * KeyWidth + (cnt - 1) * KeyboardHSpacing)) / 2;
            
            for (int j = 0; j < cnt; j++) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button.frame = CGRectMake(buttonX, buttonY, KeyWidth, KeyHeight);
                
                [button setTitle:[keyboardChar substringWithRange:NSMakeRange(charIndex, 1)] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
                
                [button addTarget:self action:@selector(touchesBegan:withEvent:) forControlEvents:UIControlEventTouchDown];
                
                button.tag = [keyboardChar characterAtIndex:charIndex];
                [_buttonPanel addSubview:button];
                
                buttonX += (KeyWidth + KeyboardHSpacing);
                charIndex++;
            }
            
            buttonY += (KeyHeight + KeyboardVSpacing);
        }
        
        _matchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _matchButton.frame = CGRectMake(10, buttonY, boundWidth - 20, KeyHeight);
        [_matchButton setTitle:@"matching..." forState:UIControlStateDisabled];
        [_matchButton addTarget:self action:@selector(matchButtonTouchesBegan:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_buttonPanel addSubview:_matchButton];
        
        //        [self outputKeyCords];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:_buttonPanel];
    
    [_pointSequence addObject:[NSValue valueWithCGPoint:touchPoint]];
}

- (void)matchButtonTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _matchButton.enabled = NO;
    [_matchButton setNeedsDisplay];
    
    __unsafe_unretained CrzInputView *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^ {
                       NSArray *resultWords = [weakSelf matchWordsByTouches:_pointSequence];
                       if (nil != weakSelf.delegate) {
                           [weakSelf.delegate likelyWordsFound:resultWords];
                       }
                       
                       [weakSelf performSelectorOnMainThread:@selector(updateMatchButtonWithResultWords:) withObject:resultWords waitUntilDone:NO];
                   });
}

- (void)updateMatchButtonWithResultWords:(NSArray *)resultWords
{
    [_matchButton setTitle:[resultWords objectAtIndex:0] forState:UIControlStateNormal];
    _matchButton.enabled = YES;
    [_matchButton setNeedsDisplay];
    
    [_pointSequence removeAllObjects];
}

- (NSArray *)matchWordsByTouches:(NSMutableArray *)touches
{
    int tcnt = touches.count;
    if (tcnt < 2) {
        return nil;
    } else if (tcnt > 24) {
        return nil;
    }
    
    NSLog(@"begin match");
    
    int cnt = (tcnt - 1) * 2;
    CGPoint *userTouches = new CGPoint[tcnt];
    
    double *wordVector = new double[cnt];
    double *usrVector = new double[cnt];
    
    for (int i = 0; i < tcnt; i++) {
        userTouches[i] = [[touches objectAtIndex:i] CGPointValue];
    }
    
    double absU = 0.0;
    for (int i = 1; i < tcnt; i++) {
        usrVector[(i - 1) * 2] = userTouches[i].x - userTouches[i - 1].x;
        usrVector[(i - 1) * 2 + 1] = userTouches[i].y - userTouches[i - 1].y;
        absU += usrVector[(i - 1) * 2] * usrVector[(i - 1) * 2];
        absU += usrVector[(i - 1) * 2 + 1] * usrVector[(i - 1) * 2 + 1];
        
        printf("%f, %f, ", usrVector[(i - 1) * 2], usrVector[(i - 1) * 2 + 1]);
    }
    printf("\n");
    absU = sqrt(absU);
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *veclen = [[mainBundle bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"veclen%d", tcnt]];
    
    DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:veclen];
    NSString *line = nil;
    
    double maxLikely = -1.0;
    double lengthDiff = 100000000;
    NSString *resultWord = nil;
    
    while (nil != (line = [reader readLine])) {
        NSArray *words = [line componentsSeparatedByString:@" "];
        NSString *word = [words objectAtIndex:0];
        
        for (int i = 1; i <= cnt; i++) {
            double p = [[words objectAtIndex:i] floatValue];
            wordVector[i - 1] = p;
        }
        
        double absW = 0.0;
        double xproduct = 0.0;
        for (int i = 0; i < cnt; i++) {
            absW += wordVector[i] * wordVector[i];
            xproduct += usrVector[i] * wordVector[i];
        }
        absW = sqrt(absW);
        
        double std = xproduct / (absU * absW);
        
        if (std - EqualThresh > maxLikely) {
            resultWord = word;
            maxLikely = std;
            lengthDiff = fabs(absW - absU);
        } else if (fabs(std - maxLikely) < EqualThresh) {
            if (fabs(absU - absW) < lengthDiff) {
                resultWord = word;
                maxLikely = std;
                lengthDiff = fabs(absU - absW);
            }
        }
    }
    
    NSLog(@"max likelyhood : %lf", maxLikely);
    NSLog(@"found most likely : %@", resultWord);
    
    delete[] userTouches;
    delete[] usrVector;
    delete[] wordVector;
    
    return [NSArray arrayWithObject:resultWord];
}

- (void)outputKeyCords
{
    NSArray *subs = [_buttonPanel subviews];
    for (UIView *view in subs) {
        NSLog(@"%c %f %f", view.tag, view.center.x, view.center.y);
    }
}

@end
