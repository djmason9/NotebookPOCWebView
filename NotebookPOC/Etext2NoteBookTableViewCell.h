//
//  Etext2NoteBookTableViewCell.h
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/23/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Etext2CustomEditUIButton.h"
#import "Etext2CustomUIWebView.h"
//delete all these fonts
#define APPLICATION_STANDARD_FONT @"Avenir-Roman"
#define APPLICATION_BOLD_FONT @"Avenir-Heavy"
#define APPLICATION_STANDARD_ITALIC_FONT @"Avenir-Oblique"
#define APPLICATION_BOLD_ITALIC_FONT @"Avenir-HeavyOblique"
#define DISABLED_COLOR [UIColor colorWithRed:0.686 green:0.686 blue:0.686 alpha:1]
#define ENABLED_COLOR [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0]


#define TOTAL_WORD_COUNT 1000


@protocol Etext2NoteBookCellDelegate <NSObject>

@required
- (void)doDoneEditing:(UITableViewCell *)cell;

@end

@interface Etext2NoteBookTableViewCell : UITableViewCell<UIWebViewDelegate>

    //public properties
    @property(nonatomic,weak) id <Etext2NoteBookCellDelegate> cellDelegate;
    @property(nonatomic,weak) NSString *selectedText;
    @property(nonatomic,weak) NSString *noteId;


    //public methods
    -(void)buttonAction:(Etext2CustomEditUIButton*)button;

@end
