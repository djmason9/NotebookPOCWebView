//
//  Etext2AllNotesViewController.m
//  eText 2.0
//
//  Created by Mason, Darren J on 11/19/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "Etext2AllNotesViewController.h"
#import "Etext2NoteBookViewController.h"
#import "Etext2WebClient.h"
#import "Etext2Utility.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "Etext2CustomUIWebView.h"
#import "Etext2CustomEditUIButton.h"
#import "Etext2NoteBookServiceManager.h"
#import "IcoMoon.h"
#import "k12UniversalIcons.h"

//DELETE ALL THESE
#define HIGHLIGHT_COLOR [UIColor colorWithRed:59.0/255.0 green:163.0/255.0 blue:255.0/255.0 alpha:1]

#define EDIT_OPEN @"isOpen"
#define EDIT_OPEN_HEIGHT @"openHeight"

@interface Etext2AllNotesViewController(){
    
    NSString *_noteBookAPI;
    BOOL _keyboardIsShown;
    NSMutableArray *_allNotes;
    BOOL keyboardIsShown;
    NSIndexPath * _indexPath;

}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

@property(strong,nonatomic)UIRefreshControl             *refreshControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortingSegment;
@property(weak,nonatomic)IBOutlet UIView                *arrowDown;
@property (weak, nonatomic) IBOutlet UILabel            *titleIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeButtonTrailingConstraint;

@property (weak, nonatomic) IBOutlet UITableView        *tableView;
@property (weak, nonatomic) IBOutlet UIButton           *addNewBtn;
@property (weak, nonatomic) IBOutlet UIButton           *allNotesBtn;
@property (strong,nonatomic) NSMutableArray             *dataSource;
@property (strong,nonatomic) NSMutableArray             *tocDataSource;
@property (strong,nonatomic) NSMutableArray             *rawDataSource;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIView             *editView;
@property (nonatomic, strong) NSDateFormatter           *mdyDateFormatter;
@property (nonatomic,strong)NSString                    *noteIdOpened;

@property (nonatomic, weak) IBOutlet UILabel            *titleLabel;
@property(nonatomic,weak)IBOutlet UIButton              *backButton;
@property (strong, nonatomic) IBOutlet UIView           *searchBarBackground;
@property (strong,nonatomic) NSDictionary               *serverList;
@property (strong,nonatomic)NSArray                     *pageContexts;
@property (strong,nonatomic) NSMutableArray             *noteCountArray;
@property (strong,nonatomic) NSMutableDictionary        *filterButtonDict;

//1/6/2016
@property (weak, nonatomic) IBOutlet UIView             *filterView;
@property (weak, nonatomic) IBOutlet UIView             *notesFilterView;



@end

@implementation Etext2AllNotesViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];

    self.arrowDown.transform = CGAffineTransformMakeRotation(M_PI/4);
    
    [self.backButton.titleLabel setFont:[UIFont fontWithName:kFontk12UniversalIcons size:18]];
    [self.backButton setTitle:[IcoMoon iconString:k12_MENU_CLOSE] forState:UIControlStateNormal];
    self.backButton.isAccessibilityElement = YES;
    self.backButton.tag = 0;
    self.backButton.accessibilityLabel = NSLocalizedString(@"Go to previous", nil);
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
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
    
    [_titleIcon setFont:[UIFont fontWithName:kFontk12UniversalIcons size:18]];
    [_titleIcon setText:[IcoMoon iconString:k12_NOTEBOOK]];
    
    NSDictionary *segmentedControlTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:APPLICATION_STANDARD_FONT size:12.0], NSForegroundColorAttributeName:[UIColor darkGrayColor]};
    [_sortingSegment setTitleTextAttributes:segmentedControlTextAttributes forState:UIControlStateNormal];
    [_sortingSegment setTitleTextAttributes:segmentedControlTextAttributes forState:UIControlStateHighlighted];
    [_sortingSegment setTintColor:HIGHLIGHT_COLOR];
    
    self.mdyDateFormatter = [[NSDateFormatter alloc] init];
    [self.mdyDateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestNotesForRefresh)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self buildRootandFirstChild:nil];
    [self getNotebookList];
}




-(void)viewWillAppear:(BOOL)animated{
//    [self.bookDelegate showContainer:NO usingBindId:NINE_DOT_ALL_NOTEBOOK];
}

#pragma mark - Actions
//Reloads data from server
-(void)getLatestNotesForRefresh{
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }

    self.sortingSegment.selectedSegmentIndex = 0;
    self.tableView = nil;
    [self buildRootandFirstChild:nil];
    [self getNotebookList];
}

-(IBAction)backActionHandler:(id)sender
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:ROOT_LEVEL object: nil];
    
}
-(IBAction)clearFilter:(id)sender{

}
-(IBAction)setFilter:(UIButton*)checkbox{

    BOOL isChecked = checkbox.tag;
    
    if(isChecked){ //if checked turn it off
        [checkbox setBackgroundImage:[UIImage imageNamed:@"Checkbox_Active"] forState:UIControlStateNormal];
        checkbox.tag = NO;
        //do some filter action
    }
    else{ //if not checked turn it on
        checkbox.tag = YES;
        [checkbox setBackgroundImage:[UIImage imageNamed:@"Checkbox_Selected"] forState:UIControlStateNormal];
        //do some filter action
    }
    
}

