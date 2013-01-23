//
//  CrzInputView.h
//  crzinput_ios
//
//  Created by huanjiang on 13-1-23.
//  Copyright (c) 2013年 huanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CrzInputViewDelegate.h"

@interface CrzInputView : UIView
{
    UIButton                    *_buttonPanel;
    UIButton                    *_matchButton;
    
    NSMutableArray              *_pointSequence;
    __unsafe_unretained id      _delegate;
}

@property(nonatomic, unsafe_unretained) id<CrzInputViewDelegate> delegate;

@end
