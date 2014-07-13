//
//  UnitPickerViewController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 10.07.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "UnitPickerViewController.h"
#import "MeasurementSettingsViewController.h"
#import "KSAdvancedPicker.h"
#import "MeasurementController.h"
#import <PryvApiKit/PYMeasurementSet.h>
#import <PryvApiKit/PYEventTypes.h>
#import <PryvApiKit/PYMeasurementTypesGroup.h>
#import "AddNumericalValueCellClass.h"
#import "AddNumericalValueCellFormat.h"

#define kUnitToMeasureSegue_ID @"kUnitToMeasureSegue_ID"
#define kGroupComponentIndex 0
#define kTypeComponentIndex 1
#define kGroupComponentProportionalWidth 0.5
#define kGroupComponentHeight 77

@interface UnitPickerViewController () <KSAdvancedPickerDataSource, KSAdvancedPickerDelegate, MeasuresDelegate>

@property (nonatomic, weak) MeasurementSettingsViewController* measuresViewController;
@property (nonatomic, weak) IBOutlet KSAdvancedPicker* unitPicker;
@property (nonatomic, strong) NSMutableArray *measurementGroups;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* top;
@property (nonatomic) BOOL isMeasureSetShow;
@end

@implementation UnitPickerViewController

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
    _isMeasureSetShow = false;
    [self updateMeasurementSets];
    [_unitPicker setDelegate:self];
    [_unitPicker setDataSource:self];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction, segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kUnitToMeasureSegue_ID]) {
        MeasurementSettingsViewController *measures = [segue destinationViewController];
        _measuresViewController = measures;
        [measures setChangeValueDelegate:self];
    }
}

-(IBAction)btShowMeasureSetPressed:(id)sender
{
    if (_isMeasureSetShow) {
        [self animateConstraint:92];
        [self animateMeasureSet:0];
        _isMeasureSetShow = false;
    }else{
        [self animateConstraint:0];
        [self animateMeasureSet:1];
        _isMeasureSetShow = true;
    }
}

-(void) animateMeasureSet:(CGFloat)alpha
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [_measuresViewController.tableView setAlpha:alpha];
    [UIView commitAnimations];
}

-(void) animateConstraint:(CGFloat)constant
{
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4
                     animations:^{
                         _top.constant = constant;
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
}

-(IBAction)btDonePressed:(id)sender
{
    NSInteger selectedGroup = [_unitPicker selectedRowInComponent:0];
    PYMeasurementTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
    PYEventType *pyType = [group pyTypeAtIndex:[_unitPicker selectedRowInComponent:1]];
    self.event.type = pyType.key;
    [self.delegate unitPickerController:self didFinishPickingUnit:_event];
}

#pragma mark - MeasuresDelegate

- (void)measuresViewControllerDidChangeSets
{
    [self updateMeasurementSets];
    [_unitPicker reloadData];
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
    NSInteger selectedGroup = [_unitPicker selectedRowInComponent:0];
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
    [cell setBackgroundColor:[UIColor clearColor]];
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
        NSInteger selectedGroup = [_unitPicker selectedRowInComponent:0];
        PYMeasurementTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
        
        PYEventType *pyType = [group pyTypeAtIndex:(int)row];
        NSString *symbolText = pyType.type;
        
        NSString *nameText = @"";
        
        if (pyType) {
            if (! pyType.symbol) {
                symbolText = pyType.localizedName;
                nameText = @"";
            } else {
                symbolText = pyType.symbol;
                nameText = pyType.localizedName;
            }
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
        [self.unitPicker reloadDataInComponent:1];
        //        [self selectFirstTypeAnimated:YES];
    }
    else if(component == 1)
    {
        NSInteger selectedGroup = [_unitPicker selectedRowInComponent:0];
        PYMeasurementTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
        PYEventType *pyType = [group pyTypeAtIndex:(int)row];
        NSString *descLabel = pyType.key;
        if (pyType && pyType.symbol) {
            descLabel = pyType.symbol;
        }
        
        //[_typeTextField setText:descLabel];
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

#pragma mark - Utils

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


@end
