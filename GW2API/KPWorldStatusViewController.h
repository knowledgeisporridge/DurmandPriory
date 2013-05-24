//
//  KPWorldStatusViewController.h
//  GW2API
//
//  Created by daniel wartnaby on 24/05/2013.
//  Copyright (c) 2013 Knowledge Is Porridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DurmandPriory.h"


@interface KPWorldStatusViewController : UIViewController {
    
@protected
    IBOutlet UIActivityIndicatorView * activityIndicatorView_;
    
    IBOutlet UILabel * eventCountLabel_;
    IBOutlet UILabel * itemCountLabel_;
    IBOutlet UILabel * recipeCountLabel_;
    IBOutlet UILabel * worldCountLabel_;
    IBOutlet UILabel * mapCountLabel_;
    
    IBOutlet UILabel * wvw_redScoreLabel_;
    IBOutlet UILabel * wvw_greenScoreLabel_;
    IBOutlet UILabel * wvw_blueScoreLabel_;
    
    IBOutlet UILabel * wvw_redNameLabel_;
    IBOutlet UILabel * wvw_greenNameLabel_;
    IBOutlet UILabel * wvw_blueNameLabel_;
}

@end
