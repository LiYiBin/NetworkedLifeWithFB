//
//  Cell.h
//  naivegrid
//
//  Created by Apirom Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoPhotograph.h"

@interface Cell : UITableViewCell {
    BOOL ischeck;
}

@property (nonatomic, retain) IBOutlet MoPhotograph *image;
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *subtitle;


-(void)setEditMode;
-(void)setNormalMode;

- (void) setChecked:(BOOL)checked;


@end