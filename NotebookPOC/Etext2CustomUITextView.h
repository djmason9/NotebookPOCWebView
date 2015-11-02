//
//  Etext2CustomUITextView.h
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/27/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Etext2CustomUITextView : UITextView

    @property (nonatomic,assign) NSRange lastSelectedRange;

    -(void)resetSelectedRange;
    - (void)applyAttributeToTypingAttribute:(id)attribute forKey:(NSString *)key;

@end
