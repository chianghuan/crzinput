//
//  CrzInputViewDelegate.h
//  crzinput_ios
//
//  Created by huanjiang on 13-1-23.
//  Copyright (c) 2013年 huanjiang. All rights reserved.
//

#ifndef crzinput_ios_CrzInputViewDelegate_h
#define crzinput_ios_CrzInputViewDelegate_h

@protocol CrzInputViewDelegate <NSObject>

@required
- (void)likelyWordsFound:(NSArray *)array;

@end


#endif
