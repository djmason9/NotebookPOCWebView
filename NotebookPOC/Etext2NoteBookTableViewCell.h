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

#define ETEXT_NOTEBOOK_CHILDREN @"children"
#define ETEXT_NOTEBOOK_PAGE_NUMBER @"pageNumber"
#define ETEXT_NOTEBOOK_NOTES @"notes"
#define ETEXT_NOTEBOOK_PAGE_TITLE @"pageTitle"
#define ETEXT_NOTEBOOK_UNIT_TITLE @"unitTitle"
#define ETEXT_NOTEBOOK_PAGE_URL @"pageUrl"
#define ETEXT_NOTEBOOK_PAGE_CAP_URL @"pageURL"
#define ETEXT_NOTEBOOK_USER_ID @"userId"
#define ETEXT_NOTEBOOK_BOOK_CONTEXT @"bookContext"
#define ETEXT_NOTEBOOK_BOOK_ID @"bookId"
#define ETEXT_NOTEBOOK_PAGE_ID @"pageId"
#define ETEXT_NOTEBOOK_PROMPTS @"prompts"
#define ETEXT_NOTEBOOK_PROMPT_ID @"id"
#define ETEXT_NOTEBOOK_PARENT_ID @"parentId"
#define ETEXT_NOTEBOOK_QUESTION @"question"
#define ETEXT_NOTEBOOK_CONTENT @"content"
#define ETEXT_NOTEBOOK_NOTE_ID @"objectId"
#define ETEXT_NOTEBOOK_TRIGGERED_NOTE @"triggeredPromptIndex"


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