- (IBAction)filterNotesTable:(UISegmentedControl*)sender {
    if(sender.selectedSegmentIndex >0){

        //loop all the data in every page and check the dates for all of them and sort them by that
        /*
         self.dataSource Looks like this
         
         [
             Unit : [
                Page : [Note,Note,Note]
                Page : [Note,Note,Note]
                Page : [Note,Note]
             ],
             Unit : [
                Page : [Note,Note]
                Page : [Note]
             ],
             Unit : [
                Page : [Note]
                Page : [Note,Note,Note]
                Page : [Note,Note]
             ]
         ]
         */
        //in order to display this we need to drop the headers and flatten out the array to Children > Notes

        
        NSMutableArray *allNotes = [NSMutableArray new];
        NSMutableArray *sortedAllNotes = [NSMutableArray new];
        for(NSDictionary *unit in self.dataSource){
            NSString *unitTitle = unit[ETEXT_NOTEBOOK_PAGE_TITLE];
            for(NSDictionary *page in unit[ETEXT_NOTEBOOK_CHILDREN]){
                NSString *pageTitle = page[ETEXT_NOTEBOOK_PAGE_TITLE];
                for (NSDictionary *note in page[ETEXT_NOTEBOOK_NOTES]) {
                    //add the unit and page name
                    NSMutableDictionary *mutedNote = [note mutableCopy];
                    mutedNote[ETEXT_NOTEBOOK_PAGE_TITLE] = pageTitle;
                    mutedNote[ETEXT_NOTEBOOK_UNIT_TITLE] = unitTitle;
                    [allNotes addObject:mutedNote];
                }
            }
            
        }
        
        NSLog(@"%@", allNotes);
        //sort by date
        NSSortDescriptor *sortType = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortType];
        //sorted Array
        sortedAllNotes = [[allNotes sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
        NSLog(@"%@",sortedAllNotes);
        
        self.dataSource = sortedAllNotes;
        [_tableView reloadData];
    
        
    }else{
        self.dataSource = _tocDataSource;
        [_tableView reloadData];
    }
}


#pragma mark - UITableViewDelegate

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(_sortingSegment.selectedSegmentIndex > 0){
        return nil;
    }
    
    UIView *dropDownView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [dropDownView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0]];

    NSDictionary *pageDataObj = _dataSource[section];
    
    UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    arrowButton.tag = section;
    arrowButton.isAccessibilityElement = YES;
    arrowButton.accessibilityLabel = NSLocalizedString(@"Show items", nil);
    [arrowButton addTarget:self
               action:@selector(openItems:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [arrowButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:20]];
    [arrowButton setTitle:[NSString fontAwesomeIconStringForEnum:FACaretRight] forState:UIControlStateNormal];
    
    [arrowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    arrowButton.frame = CGRectMake(5, 5, 40, 40.0);
    [dropDownView addSubview:arrowButton];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (tableView.frame.size.width-30), 47.0)];
    [view setBackgroundColor:[UIColor whiteColor]];
    UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, tableView.frame.size.width-30, 30)];
    [fromLabel setFont:[UIFont fontWithName:APPLICATION_STANDARD_FONT size:18.0]];
    fromLabel.text = pageDataObj[ETEXT_NOTEBOOK_PAGE_TITLE];

    UILabel *noteCount = [[UILabel alloc]initWithFrame:CGRectMake(tableView.frame.size.width-60, 10, 50, 30)];
    [noteCount setFont:[UIFont fontWithName:APPLICATION_STANDARD_FONT size:12.0]];

    noteCount.text = [NSString stringWithFormat:@"%@",self.noteCountArray[section]];
    noteCount.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [view addSubview:noteCount];
    [view addSubview:fromLabel];
    [view addSubview:dropDownView];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if(!self.dataSource) {
        return 1;
    }
    
    if(_sortingSegment.selectedSegmentIndex > 0){
        return 1;
    }
    
    return self.dataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.dataSource) {
        return 0;
    }
    
    if(_sortingSegment.selectedSegmentIndex > 0){
        return self.dataSource.count;
    }
    
    NSDictionary *pageDetailObj = self.dataSource[section];
    NSArray *children = pageDetailObj[ETEXT_NOTEBOOK_CHILDREN];
    NSUInteger childrenCount = 0;
    for(NSDictionary *child in children){
        childrenCount += [child[ETEXT_NOTEBOOK_NOTES] count];
    }
    
    
    // Return the number of rows in the section.
    return childrenCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Etext2NoteBookTableViewCell *cell = (Etext2NoteBookTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.cellDelegate = self;
    
    //move this to its own method
    NSDictionary *pageDataObj = [self buildNotesArrayForIndexPath:indexPath];
    NSString *rootName;
    NSString *tocBeadCrumbString;
    
    //get a note for each row
    NSDictionary *noteDict = _allNotes[indexPath.row];
    NSString *currentPageTitle = noteDict[ETEXT_NOTEBOOK_PAGE_TITLE];
    
    if(pageDataObj){
        rootName = pageDataObj[ETEXT_NOTEBOOK_PAGE_TITLE];
    }else{
        rootName = noteDict[ETEXT_NOTEBOOK_UNIT_TITLE];
    }
    
    
    if(noteDict[ETEXT_NOTEBOOK_PAGE_TITLE] && ![rootName isEqualToString:currentPageTitle]){
        tocBeadCrumbString = [NSString stringWithFormat:@"%@ > %@",rootName,currentPageTitle];
    }else{
        tocBeadCrumbString = rootName;
    }
    UILabel *tocBeadCrumb = ((UILabel*)[cell viewWithTag:TOC_LABEL]);
    
    [tocBeadCrumb setText:tocBeadCrumbString];
    
    NSString *question = noteDict[ETEXT_NOTEBOOK_QUESTION];
    NSString *contentString = noteDict[ETEXT_NOTEBOOK_CONTENT];
    
    if(question){
        contentString = [NSString stringWithFormat:@"<b>%@</b><br>%@",[Etext2Utility stripOutwhiteSpace: question],contentString];
    }
    
    NSString *noteId = noteDict[@"objectId"];
    cell.noteId = noteId;
    
    Etext2CustomUIWebView *label = (Etext2CustomUIWebView *)[cell viewWithTag:NOTE_TEXT];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setOpaque:NO];
    //    label.attributedText = [Etext2Utility stringByStrippingHTML:[Etext2Utility formatHTMLString:contentString]];
    [label loadHTMLString:contentString baseURL:nil];
    
    UIView *editViewBox = ((UIView*)[cell viewWithTag:EDIT_BOX]);
    
    
    
    //date

    UILabel *date = (UILabel*)[cell viewWithTag:DATE];
    date.text = [_mdyDateFormatter stringFromDate:[self formateDate:noteDict[@"updated"]]];

    if(noteDict[EDIT_OPEN] && [noteDict[EDIT_OPEN] boolValue]){
        editViewBox.hidden = NO;
        Etext2CustomUIWebView *textView = ((Etext2CustomUIWebView*)[cell viewWithTag:TEXT_BOX]);
        //reset any selected buttons
        [self resetButtons:cell];
        
        [textView loadHTMLStringForEdit:contentString];
                
    }else{
        editViewBox.hidden = YES;
    }

    
    cell.backgroundColor = [UIColor colorWithRed:221.0/255 green:221.0/255 blue:221.0/255 alpha:1];//used to hide the annoying white part at the start of the seperator
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self buildNotesArrayForIndexPath:indexPath];
    NSDictionary *dic = _allNotes[indexPath.row];
    UIFont *attributeFont = [UIFont fontWithName:APPLICATION_STANDARD_FONT size:STANDARD_FONT_SIZE];
    
    NSAttributedString *attributedText;
    NSString *noteString = dic[ETEXT_NOTEBOOK_CONTENT];
    NSString *question = dic[ETEXT_NOTEBOOK_QUESTION];
    CGFloat rowHeight = 0.0; //only for edit and question height
    
    if(question){
        noteString = [NSString stringWithFormat:@"%@<br>%@",[Etext2Utility stripOutwhiteSpace: question],noteString];
        rowHeight = (180.0 + [self getQuestionHeight:question]);
    }
    
    //replace any html that creates empty space with a \n to poperly calculate the size.
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"<(\\/b).*?>|<(br).*?>|<(\\/ol).*?>|<(\\/ul).*?>"
                                                                        options:0
                                                                          error:NULL];
    
    noteString = [re stringByReplacingMatchesInString:noteString
                                              options:0
                                                range:NSMakeRange(0, [noteString length])
                                         withTemplate:@"\n"];
    
    
    noteString = [noteString stringByAppendingString:@"\n\n"];
    
    CGRect titleRect = CGRectZero;
    
    
    if ( noteString != nil && [noteString length] > 0 )
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSAttributedString *attrNoteString = [[NSAttributedString alloc] initWithString:noteString];
        attributedText = [[NSAttributedString alloc] initWithString:[[Etext2Utility stringByStrippingHTML:attrNoteString] string] attributes:@{NSFontAttributeName: attributeFont, NSParagraphStyleAttributeName: paragraphStyle}];
        
        titleRect = [attributedText boundingRectWithSize:(CGSize){350, CGFLOAT_MAX}
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                 context:nil];
        
        if(titleRect.size.height > 55){ //more than one line
            if (dic[EDIT_OPEN] && [dic[EDIT_OPEN] boolValue]) {
                if(question){
                    return rowHeight;
                }else{
                    return 180.0;
                }
            }
            return titleRect.size.height+30; //account for the date
        }
        
        if (dic[EDIT_OPEN] && [dic[EDIT_OPEN] boolValue]) {
            if(question){
                return rowHeight;
            }else{
                return 180.0;
            }
        }
    }else if(dic[EDIT_OPEN]){ //new row
        if(question){
            return rowHeight;
        }else{
            return 180.0;
        }
        
    }
    
    return 75; //accomedates one line and a date
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     _indexPath = indexPath;
    
    //open the text up in a editor
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    UIView *editViewBox = ((UIView*)[cell viewWithTag:EDIT_BOX]);
    if(!editViewBox.isHidden){//dont do anyting if its editing
        return;
    }
    
    cell.frame = CGRectMake(0, 0, 350, cell.frame.size.height + 100);
    
    
    [self buildNotesArrayForIndexPath:indexPath];
    NSMutableDictionary *noteDict = [_allNotes[indexPath.row]mutableCopy];

    noteDict[EDIT_OPEN] = @(YES);
    noteDict[EDIT_OPEN_HEIGHT] = @(120);
