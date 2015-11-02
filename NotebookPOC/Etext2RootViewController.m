//
//  ViewController.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/21/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2RootViewController.h"
#import "Etext2NoteBookViewController.h"

@interface Etext2RootViewController ()


@property (weak, nonatomic) IBOutlet UIView *noteListView;


@end

@implementation Etext2RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}
- (IBAction)showNotesList:(id)sender {
    Etext2NoteBookViewController *noteController = (Etext2NoteBookViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"notebook_view_controller"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
