//
//  Etext2NotesViewController.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/21/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2NoteBookViewController.h"
#import "Etext2WebClient.h"
#import "AFNetworking.h"
#import "Etext2Utility.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "Etext2CustomUITextView.h"
#import "Etext2CustomEditUIButton.h"

//all these can be deleted
#define SERVER_DEVLOPMENT @"DEVELOPMENT"
#define SERVER_STAGE @"PPE"
#define SERVER_PROD @"PRODUCTION"
#define HIGHLIGHT_COLOR [UIColor colorWithRed:59.0/255.0 green:163.0/255.0 blue:255.0/255.0 alpha:1]

#define EDIT_OPEN @"isOpen"

@interface Etext2NoteBookViewController (){

    NSString *_noteBookAPI;
    BOOL _keyboardIsShown;
    
    NSString *_bookId;
    NSString *_pageId;
    NSString *_userId;
}
@property (weak, nonatomic) UITextView *currentInputTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (nonatomic, strong) NSDateFormatter *mdyDateFormatter;


@end

@implementation Etext2NoteBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.mdyDateFormatter = [[NSDateFormatter alloc] init];
    [self.mdyDateFormatter setDateStyle:NSDateFormatterShortStyle];
    
//    _tableView.rowHeight = UITableViewAutomaticDimension;
//    _tableView.estimatedRowHeight = 100;
    
    _tableView.hidden = YES;
    //set up a user book and page needs to be dynamic
    _bookId =@"786856f8-be28-4083-9099-6c6eda8a29eb";
    _pageId = @"4fddc2fc-4b80-44fa-a6c3-5ac61a69556e";//@"60d9f594-7fcf-4d4a-a7d9-0ebc31ec2b3b";//
    _userId = @"demoUser";
    
    
    NSDictionary *endPointDictionary = [Etext2WebClient dictionaryFromPlist:@"EndPoints"];
    NSDictionary *serverList = [NSDictionary dictionaryWithObjectsAndKeys:
                                [endPointDictionary objectForKey:SERVER_DEVLOPMENT],
                                SERVER_DEVLOPMENT,[endPointDictionary objectForKey:SERVER_STAGE],
                                SERVER_STAGE,[endPointDictionary objectForKey:SERVER_PROD],
                                SERVER_PROD , nil];

    
    _noteBookAPI = serverList[SERVER_DEVLOPMENT][@"notebook"];
    
    [self getNotebookList];
    
    
}

-(void)getNotebookList{
    NSString *noteBookList = [Etext2WebClient getEndpointURLForKey:@"get_notebook_list"];
    NSString *apiURL = [_noteBookAPI stringByAppendingString:[NSString stringWithFormat:noteBookList,_bookId,_pageId,_userId]];
    
//    NSLog(@"%@",apiURL);
    
    [self callService:apiURL];

    
}

