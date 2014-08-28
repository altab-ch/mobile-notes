//
//  DetailCellDelegate.h
//  NotesApp
//
//  Created by Mathieu Knecht on 14.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DetailCellDelegate <NSObject>

-(void) detailShouldUpdateEvent;
-(void) closePickers:(BOOL)forceUpdateUI;
-(void) updateEndDateCell;

@end