//
    [_allNotes replaceObjectAtIndex:indexPath.row withObject:noteDict];
    
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Etext2NoteBookCell Delegates
-(void)doDelete:(NSIndexPath*)indexPath{
    
}

- (void)doDoneEditing:(Etext2NoteBookTableViewCell *)cell {

}

#pragma mark - private methods
-(CGFloat)getQuestionHeight:(NSString*)question{
    
    
    CGRect questionRect = CGRectZero;
    UIFont *attributeFont = [UIFont fontWithName:APPLICATION_STANDARD_FONT size:STANDARD_FONT_SIZE];
    
    NSAttributedString *attributedText;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSAttributedString *attrQuestionString = [[NSAttributedString alloc] initWithString:question];
    attributedText = [[NSAttributedString alloc] initWithString:[[Etext2Utility stringByStrippingHTML:attrQuestionString] string] attributes:@{NSFontAttributeName: attributeFont, NSParagraphStyleAttributeName: paragraphStyle}];
    
    questionRect = [attributedText boundingRectWithSize:(CGSize){350, CGFLOAT_MAX}
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
    
    return questionRect.size.height-20;
}

-(NSDictionary*)buildNotesArrayForIndexPath:(NSIndexPath*)indexPath{
    
    NSMutableDictionary *pageDataObj;
    _allNotes = [NSMutableArray new];
    
    if(_sortingSegment.selectedSegmentIndex>0){
    

        for(NSDictionary *note in self.dataSource){
            
            NSMutableDictionary *mutedNotes = [note mutableCopy];
            [mutedNotes setObject:note[ETEXT_NOTEBOOK_PAGE_TITLE] forKey:ETEXT_NOTEBOOK_PAGE_TITLE];
            [_allNotes addObject:mutedNotes];

        }
        

    }else{
    
        pageDataObj = [self.dataSource objectAtIndex:indexPath.section];
        NSArray *notes = pageDataObj[ETEXT_NOTEBOOK_CHILDREN];//my names are in this array this is all the pages under this unit
        
        for(NSDictionary *note in notes){//loops the pages each page will only have one name so get the first one and set a name
            NSMutableArray *allMutedNotes = [note[ETEXT_NOTEBOOK_NOTES] mutableCopy];
            
            NSMutableDictionary *mutedNotes = [allMutedNotes[0] mutableCopy];
            [mutedNotes setObject:note[ETEXT_NOTEBOOK_PAGE_TITLE] forKey:ETEXT_NOTEBOOK_PAGE_TITLE];
            [allMutedNotes replaceObjectAtIndex:0 withObject:mutedNotes];
            [_allNotes addObjectsFromArray:allMutedNotes];
        }
    }
    
    return pageDataObj;

}

-(void)getNotebookList{
    
    //get array of pageURLS from TOC
//    NSString *apiURL = @"http://nightly-nbapi.elasticbeanstalk.com/api/v1/notebook/books/95644ccd-354a-4886-bbb4-9a40f0fb191e/notes";
    
    NSString *apiURL = @"https://spt.psondev.net/gps_api/notebookservice/api/v1/notebook/books/95644ccd-354a-4886-bbb4-9a40f0fb191e/notes";
    
    NSArray *pageUrls = [self buildPageContextArray];
    NSString *pageContexts = @"{\"pageContexts\":";
    
    NSString *jsonString = [NSString stringWithFormat:@"%@[",pageContexts];
    
    for (int i=0; i < pageUrls.count; i++) {
        NSString *page = pageUrls[i];
        NSString *comma;
        
        comma = i>0 ? @",": @"";
        
        NSString *formatedPage = [NSString stringWithFormat:@"%@\"%@\"",comma,page];
        
        jsonString = [jsonString stringByAppendingString:formatedPage];
    }
    
   jsonString = [jsonString stringByAppendingString:@"]}"];
    
    
    
    [Etext2NoteBookServiceManager getAllNotes:apiURL bodyText:jsonString withHandler:^(NSDictionary *pageDictionary, NSError *error) {
        if(!error){
            [self getAllNotesPrompts:pageDictionary];
        }else{
            //do error stuff
        }
    }];
    
}

-(void)addFilterButtons{
    
    CGRect firstbuttonFrame = _notesFilterView.frame;
    
    for(NSString *key in [_filterButtonDict allKeys]){
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 135, 44)];
        
        
        UILabel *buttonTitle = [[UILabel alloc] initWithFrame:CGRectMake(27, 7, ([key length]*6), 21)];
        [buttonTitle setText:key];
        buttonTitle.font = [UIFont fontWithName:APPLICATION_STANDARD_FONT size:12.0];
        
        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterButton addTarget:self
                   action:@selector(setFilter:)
         forControlEvents:UIControlEventTouchUpInside];
        [filterButton setTitle:@"" forState:UIControlStateNormal];
        [filterButton setBackgroundImage:[UIImage imageNamed:@"Checkbox_Active"] forState:UIControlStateNormal];
        filterButton.frame = CGRectMake(1, 6, 20, 20.0);
        [containerView addSubview:filterButton];
        [containerView addSubview:buttonTitle];
        
        containerView.frame = CGRectMake((firstbuttonFrame.origin.x - (buttonTitle.frame.size.width+30)), firstbuttonFrame.origin.y, buttonTitle.frame.size.width + 30, 44);
        
        
        [_filterView addSubview:containerView];

        firstbuttonFrame = containerView.frame;

    }
}