-(void)callService:(NSString*)apiURL{

    AFHTTPRequestOperationManager *client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:apiURL]];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL]];
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation * req = [client HTTPRequestOperationWithRequest:request
                                                                   success:^(AFHTTPRequestOperation *operation, id responseObject)
                                    {
                                        _tableView.hidden = NO;
                                        NSArray *noteArray = responseObject[@"data"];
                                        
//                                        NSLog(@"Success! %@",noteArray);
                                        
                                        //sort by date
                                        NSSortDescriptor *sortType = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
                                        NSArray *sortDescriptors = [NSArray arrayWithObject:sortType];
                                        noteArray = [[noteArray sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
                                        
                                        self.dataSource = [noteArray mutableCopy];
                                        [self.tableView reloadData];
                                        
                                        [_spinner stopAnimating];
                                    
                                    }
                                                                   failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                    {
                                        NSLog(@"Fail! %@",error);
                                    }];
    
    [req start];
}

-(NSDate*)formateDate:(NSString*)dateString{
    
    NSRange tRange = [dateString rangeOfString:@"T"];
    NSString *subDate = [dateString substringToIndex:tRange.location];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:subDate ];
    
    return date;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


#pragma UITableViewDelegate

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (tableView.frame.size.width-30), 42.0)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0, (tableView.frame.size.width - 30.0), 42)];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:APPLICATION_BOLD_FONT size:16]];
    
    //sort the map keys then grabs the key based on section
    NSString *string = @"TOC Page Name";
    
    [label setText:string];
    [view addSubview:label];
    
    [view setBackgroundColor:HIGHLIGHT_COLOR];
    
    
    label.isAccessibilityElement = YES;
    label.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"Section", nil), string];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.dataSource) {
        return 0;
    }
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Etext2NoteBookTableViewCell *cell = (Etext2NoteBookTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.cellDelegate = self;
    NSDictionary *noteDict = [self.dataSource objectAtIndex:indexPath.row];
    NSString *contentString = noteDict[@"content"];
    
    UITextField *label = (UITextField *)[cell viewWithTag:NOTE_TEXT];;
    label.attributedText = [Etext2Utility stringByStrippingHTML:[Etext2Utility formatHTMLString:contentString]];
    
    UIView *editViewBox = ((UIView*)[cell viewWithTag:EDIT_BOX]);
    
    //date
    UILabel *date = (UILabel*)[cell viewWithTag:DATE];
    date.text = [_mdyDateFormatter stringFromDate:[self formateDate:noteDict[@"created"]]];
    
    if(noteDict[EDIT_OPEN] && [noteDict[EDIT_OPEN] boolValue]){
        editViewBox.hidden = NO;
        Etext2CustomUITextView *textView = ((Etext2CustomUITextView*)[cell viewWithTag:TEXT_BOX]);
        //reset any selected buttons
        [self resetButtons:cell];
        textView.attributedText = [Etext2Utility stringByStrippingHTML:[Etext2Utility formatHTMLString:contentString]];
        
        //get word count
        ((UILabel*)[cell viewWithTag:WORD_COUNT]).text = [NSString stringWithFormat:@"%ld", (long)textView.text.length];
        
    }else{
        editViewBox.hidden = YES;
    }
    
//    NSLog(@"%@",[self.dataSource objectAtIndex:indexPath.row][@"content"]);

    cell.backgroundColor = [UIColor colorWithRed:221.0/255 green:221.0/255 blue:221.0/255 alpha:1];//used to hide the annoying white part at the start of the seperator
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSDictionary *dic = self.dataSource[indexPath.row];
    UIFont *attributeFont = [UIFont fontWithName:APPLICATION_STANDARD_FONT size:STANDARD_FONT_SIZE];

    NSAttributedString *attributedText;
    NSString *noteString = dic[@"content"];


    CGRect titleRect = CGRectZero;

    
    if ( noteString != nil && [noteString length] > 0 )
    {
        attributedText = [[NSAttributedString alloc] initWithString:noteString attributes:@{NSFontAttributeName: attributeFont}];
        titleRect = [attributedText boundingRectWithSize:(CGSize){350, CGFLOAT_MAX}
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                 context:nil];
        
        if(titleRect.size.height > 58){ //more than one line
            if (dic[EDIT_OPEN] && [dic[EDIT_OPEN] boolValue]) {
                return 180.0;
            }
            return titleRect.size.height;
        }
        
        if (dic[EDIT_OPEN] && [dic[EDIT_OPEN] boolValue]) {
            return 180.0;
        }
    }
    
    return 75; //accomedates one line and a date
}

#pragma mark - private methods
-(void)resetButtons:(UITableViewCell*)cell{
    
    for(int i=1;i<8;i++)
        [((Etext2CustomEditUIButton*)[cell viewWithTag:i]) setUpButtonUnSelectedStyle];
    
}

//does actual undo
- (void)undoTextFieldEdit: (NSAttributedString*)string
{
    //registers every key stroke or action
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(undoTextFieldEdit:)
                                      object:self.currentInputTextField.attributedText];
    
    self.currentInputTextField.attributedText = string;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //open the text up in a editor
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    cell.frame = CGRectMake(0, 0, 350, cell.frame.size.height + 100);
    
    NSMutableDictionary *tempDict = [self.dataSource[indexPath.row] mutableCopy];
    tempDict[EDIT_OPEN] = @(YES);
    
    self.dataSource[indexPath.row] = tempDict;

    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - note actions from Cell Delegate
- (void)attributeButtonPressed{
    [self undoTextFieldEdit:self.currentInputTextField.attributedText];
}

- (void)doUndo:(UITableViewCell *)cell{
    
    [self.undoManager undo];
    
    if([self.undoManager canUndo])
        [((Etext2CustomEditUIButton*)[cell viewWithTag:UNDO]) setButtonEnableState:YES];
    else
        [((Etext2CustomEditUIButton*)[cell viewWithTag:UNDO]) setButtonEnableState:NO];
    
    
    
}
- (void)doRedo:(UITableViewCell *)cell{
    [self.undoManager redo];
    
    if([self.undoManager canRedo])
        [((Etext2CustomEditUIButton*)[cell viewWithTag:REDO]) setButtonEnableState:YES];
    else
        [((Etext2CustomEditUIButton*)[cell viewWithTag:REDO]) setButtonEnableState:NO];
}

