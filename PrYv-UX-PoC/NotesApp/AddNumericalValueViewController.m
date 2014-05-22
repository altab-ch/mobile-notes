//
//  AddNumericalValueViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/19/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "AddNumericalValueViewController.h"
#import <PryvApiKit/PYMeasurementSet.h>
#import <PryvApiKit/PYEventTypes.h>
#import <PryvApiKit/PYMeasurementTypesGroup.h>
#import "MeasurementController.h"
#import "PhotoNoteViewController.h"
#import "KSAdvancedPicker.h"
#import "UserHistoryEntry.h"
#import "CellStyleModel.h"
#import "AddNumericalValueCellFormat.h"
#import "AddNumericalValueCellClass.h"

#define kSaveMeasurementSegue @"SaveMeasurementSegue_ID"
#define kGroupComponentIndex 0
#define kTypeComponentIndex 1
#define kGroupComponentProportionalWidth 0.5
#define kGroupComponentHeight 77

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface AddNumericalValueViewController () <KSAdvancedPickerDataSource, KSAdvancedPickerDelegate>

@property (nonatomic, strong) IBOutlet CustomNumericalKeyboard *customKeyborad;
@property (nonatomic, strong) NSMutableArray *measurementGroups;
@property (nonatomic, strong) IBOutlet UITextField *typeTextField;
@property (nonatomic, strong) IBOutlet KSAdvancedPicker *typePicker;

- (void)updateView:(UIImageView*)view forRow:(NSInteger)row;
- (void)selectFirstTypeAnimated:(BOOL)animated;
- (NSNumber*)valueAsNumber;
- (void)updateMeasurementSets;
- (void)selectRightMeasurementGroupForMeasurementClassKey:(NSString*)classKey andMeasurementType:(NSString*)measurementType;

@end

@implementation AddNumericalValueViewController

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
    [self textFieldValueChangedForCustomNumericalKeyboard:_customKeyborad];
    self.typePicker.delegate = self;
    self.typePicker.dataSource = self;
    [self.typePicker reloadData];
    UIButton *delBtn = (UIButton*)[self.customKeyborad viewWithTag:11];
    [delBtn setTitle:@"\u232B" forState:UIControlStateNormal];
    self.navigationItem.title = NSLocalizedString(@"AddNumericalViewController.Title", nil);
    if (IS_IPHONE_5){
        [self.typeTextField setFont:[UIFont fontWithName:@"Helvetica Neue" size:40.0]];
        [self.valueField setFont:[UIFont fontWithName:@"Helvetica Neue" size:46.0]];
    }else{
        [self.typeTextField setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
        [self.valueField setFont:[UIFont fontWithName:@"Helvetica Neue" size:28.0]];
    }
    self.valueField.text = @"";
    
    [self updateMeasurementSets];
    [self.typePicker reloadData];
    [self selectRightMeasurementGroupForMeasurementClassKey:self.valueClass andMeasurementType:self.valueType];
    if(self.value)
    {
        self.valueField.text = self.value;
        self.typeTextField.text = self.valueType;
    }
}

