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

#define topConstraintConstant ((IS_IPHONE_5) ? 86.0 : 60.0)

@interface UnitPickerViewController () <KSAdvancedPickerDataSource, KSAdvancedPickerDelegate, MeasuresDelegate>

@property (nonatomic, weak) MeasurementSettingsViewController* measuresViewController;
@property (nonatomic, weak) IBOutlet KSAdvancedPicker* unitPicker;
@property (nonatomic, strong) NSMutableArray *measurementGroups;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* top;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btNext;
@property (nonatomic, weak) IBOutlet UIButton *btShowMeasure;
@property (nonatomic, weak) IBOutlet UILabel *lbManageUnits;
@property (nonatomic, weak) IBOutlet UILabel *lbPickUnit;

@property (nonatomic) BOOL isMeasureSetShow;
@end

@implementation UnitPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.lbManageUnits setText:NSLocalizedString(@"UnitPicker.Manage", nil)];
    [self.lbPickUnit setText:NSLocalizedString(@"UnitPicker.Select", nil)];
    self.top.constant = topConstraintConstant;
    self.isMeasureSetShow = false;
    [self.btNext setTitle:NSLocalizedString(@"UnitPicker.Next", nil)];
    [self updateMeasurementSets];
    [self.unitPicker setDelegate:self];
    [self.unitPicker setDataSource:self];
    [self.btShowMeasure.imageView setTransform:CGAffineTransformMakeRotation(M_PI)];
}

-(void) viewDidAppear:(BOOL)animated
{
    for (int i=0; i<[self.measurementGroups count]; i++) {
        PYMeasurementTypesGroup *mes = [self.measurementGroups objectAtIndex:i];
        if ([mes.name isEqualToString:@"mass"]){
            [self.unitPicker selectRow:i inComponent:0 animated:NO];
            for (int j=0; j<[mes.formatKeyList count]; j++) {
                if ([[mes.formatKeyList objectAtIndex:j] isEqualToString:@"kg"] ||
                     [[mes.formatKeyList objectAtIndex:j] isEqualToString:@"lb"]) {
                    [self.unitPicker selectRow:j inComponent:1 animated:NO];
                    return;
                }
            }
        }
            
    }
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
        
        self.measuresViewController = [segue destinationViewController];
        [self.measuresViewController setChangeValueDelegate:self];
    }
}

-(IBAction)btShowMeasureSetPressed:(id)sender
{
    if (self.isMeasureSetShow) {
        [self.btShowMeasure.imageView setTransform:CGAffineTransformMakeRotation(M_PI)];
        [self animateConstraint:topConstraintConstant];
        [self animateMeasureSet:0];
        self.isMeasureSetShow = false;
    }else{
        [self.btShowMeasure.imageView setTransform:CGAffineTransformIdentity];
        [self animateConstraint:0];
        [self animateMeasureSet:1];
        self.isMeasureSetShow = true;
    }
}

-(void) animateMeasureSet:(CGFloat)alpha
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [self.measuresViewController.tableView setAlpha:alpha];
    [UIView commitAnimations];
}

-(void) animateConstraint:(CGFloat)constant
{
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.top.constant = constant;
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
}

-(IBAction)btDonePressed:(id)sender
{
    NSInteger selectedGroup = [self.unitPicker selectedRowInComponent:0];
    PYMeasurementTypesGroup *group = [self.measurementGroups objectAtIndex:selectedGroup];
    PYEventType *pyType = [group pyTypeAtIndex:[self.unitPicker selectedRowInComponent:1]];
    self.event.type = pyType.key;
    [self.delegate unitPickerController:self didFinishPickingUnit:self.event];
}

#pragma mark - MeasuresDelegate

- (void)measuresViewControllerDidChangeSets
{
    NSInteger selectedGroup = [_unitPicker selectedRowInComponent:0];
    PYMeasurementTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
    PYEventType *type = [group pyTypeAtIndex:[self.unitPicker selectedRowInComponent:1]];
    [self updateMeasurementSets];
    NSInteger newGroupRow = [self getGroupRow:group];
    [self.unitPicker selectRow:newGroupRow inComponent:0 animated:NO];
    [self.unitPicker selectRow:[self getTypeRow:type forGroup:[self.measurementGroups objectAtIndex:newGroupRow]] inComponent:1 animated:NO];
    
    [self.unitPicker reloadData];
}

-(NSInteger) getGroupRow:(PYMeasurementTypesGroup*)group
{
    for (int i=0;i<[_measurementGroups count];i++)
        if ([[[self.measurementGroups objectAtIndex:i] classKey] isEqualToString:[group classKey]]) return i;

    return 0;
}

-(NSInteger) getTypeRow:(PYEventType*)type forGroup:(PYMeasurementTypesGroup*)group
{
    for (int i=0;i<[group.formatKeyList count];i++)
        if ([[type formatKey] isEqualToString:[[group pyTypeAtIndex:i] formatKey]]) return i;
    
    return 0;
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
        return [self.measurementGroups count];
    }
    NSInteger selectedGroup = [_unitPicker selectedRowInComponent:0];
    return [[[self.measurementGroups objectAtIndex:selectedGroup] formatKeys] count];
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
        
        PYMeasurementTypesGroup *group = [self.measurementGroups objectAtIndex:row];
        [label setText:group.localizedName];
    }
    else
    {
        NSInteger selectedGroup = [self.unitPicker selectedRowInComponent:0];
        PYMeasurementTypesGroup *group = [self.measurementGroups objectAtIndex:selectedGroup];
        
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
        [self.unitPicker selectRow:0 inComponent:1 animated:NO];
    }
    else if(component == 1)
    {
        NSInteger selectedGroup = [self.unitPicker selectedRowInComponent:0];
        PYMeasurementTypesGroup *group = [self.measurementGroups objectAtIndex:selectedGroup];
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
    return [UIColor whiteColor];
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