-(void)getAllNotesPrompts:(NSDictionary*)pageDictionary{
    //TODO remove this hard coded url
    NSString *apiURL = @"https://content-service-qa.stg-prsn.com/csg/api/v2/search?indexType=d6bc33e564b4bb01adba783757a42782&fieldsToReturn=promptId,pageUrl,promptText,tags&groupBy=pageUrl";
    
    [Etext2NoteBookServiceManager getAllNotesPrompts:apiURL withHandler:^(NSDictionary *promptsDict, NSError *error) {
        
        [self mergePrompts:promptsDict intoNotes:pageDictionary];
        [self addFilterButtons];
        
         _tableView.hidden = NO;
        [self.tableView reloadData];
        [_spinner stopAnimating];
        [self.sortingSegment setEnabled:YES];
        [self.sortingSegment setAlpha:1];
    }];
    
}
-(void)mergePrompts:(NSDictionary*)promptsDict intoNotes:(NSDictionary*)pageDictionary{
    NSMutableDictionary *newPageDictionary = [NSMutableDictionary dictionaryWithDictionary:pageDictionary];
    
    
    //loop the
    for(NSString *key in [pageDictionary allKeys]){
        NSMutableDictionary *newNotes = [NSMutableDictionary new];
        NSArray *allNotes = newPageDictionary[key][ETEXT_NOTEBOOK_NOTES];
        NSMutableArray *mutedNotes =[NSMutableArray new];
        for(NSDictionary *note in allNotes){
            NSMutableDictionary *mutedNote = [NSMutableDictionary dictionaryWithDictionary:note];
            
            if(note[ETEXT_NOTEBOOK_PARENT_ID]){ //if it has a promptId add the prompt
                
                //go find the prompt for this note!!
                for(NSDictionary *promptPage in promptsDict[@"searchResults"]){
                    NSDictionary *promptObj = promptPage[@"source"][@"cnt:auxiliaryFields"];
                    
                    NSString *pKey = promptObj[@"pageUrl"];
                    NSString *promptId = promptObj[@"promptId"];
                    NSString *questionText = promptObj[@"promptText"];
                    NSString *tags = promptObj[@"tags"];
                    
                    //use the tags for filters so gather those up
                    if(!_filterButtonDict)_filterButtonDict = [NSMutableDictionary new];
                    [_filterButtonDict setObject:@"button" forKey:tags];
                    
                    if([pKey rangeOfString:@"/"].location == 0){
                        pKey = [pKey substringFromIndex:1];
                    }
                    
                    if([note[ETEXT_NOTEBOOK_PARENT_ID] isEqualToString:promptId]){
                        mutedNote[ETEXT_NOTEBOOK_QUESTION] = questionText;
                        mutedNote[@"tags"] = tags;
                    }
                }
            }
            
            [mutedNotes addObject:mutedNote]; //set up new array with altered notes
            
        }
        
        
        if(mutedNotes.count>0){
            //add new notes to pagedict
            [newNotes setObject:mutedNotes forKey:ETEXT_NOTEBOOK_NOTES];
            [newPageDictionary setObject:newNotes forKey:key];
        }
        
    }

    [self mergeNotesAndPromptsToDataSource:newPageDictionary];

}

