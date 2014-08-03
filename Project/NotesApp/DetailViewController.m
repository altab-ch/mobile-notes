//
//  DetailViewController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 03.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DetailViewController.h"
#import "NoteDetailCell.h"
#import "NumericDetailCell.h"
#import "PhotoDetailCell.h"
#import "StreamDetailCell.h"
#import "DatePickerDetailCell.h"
#import "DateDetailCell.h"
#import "EndDateDetailCell.h"
#import "TagsDetailCell.h"
#import "DescriptionDetailCell.h"
#import "DeleteDetailCell.h"

#import "PYEvent+Helper.h"

#define kStreamCellHeight 54
#define kDeleteCellHeight 50
#define kDateCellHeight 66
#define kValueCellHeight 90
#define kImageCellHeight 320
#define kNoteTextViewWidth 297

typedef enum
{
    DetailCellTypeEvent,
    DetailCellTypeStreams,
    DetailCellTypeTime,
    DetailCellTypeTimeEnd,
    DetailCellTypeTags,
    DetailCellTypeDescription,
    DetailCellTypeDelete
    
} DetailCellType;

@interface DetailViewController ()

@property (nonatomic) BOOL isEdit;
@property (nonatomic) BOOL isDatePicker;
@property (nonatomic) BOOL isEndDatePicker;
@property (nonatomic) BOOL shouldUpdateEvent;
@property (nonatomic, strong) NSDictionary* initialEventValue;

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isEdit = _event.isDraft;
    _initialEventValue = [self.event cachingDictionary];
    _isDatePicker = false;
    _isEndDatePicker = false;
    UINib *nib = [UINib nibWithNibName:@"NoteDetailCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"NoteDetailCell_ID"];
    nib = [UINib nibWithNibName:@"NumericDetailCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"NumericDetailCell_ID"];
    nib = [UINib nibWithNibName:@"PhotoDetailCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"PhotoDetailCell_ID"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 1;
    if (section==DetailCellTypeTime) {
        if (_isDatePicker)
            numberOfRows=2;
        else
            numberOfRows=1;
    }
    if (section==DetailCellTypeTimeEnd) {
        if (_isEndDatePicker)
            numberOfRows=2;
        else
            numberOfRows=1;
    }
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
            
        case DetailCellTypeEvent:
        {
            EventDataType type = [_event eventDataType];
            switch (type) {
                case EventDataTypeImage:
                {
                    PhotoDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoDetailCell_ID"];
                    [cell updateWithEvent:_event];
                    return cell;
                }
                    break;
                    
                case EventDataTypeValueMeasure:
                {
                    NumericDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NumericDetailCell_ID"];
                    [cell updateWithEvent:_event];
                    return cell;
                }
                    break;
                    
                case EventDataTypeNote:
                {
                    NoteDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteDetailCell_ID"];
                    [cell updateWithEvent:_event];
                    return cell;
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
            
        case DetailCellTypeStreams:
        {
            StreamDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StreamDetailCell_ID"];
            [cell updateWithEvent:_event];
            return cell;
        }
            break;
            
        case DetailCellTypeTime:
        {
            if (indexPath.row==0) {
                DateDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateDetailCell_ID"];
                [cell updateWithEvent:_event];
                return cell;
            }else if (indexPath.row==1){
                DatePickerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DatePickerDetailCell_ID"];
                [cell updateWithEvent:_event];
                return cell;
            }
            
        }
            break;
            
        case DetailCellTypeTimeEnd:
        {
            if (indexPath.row==0) {
                EndDateDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateEndDetailCell_ID"];
                [cell updateWithEvent:_event];
                return cell;
            }else if (indexPath.row==1){
                DatePickerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DatePickerDetailCell_ID"];
                [cell updateWithEvent:_event];
                return cell;
            }
            
        }
            break;
            
        case DetailCellTypeTags:
        {
            TagsDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TagsDetailCell_ID"];
            [cell updateWithEvent:_event];
            return cell;
        }
            break;
            
        case DetailCellTypeDescription:
        {
            DescriptionDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DescriptionDetailCell_ID"];
            [cell updateWithEvent:_event];
            return cell;
        }
            break;
            
        case DetailCellTypeDelete:
        {
            DeleteDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteDetailCell_ID"];
            [cell updateWithEvent:_event];
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