- (void)doDoneEditing:(UITableViewCell *)cell {

    cell.frame = CGRectMake(0, 0, 350, cell.frame.size.height - 100);
    UIView *editView = ((UIView*)[cell viewWithTag:EDIT_BOX]);
        
    editView.hidden = YES;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSMutableDictionary *tempDict = [self.dataSource[indexPath.row] mutableCopy];
    tempDict[EDIT_OPEN] = @(NO);
    
    self.dataSource[indexPath.row] = tempDict;
    
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

-(void)resetSelectedText:(UITableViewCell *)cell{
    
    Etext2CustomUITextView *textBox = ((Etext2CustomUITextView*)[cell viewWithTag:TEXT_BOX]);
    [textBox resetSelectedRange];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    
    Etext2NoteBookTableViewCell *cell = (Etext2NoteBookTableViewCell*)textView.superview.superview.superview.superview;
    
    //update count
    ((UILabel*)[cell viewWithTag:WORD_COUNT]).text = [NSString stringWithFormat:@"%ld", (long)textView.text.length];
    
    [cell doStringAttribution:textView.selectedRange fromAllText:textView.attributedText withHandler:nil];
    
    [((Etext2CustomEditUIButton*)[cell viewWithTag:UNDO]) setButtonEnableState:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    //listen for every action happening in the text box  
    [self undoTextFieldEdit:textView.attributedText];
    
     NSLog(@"Can undo: %@",textView.text);
    
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView{

    Etext2NoteBookTableViewCell *cell = (Etext2NoteBookTableViewCell*)textView.superview.superview.superview.superview;
    [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    //a new box has been chosen
    self.currentInputTextField = textView;
    [self.undoManager removeAllActions]; //clear out old undos
}

/**
 *  Listens for changed in the selection and sets up the buttons
 *
 *  @param textView
 */
- (void)textViewDidChangeSelection:(UITextView *)textView{

    NSAttributedString *allText = textView.attributedText;
    NSRange textRange = textView.selectedRange;
    
    UIView *parentView = (UITableViewCell*)textView.superview;
    
    if (textRange.length <=0) { //if nothing is selected do nothing
        return;
    }
    
    ((Etext2CustomUITextView*)textView).lastSelectedRange = textRange;
    
    Etext2CustomEditUIButton *italicButton = (Etext2CustomEditUIButton*)[parentView viewWithTag:ITALIC];
    Etext2CustomEditUIButton *boldButton = (Etext2CustomEditUIButton*)[parentView viewWithTag:BOLD];
    Etext2CustomEditUIButton *underlineButton = (Etext2CustomEditUIButton*)[parentView viewWithTag:UNDERLINE];

    //turn off the buttons
    [italicButton setUpButtonUnSelectedStyle];
    [boldButton setUpButtonUnSelectedStyle];
    [underlineButton setUpButtonUnSelectedStyle];
    
    [allText enumerateAttributesInRange:textRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {    
        
        for (id attributeType in attrs) {
            //check for any underlines
            if([attributeType isEqualToString:@"NSUnderline"]){
                [underlineButton setUpButtonSelectedStyle];
            }
            //check for existing formatting.
            if([attributeType isEqualToString:@"NSFont"]){
               NSLog(@"%@",((UIFont*)attrs[attributeType]).fontName);

                if ([((UIFont*)attrs[attributeType]).fontName rangeOfString:@"Oblique"].location != NSNotFound) {
                    [italicButton setUpButtonSelectedStyle];

                }
                
                if ([((UIFont*)attrs[attributeType]).fontName rangeOfString:@"Heavy"].location != NSNotFound) {
                    [boldButton setUpButtonSelectedStyle];

                }
                
                if ([((UIFont*)attrs[attributeType]).fontName rangeOfString:@"HeavyOblique"].location != NSNotFound) {
                    
                    [italicButton setUpButtonSelectedStyle];
                    [boldButton setUpButtonSelectedStyle];
                    
                }
            }
        }
    
    }];
    
}


#pragma mark - keyboard notifications
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (_keyboardIsShown) {
        return;
    }
    
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    CGFloat positionDifference = keyboardFrame.size.height;
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.tableViewBottomConstraint setConstant: positionDifference];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _keyboardIsShown = YES;
    }];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableViewBottomConstraint setConstant:0.0f];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        _keyboardIsShown = NO;
    }];
}


@end