-(void)mergeNotesAndPromptsToDataSource:(NSDictionary*)pageDictionary{
    
    if(!self.noteCountArray)
        self.noteCountArray = [NSMutableArray new];
    
    NSUInteger allNoteCount=0;
    
    //loop array of pages
    for(NSMutableDictionary*page in _rawDataSource){
        
        NSMutableDictionary *rootChild = [NSMutableDictionary new];
        //page needs to have new kids added so we need to mute it
        NSMutableDictionary *childrenWithNotes = [[NSDictionary dictionaryWithDictionary:page]mutableCopy];
        
        NSArray *children = childrenWithNotes[ETEXT_NOTEBOOK_CHILDREN];//we will replace this after we add the notes
        NSString *key = childrenWithNotes[ETEXT_NOTEBOOK_PAGE_CAP_URL];
        
        NSDictionary *notesForPage = pageDictionary[key]; //test the root for notes
        NSArray *notes = notesForPage[ETEXT_NOTEBOOK_NOTES]; //grab any notes
        

        allNoteCount +=notes.count;
        
        //need to set up a new dictionary to add to the page
        [rootChild setObject:childrenWithNotes[ETEXT_NOTEBOOK_PAGE_CAP_URL] forKey:ETEXT_NOTEBOOK_PAGE_CAP_URL];
        [rootChild setObject:childrenWithNotes[ETEXT_NOTEBOOK_PAGE_ID] forKey:ETEXT_NOTEBOOK_PAGE_ID];
        [rootChild setObject:childrenWithNotes[ETEXT_NOTEBOOK_PAGE_NUMBER] forKey:ETEXT_NOTEBOOK_PAGE_NUMBER];
        [rootChild setObject:childrenWithNotes[ETEXT_NOTEBOOK_PAGE_TITLE] forKey:ETEXT_NOTEBOOK_PAGE_TITLE];
        [rootChild setObject:childrenWithNotes[ETEXT_NOTEBOOK_PARENT_ID] forKey:ETEXT_NOTEBOOK_PARENT_ID];
        
        if(notes.count>0){
            [rootChild setObject:notes forKey:ETEXT_NOTEBOOK_NOTES];
        }
        
        NSMutableArray *tmpArray =[NSMutableArray new];
        [tmpArray addObject:rootChild];
        
        //loop the notes for this page
        for(NSDictionary *child in children){
            //need to add stuff to the child so mute it
            NSMutableDictionary *muteChild = [[NSDictionary dictionaryWithDictionary:child] mutableCopy];
            key = muteChild[ETEXT_NOTEBOOK_PAGE_CAP_URL];
            notesForPage = pageDictionary[key];
            notes = notesForPage[ETEXT_NOTEBOOK_NOTES];

            if(notes.count>0){
                [muteChild setObject:notes forKey:ETEXT_NOTEBOOK_NOTES];
                [tmpArray addObject:muteChild];
            }
            
            allNoteCount +=notes.count;
        }
        
        //counts total notes for each unit
        [self.noteCountArray addObject:[NSString stringWithFormat:@"%ld",(long)allNoteCount]];
        
        
        childrenWithNotes[ETEXT_NOTEBOOK_CHILDREN] = tmpArray;
        if(!_dataSource)_dataSource = [NSMutableArray new];
        [_dataSource addObject:childrenWithNotes];
        
    }
    
    _tocDataSource = _dataSource;
    
}
-(NSArray*)buildPageContextArray{
    // THIS WILL BE GOTTEN FROM CORE DATA
    NSArray *pageArray = @[
                           @"OPS/s9ml/chapter02/filep7000495165000000000000000000005.xhtml",
                           @"OPS/s9ml/chapter02/filep7000495165000000000000000000018.xhtml#e9b2f7d344be4bcebb5385034b4c24ce"
                           ];
    
    return  pageArray;
}