- (void)updateMeasurementSets
{
    if(self.measurementGroups)
    {
        [self.measurementGroups removeAllObjects];
    }
    else
    {
        self.measurementGroups = [NSMutableArray array];
    }
    NSArray *measurementSets = [[MeasurementController sharedInstance] userSelectedMeasurementSets];
    NSArray *availableSets = [[PYEventTypes sharedInstance] measurementSets];
    
    
    NSMutableDictionary* tempDictionary = [[NSMutableDictionary alloc] init];
    
    
    
    for(NSString *setKey in measurementSets) // for each set choosen by the user
    {
        for(PYMeasurementSet *set in availableSets) // for each available set
        {
            if([[set key] isEqualToString:setKey]) // found set in available set
            {
                // --- for each event group put them in a new PYGroup
                for (int i = 0; i < set.measurementGroups.count ; i++) {
                    PYMeasurementTypesGroup *pyGroupSrc = [set.measurementGroups objectAtIndex:i];
                    
                    if (! pyGroupSrc.classKey) { continue; } // should not happend
                    
                    PYMeasurementTypesGroup *pyGroupDest = [tempDictionary objectForKey:pyGroupSrc.classKey];
                    if (! pyGroupDest) {
                        pyGroupDest = [[PYMeasurementTypesGroup alloc] initWithClassKey:pyGroupSrc.classKey
                                                                 andListOfFormats:pyGroupSrc.formatKeyList
                                                                 andPYEventsTypes:nil];
                        [tempDictionary setObject:pyGroupDest forKey:pyGroupSrc.classKey];
                    } else {
                    // merge
                        [pyGroupDest addFormats:pyGroupSrc.formatKeyList withClassKey:pyGroupSrc.classKey];
                    }
                    [pyGroupDest sortUsingLocalizedName];
                }
                
            }
        }
    }
    
    
   
    [_measurementGroups addObjectsFromArray:[tempDictionary allValues]];
    
    // order
    [_measurementGroups sortUsingComparator:^NSComparisonResult(id a, id b) {
        return [[(PYMeasurementTypesGroup*)a localizedName] caseInsensitiveCompare:[(PYMeasurementTypesGroup*)b localizedName]];
    }];
    
}

- (void)selectRightMeasurementGroupForMeasurementClassKey:(NSString *)classKey andMeasurementType:(NSString *)measurementType
{
    __block BOOL typeIsFound = NO;
    [self.measurementGroups enumerateObjectsUsingBlock:^(PYMeasurementTypesGroup *mGroup, NSUInteger idx1, BOOL *stop1) {
        if([mGroup.classKey isEqualToString:classKey])
        {
            [self.typePicker selectRow:[self.measurementGroups indexOfObject:mGroup] inComponent:0 animated:NO];
            [mGroup.formatKeys enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx2, BOOL *stop2) {
                if([type isEqualToString:measurementType])
                {
                    [self.typePicker selectRow:[mGroup.formatKeys indexOfObject:type] inComponent:1 animated:NO];
                    typeIsFound = YES;
                    *stop2 = YES;
                }
            }];
        }
        if(typeIsFound)
        {
            *stop1 = YES;
        }
    }];
    if(!typeIsFound && classKey && measurementType)
    {
        self.typePicker.hidden = YES;
    }
}

- (void)selectFirstTypeAnimated:(BOOL)animated
{
    [_typePicker selectRow:0 inComponent:1 animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateView:(UIImageView *)view forRow:(NSInteger)row
{
    PYMeasurementTypesGroup *group = [_measurementGroups objectAtIndex:row];
    [view setImage:[UIImage imageNamed:[group classKey]]];
}

- (NSNumber*)valueAsNumber
{
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setMaximumFractionDigits:2000];
    NSNumber *number = [nf numberFromString:_valueField.text];
    return number;
}

#pragma mark - CustomNumericalKeyboardDelegate

- (UITextField*)textFieldForCustomkeyboard:(CustomNumericalKeyboard *)customKeybord
{
    return _valueField;
}

- (void)textFieldValueChangedForCustomNumericalKeyboard:(CustomNumericalKeyboard *)customKeyboard
{
//    _doneButton.enabled = _valueField.text.length > 0;
}

#pragma mark - Segues

- (IBAction)doneButtonTouched:(id)sender
{
    if([[_valueField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 1)
    {
        _valueField.text = @"0";
    }
    NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
    NSInteger selectedType = [_typePicker selectedRowInComponent:1];
    PYMeasurementTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
    NSString *formatKey = [group.formatKeys objectAtIndex:selectedType];
    if(self.valueDidChangeBlock)
    {
        if(self.typePicker.hidden)
        {
            self.valueDidChangeBlock(self.valueClass,self.valueType,_valueField.text,self);
        }
        else
        {
            self.valueDidChangeBlock([group classKey],formatKey,_valueField.text,self);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KSAdvancedPickerDataSource and KSAdvancedDelegate methods

- (NSInteger) numberOfComponentsInAdvancedPicker:(KSAdvancedPicker *)picker
{
    return 2;
}

- (NSInteger) advancedPicker:(KSAdvancedPicker *)picker numberOfRowsInComponent:(NSInteger)component
{
    if(component == kGroupComponentIndex)
    {
        return [_measurementGroups count];
    }
    NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
    return [[[_measurementGroups objectAtIndex:selectedGroup] formatKeys] count];
}

- (UIView *) advancedPicker:(KSAdvancedPicker *)picker viewForComponent:(NSInteger)component inRect:(CGRect)rect
{
    if(component == kGroupComponentIndex)
    {
        AddNumericalValueCellClass *cell = [[AddNumericalValueCellClass alloc] initWithFrame:rect];
        return cell ;
    }
    
    AddNumericalValueCellFormat *cell = [[AddNumericalValueCellFormat alloc] initWithFrame:rect];
    return cell;
    
}

- (void) advancedPicker:(KSAdvancedPicker *)picker setDataForView:(UIView *)view row:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == kGroupComponentIndex)
    {
        //UILabel *label = (UILabel*)view;
        UILabel *label = [(AddNumericalValueCellClass*)view classLabel];
        
        PYMeasurementTypesGroup *group = [_measurementGroups objectAtIndex:row];
        [label setText:group.localizedName];
    }
    else
    {
        NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
        PYMeasurementTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
        
        PYEventType *pyType = [group pyTypeAtIndex:(int)row];
        NSString *symbolText = pyType.type;
        
        NSString *nameText = @"";
        if (pyType && pyType.localizedName) {
            nameText = pyType.localizedName;
        }
        if (pyType && pyType.symbol) {
            symbolText = pyType.symbol;
        }
        
        AddNumericalValueCellFormat *cell = (AddNumericalValueCellFormat*)view;
        [cell.nameLabel setText:nameText];
        [cell.symbolLabel setText:symbolText];
    }
}

- (CGFloat)heightForRowInAdvancedPicker:(KSAdvancedPicker *)picker
{
    return kGroupComponentHeight;
}

- (CGFloat) advancedPicker:(KSAdvancedPicker *)picker widthForComponent:(NSInteger)component
{
    CGFloat width = picker.frame.size.width;
    if(component == kGroupComponentIndex)
    {
        return width * kGroupComponentProportionalWidth;
    }
    //return width * (1 - kGroupComponentProportionalWidth);
    // TODO Fix.. there is a problem with the width of 2nd column component
    return 320;
}

- (void) advancedPicker:(KSAdvancedPicker *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        [self.typePicker reloadDataInComponent:1];
//        [self selectFirstTypeAnimated:YES];
    }
    else if(component == 1)
    {
        NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
        PYMeasurementTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
        PYEventType *pyType = [group pyTypeAtIndex:row];
        NSString *descLabel = pyType.key;
        if (pyType && pyType.symbol) {
            descLabel = pyType.symbol;
        }

        [_typeTextField setText:descLabel];
    }
}

- (UIColor *) backgroundColorForAdvancedPicker:(KSAdvancedPicker *)picker
{
    return [UIColor clearColor];
}

- (UIColor *) advancedPicker:(KSAdvancedPicker *)picker backgroundColorForComponent:(NSInteger)component
{
    return [UIColor clearColor];
}

- (UIColor *) overlayColorForAdvancedPickerSelector:(KSAdvancedPicker *)picker
{
    return [UIColor clearColor];
}

- (UIColor *) viewColorForAdvancedPickerSelector:(KSAdvancedPicker *)picker
{
    return [UIColor clearColor];
}

- (void)setupCustomCancelButton
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle: NSLocalizedString(@"Cancel", nil)
                                     style: UIBarButtonItemStyleBordered
                                     target:self action: @selector(cancelButtonTouched:)];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:cancelButton];
}

- (void)cancelButtonTouched:(id)sender
{
    UIViewController *vcToPop = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers indexOfObject:self] - 2];
    [self.navigationController popToViewController:vcToPop animated:YES];
}

@end