-(void)buildRootandFirstChild:(NSString*)pageId{

    //GO GET THE DATA FROM CORE DATA HERE
    //MULTI UNITS
   // NSString *jsonString =@"[{    \"children\":   [                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a5015c34116b64f884474d01777e74626a02c3c12-c693bc8f863b4f4f96d1f2b7728be421\",            \"pageNumber\":\"2\",            \"pageTitle\":\"Chapter 3: Demand and Supply\",            \"pageURL\":\"OPS/s9ml/chapter03/filep7000495374000000000000000000005.xhtml#c693bc8f863b4f4f96d1f2b7728be421\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"c693bc8f863b4f4f96d1f2b7728be421\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a491aed43590bcaf1cda99c5d08094c94d086c981-b6013640bc2a4fd690163b4da842e176\",            \"pageNumber\":\"3\",            \"pageTitle\":\"Did You Know That\",            \"pageURL\":\"OPS/s9ml/chapter03/filechunkd2613e101.xhtml#b6013640bc2a4fd690163b4da842e176\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"b6013640bc2a4fd690163b4da842e176\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a561cd2f7a3d6e5c1c22fb30ff09fc430f3e96766-a9a9c982436541da8b71336fae41bccf\",            \"pageNumber\":\"4\",            \"pageTitle\":\"Demand\",            \"pageURL\":\"OPS/s9ml/chapter03/filep700049537400000000000000000002a.xhtml#a9a9c982436541da8b71336fae41bccf\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"a9a9c982436541da8b71336fae41bccf\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a6bdb33d0b544be37fe83d2ad98cacb21d83e7155-e65f56db91574ead90329f4a4769baeb\",            \"pageNumber\":\"5\",            \"pageTitle\":\"Shifts in Demand\",            \"pageURL\":\"OPS/s9ml/chapter03/filep70004953740000000000000000000c6.xhtml#e65f56db91574ead90329f4a4769baeb\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"e65f56db91574ead90329f4a4769baeb\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"ac7cfdf91204acb6beafcbf3db486bcbf19fddb24-ede91f3742b14832ada20987790cc09f\",            \"pageNumber\":\"6\",            \"pageTitle\":\"Supply\",            \"pageURL\":\"OPS/s9ml/chapter03/filep700049537400000000000000000015c.xhtml#ede91f3742b14832ada20987790cc09f\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"ede91f3742b14832ada20987790cc09f\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a8356190b5e789ef7eccfae5976d74bc0d050c793-ab204826e4144f99bd9394648b5cd667\",            \"pageNumber\":\"7\",            \"pageTitle\":\"Shifts in Supply\",            \"pageURL\":\"OPS/s9ml/chapter03/filep70004953740000000000000000001b4.xhtml#ab204826e4144f99bd9394648b5cd667\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"ab204826e4144f99bd9394648b5cd667\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a819c7dde6cd4ba8d7107b9f6f9c4c86695ed4f9a-cf977aaee55d415fba2773512f7ec83a\",            \"pageNumber\":\"8\",            \"pageTitle\":\"Putting Demand and Supply Together\",            \"pageURL\":\"OPS/s9ml/chapter03/filep700049537400000000000000000020b.xhtml#cf977aaee55d415fba2773512f7ec83a\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"cf977aaee55d415fba2773512f7ec83a\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"af848bffce17bab588423f445ee0dc6499e994e7c-d082a30404344b6a877813fdaa34d76b\",            \"pageNumber\":\"9\",            \"pageTitle\":\"Exhibit 8\",            \"pageURL\":\"OPS/s9ml/chapter03/reader_1.xhtml#d082a30404344b6a877813fdaa34d76b\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"d082a30404344b6a877813fdaa34d76b\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a077c0dff04fb91384e2e13e40c51a2d0f4dfb2a9-eb3707103d3649f89940ccd6fd9de9c8\",            \"pageNumber\":\"10\",            \"pageTitle\":\"You Are There: In Finland, the Taxman Screams, Less Ice Cream!\",            \"pageURL\":\"OPS/s9ml/chapter03/filep700049537400000000000000000020b_1.xhtml#eb3707103d3649f89940ccd6fd9de9c8\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"eb3707103d3649f89940ccd6fd9de9c8\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a2791ecc6924ea3d659ec36aabf746bd488e38e1a-ec268954df1c4edeac25eb9eb5f3d044\",            \"pageNumber\":\"11\",            \"pageTitle\":\"Issues & Applications\",            \"pageURL\":\"OPS/s9ml/chapter03/filep700049537400000000000000000020b_2.xhtml#ec268954df1c4edeac25eb9eb5f3d044\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"ec268954df1c4edeac25eb9eb5f3d044\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a78fb774a5df198bf8236892bf507ef3ca2149e8d-f5d5a6d4960449a2a4ea0421703af70a\",            \"pageNumber\":\"12\",            \"pageTitle\":\"Fundamental Points\",            \"pageURL\":\"OPS/s9ml/chapter03/filep700049537400000000000000000020b_3.xhtml#f5d5a6d4960449a2a4ea0421703af70a\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"f5d5a6d4960449a2a4ea0421703af70a\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a62b7ca9b83f32473df152cec4c87282fb9d92e5b-e101d90621fd4a008cd031862dfcf661\",            \"pageNumber\":\"13\",            \"pageTitle\":\"What You Should Know\",            \"pageURL\":\"OPS/s9ml/chapter03/filep700049537400000000000000000020b_4.xhtml#e101d90621fd4a008cd031862dfcf661\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"e101d90621fd4a008cd031862dfcf661\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a9e35af6d29af85988a283b9fb9af4eacbdcf47f9-data-uuid-d2f5d6bd5bfe4f18aaed677e5f75c318\",            \"pageNumber\":\"14\",            \"pageTitle\":\"Problems\",            \"pageURL\":\"OPS/s9ml/chapter03/filep700049537400000000000000000020b_5.xhtml#data-uuid-d2f5d6bd5bfe4f18aaed677e5f75c318\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"data-uuid-d2f5d6bd5bfe4f18aaed677e5f75c318\"        },                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a0a286af2f2e43dc9781ae659799f0c01b4bbc1ff-data-uuid-8059b46013554dd79e27cc1a5156c75a\",            \"pageNumber\":\"15\",            \"pageTitle\":\"References\",            \"pageURL\":\"OPS/s9ml/chapter03/filep70004953740000000000000000003fa.xhtml#data-uuid-8059b46013554dd79e27cc1a5156c75a\",            \"parentId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",            \"urlTag\":\"data-uuid-8059b46013554dd79e27cc1a5156c75a\"        }    ],    \"isChildren\":\"1\",    \"isDownloaded\":\"0\",    \"pageId\":\"a5015c34116b64f884474d01777e74626a02c3c12\",    \"pageNumber\":\"1\",    \"pageTitle\":\"Chapter 3: Demand and Supply\",    \"pageURL\":\"OPS/s9ml/chapter03/filep7000495374000000000000000000005.xhtml\",    \"parentId\":\"root\",    \"urlTag\":\"\"},{    \"children\": [                {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a2d5c17919ff61c93d3d894fb7f2095a3765b08c7\",            \"pageNumber\":\"16\",            \"pageTitle\":\"Glossary\",            \"pageURL\":\"OPS/s9ml/glossary.xhtml\",            \"parentId\":\"a2d5c17919ff61c93d3d894fb7f2095a3765b08c7\",            \"urlTag\":\"\"        }    ],    \"isChildren\":\"1\",    \"isDownloaded\":\"0\",    \"pageId\":\"a2d5c17919ff61c93d3d894fb7f2095a3765b08c7\",    \"pageNumber\":\"16\",    \"pageTitle\":\"Appendix\",    \"pageURL\":\"OPS/s9ml/glossary.xhtml\",    \"parentId\":\"root\",    \"urlTag\":\"\"}]";
    
    NSString *jsonString = @"[   {      \"children\":[         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a12d1ab258e972ee460516365bb0cb240ede659a6-e9b2f7d344be4bcebb5385034b4c24ce\",            \"pageNumber\":\"3\",            \"pageTitle\":\"2.1 Scalars and Vectors\",            \"pageURL\":\"OPS/s9ml/chapter02/filep7000495165000000000000000000018.xhtml#e9b2f7d344be4bcebb5385034b4c24ce\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"e9b2f7d344be4bcebb5385034b4c24ce\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a9742d6c50bf2a35c2c3ccc956f495ae4db7d0a4a-afb9501c8e064db4b6d42c3d8cea151a\",            \"pageNumber\":\"4\",            \"pageTitle\":\"2.2 Vector Operations\",            \"pageURL\":\"OPS/s9ml/chapter02/filep7000495165000000000000000000026.xhtml#afb9501c8e064db4b6d42c3d8cea151a\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"afb9501c8e064db4b6d42c3d8cea151a\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a54eb422761373247fb43733d3fdb0726545acae8-f05d3f82279f4dd7bd9d2e85c27f109e\",            \"pageNumber\":\"5\",            \"pageTitle\":\"2.3 Vector Addition of Forces\",            \"pageURL\":\"OPS/s9ml/chapter02/filep7000495165000000000000000000053.xhtml#f05d3f82279f4dd7bd9d2e85c27f109e\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"f05d3f82279f4dd7bd9d2e85c27f109e\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"ad5ae3eb1f5b6b080bc6fe35afb2ce82c596c4022-aa23391eba64424f80ae3650101247fb\",            \"pageNumber\":\"6\",            \"pageTitle\":\"2.3 Examples\",            \"pageURL\":\"OPS/s9ml/chapter02/2_3_examples.xhtml#aa23391eba64424f80ae3650101247fb\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"aa23391eba64424f80ae3650101247fb\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"ab756802e2b68b2f14932c370e9442179777abe18-f697a135105a4470af14f280ecacc169\",            \"pageNumber\":\"7\",            \"pageTitle\":\"2.3 Preliminary Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_3_preliminary_problems.xhtml#f697a135105a4470af14f280ecacc169\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"f697a135105a4470af14f280ecacc169\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a3df2bba42d3fcc0fa8f5d8f76f6341f4859cbce4-f697a135105a4470af14f280ecacc169\",            \"pageNumber\":\"8\",            \"pageTitle\":\"2.3 Fundamental Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_3_fundamental_problems.xhtml#f697a135105a4470af14f280ecacc169\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"f697a135105a4470af14f280ecacc169\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"aa9921b0388db452ce4e1535e7842f83fdecc0ab7-f697a135105a4470af14f280ecacc169\",            \"pageNumber\":\"9\",            \"pageTitle\":\"2.3 Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_3_problems.xhtml#f697a135105a4470af14f280ecacc169\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"f697a135105a4470af14f280ecacc169\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a2d76e3b32f057d3066cb678ab4cacd1177d35336-e7092b7761404c18becaafe93b692b16\",            \"pageNumber\":\"10\",            \"pageTitle\":\"2.4 Addition of a System of Coplanar Forces\",            \"pageURL\":\"OPS/s9ml/chapter02/filep70004951650000000000000000001ef.xhtml#e7092b7761404c18becaafe93b692b16\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"e7092b7761404c18becaafe93b692b16\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"ae72e14a97c8bdeaac53827ba47143eee19e55e76-daa4c38fcc964ee79f70cdd2bdca0a0d\",            \"pageNumber\":\"11\",            \"pageTitle\":\"2.4 Examples\",            \"pageURL\":\"OPS/s9ml/chapter02/2_4_examples.xhtml#daa4c38fcc964ee79f70cdd2bdca0a0d\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"daa4c38fcc964ee79f70cdd2bdca0a0d\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a9bfbef4d6c865b1b3127ced7f3d1ab3d9de45cd7-dbeb2c88d78646ccbfc6a13826e7ec4d\",            \"pageNumber\":\"12\",            \"pageTitle\":\"2.4 Fundamental Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_4_fundamental_problems.xhtml#dbeb2c88d78646ccbfc6a13826e7ec4d\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"dbeb2c88d78646ccbfc6a13826e7ec4d\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"acc826a1b63752f1931afb4d28baf77d086bd901f-d1e8e57a9b8342d4b291f16a11bb2df2\",            \"pageNumber\":\"13\",            \"pageTitle\":\"2.4 Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_4_problems.xhtml#d1e8e57a9b8342d4b291f16a11bb2df2\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"d1e8e57a9b8342d4b291f16a11bb2df2\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"aa1e99f57249a21954d4a78d912e16702bc857d2f-bd8334a7ccf842938afacc74243d6678\",            \"pageNumber\":\"14\",            \"pageTitle\":\"2.5 Cartesian Vectors\",            \"pageURL\":\"OPS/s9ml/chapter02/filep7000495165000000000000000000371.xhtml#bd8334a7ccf842938afacc74243d6678\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"bd8334a7ccf842938afacc74243d6678\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a7be4ddbcb6272c1a473b4b7433143ce57fdc819a-ca3315affae34fd78a28b63afacbecf3\",            \"pageNumber\":\"15\",            \"pageTitle\":\"2.6 Addition of Cartesian Vectors\",            \"pageURL\":\"OPS/s9ml/chapter02/filep70004951650000000000000000003d5.xhtml#ca3315affae34fd78a28b63afacbecf3\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"ca3315affae34fd78a28b63afacbecf3\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"acd6d2895e6e958fb965a5336be57d0500f87681f-e677ab5c3cc74afc9241c48c349ad77d\",            \"pageNumber\":\"16\",            \"pageTitle\":\"Exhibit 15\",            \"pageURL\":\"OPS/s9ml/chapter02/reader_1.xhtml#e677ab5c3cc74afc9241c48c349ad77d\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"e677ab5c3cc74afc9241c48c349ad77d\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"af948e5136526bb4bb61f037dc0eda2ee7240a675-b03a7dc1464c42509fb18851fe5fa3f4\",            \"pageNumber\":\"17\",            \"pageTitle\":\"2.6 Examples\",            \"pageURL\":\"OPS/s9ml/chapter02/2_6_examples.xhtml#b03a7dc1464c42509fb18851fe5fa3f4\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"b03a7dc1464c42509fb18851fe5fa3f4\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"ab1456f0c13cc5c1bb57f2ec285d9c6f03e8fbaac-ed6eb7153d374d31868313979c65a077\",            \"pageNumber\":\"18\",            \"pageTitle\":\"2.6 Preliminary Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_6_preliminary_problems.xhtml#ed6eb7153d374d31868313979c65a077\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"ed6eb7153d374d31868313979c65a077\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a125244ba85e2a95058602794e4b835f2a2788de8-a6c7134c31a94ff2b5f646a523860226\",            \"pageNumber\":\"19\",            \"pageTitle\":\"2.6 Fundamental Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_6_fundamental_problems.xhtml#a6c7134c31a94ff2b5f646a523860226\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"a6c7134c31a94ff2b5f646a523860226\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a42e49182f5fb2b0588a47abad48c46cdaabf8785-e3cdc170518b4da88f18aa81d75a305b\",            \"pageNumber\":\"20\",            \"pageTitle\":\"2.6 Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_6_problems.xhtml#e3cdc170518b4da88f18aa81d75a305b\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"e3cdc170518b4da88f18aa81d75a305b\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"ab4cb2942a59493bdece5fee4972e8cceb0b3df19-aad4016db1c442e786c414f3bc8d8f0f\",            \"pageNumber\":\"21\",            \"pageTitle\":\"2.7 Position Vectors\",            \"pageURL\":\"OPS/s9ml/chapter02/filep7000495165000000000000000000537.xhtml#aad4016db1c442e786c414f3bc8d8f0f\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"aad4016db1c442e786c414f3bc8d8f0f\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"adfdb10b4bda331e68b30ce597fa2a6d2109ff6d2-db56381ba48a4b6b87876b1a80369db8\",            \"pageNumber\":\"22\",            \"pageTitle\":\"2.7 Examples\",            \"pageURL\":\"OPS/s9ml/chapter02/2_7_examples.xhtml#db56381ba48a4b6b87876b1a80369db8\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"db56381ba48a4b6b87876b1a80369db8\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"af3e232e80e1ec01aade40905a6f8dfffda3f9ce4-aad4016db1c442e786c414f3bc8d8f0f\",            \"pageNumber\":\"23\",            \"pageTitle\":\"2.8 Force Vector Directed Along a Line\",            \"pageURL\":\"OPS/s9ml/chapter02/2_8_force_vector_directed_along_a_line.xhtml#aad4016db1c442e786c414f3bc8d8f0f\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"aad4016db1c442e786c414f3bc8d8f0f\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"ad5b79cd31c0d1d27460a5d40390a96c13b1764bf-e29d3e7a7f1144659e6692fd9232e5cd\",            \"pageNumber\":\"24\",            \"pageTitle\":\"2.8 Examples\",            \"pageURL\":\"OPS/s9ml/chapter02/2_8_examples.xhtml#e29d3e7a7f1144659e6692fd9232e5cd\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"e29d3e7a7f1144659e6692fd9232e5cd\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a0639f7695b2c88edb5252b32525e4de93c2fc5a8-d6690abca122485eb37dad9497963c35\",            \"pageNumber\":\"25\",            \"pageTitle\":\"2.8 Preliminary Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_8_preliminary_problems.xhtml#d6690abca122485eb37dad9497963c35\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"d6690abca122485eb37dad9497963c35\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a1e8203ad54d75c23ba06be389f355c84bdf58af1-ed76c04691544c35aaf16a8374db02e7\",            \"pageNumber\":\"26\",            \"pageTitle\":\"2.8 Fundamental Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_8_fundamental_problems.xhtml#ed76c04691544c35aaf16a8374db02e7\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"ed76c04691544c35aaf16a8374db02e7\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a66a3aff2c56d75d30e8eda6d81f7fd9cf08c313c-d213f28a2aa9435abc7df3ec3e50e1ba\",            \"pageNumber\":\"27\",            \"pageTitle\":\"2.8 Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/2_8_problems.xhtml#d213f28a2aa9435abc7df3ec3e50e1ba\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"d213f28a2aa9435abc7df3ec3e50e1ba\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a953b103680f5b9e1c7eb0d8b2ac3acdfe2a64cda-cb2f2f2473da4c15aae371485a7c3fef\",            \"pageNumber\":\"28\",            \"pageTitle\":\"Chapter Review\",            \"pageURL\":\"OPS/s9ml/chapter02/filep700049516500000000000000000087f.xhtml#cb2f2f2473da4c15aae371485a7c3fef\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"cb2f2f2473da4c15aae371485a7c3fef\"         },         {            \"isChildren\":\"0\",            \"isDownloaded\":\"0\",            \"pageId\":\"a925f2482929fec8c68935c3cdb00d499972310bf-fa6015a93581481c97dcca13f9e1ed7a\",            \"pageNumber\":\"29\",            \"pageTitle\":\"Review Problems\",            \"pageURL\":\"OPS/s9ml/chapter02/filep70004951650000000000000000008d1.xhtml#fa6015a93581481c97dcca13f9e1ed7a\",            \"parentId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",            \"urlTag\":\"fa6015a93581481c97dcca13f9e1ed7a\"         }      ],      \"isChildren\":\"1\",      \"isDownloaded\":\"0\",      \"pageId\":\"ad8f3730ec53b95c94b8795e1a9851c283bde4dfe\",      \"pageNumber\":\"1\",      \"pageTitle\":\"Chapter 2: Force Vectors\",      \"pageURL\":\"OPS/s9ml/chapter02/filep7000495165000000000000000000005.xhtml\",      \"parentId\":\"root\",      \"urlTag\":\"#\"   }]";

    NSError *error;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    _rawDataSource = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
}

-(void)resetButtons:(UITableViewCell*)cell{
    
    for(int i=1;i<8;i++)
        [((Etext2CustomEditUIButton*)[cell viewWithTag:i]) setUpButtonUnSelectedStyle];
    
}

-(NSDate*)formateDate:(NSString*)dateString{
    
    NSRange tRange = [dateString rangeOfString:@"T"];
    NSString *subDate = [dateString substringToIndex:tRange.location];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:subDate ];
    
    return date;
    
}

-(void)openItems:(UIButton*)sender{
    
    NSInteger section = sender.tag;
    NSInteger rowCount = [_tableView numberOfRowsInSection:section];
    NSMutableArray *indexPaths = [NSMutableArray new];
    
    while (rowCount>0) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:rowCount inSection:section]];
        rowCount--;
    }

    
    [_tableView beginUpdates];
//    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    
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
        //scroll to top
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _keyboardIsShown = YES;
        [_tableView scrollToRowAtIndexPath:_indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
