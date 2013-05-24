//
//  KPWorldStatusViewController.m
//  GW2API
//
//  Created by daniel wartnaby on 24/05/2013.
//  Copyright (c) 2013 Knowledge Is Porridge. All rights reserved.
//

#import "KPWorldStatusViewController.h"

@interface KPWorldStatusViewController ()

@end

@implementation KPWorldStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Status";
    
    [activityIndicatorView_ startAnimating];
    
    worldCountLabel_.text = [NSString stringWithFormat:@"%d", [[GW2World worlds] count]];
    
    
    // Let's get our data. There are several options. We're getting 'everything' to show how the API works, but
    // ultimately in a real app you'd concern yourself with a subset of data.
    // For the sake of this demo though, let's stick to getting everything. You have two main approaches;
    //   - You can ask the API for everything, and the entire dataset will be loaded in ONE operation.
    //   - You can ask the API for each part in turn, and you'll respond to several operations.
    //
    // Why use one over the other? Getting everything in one operation is simpler, but, while the requests are running
    // your application will need to wait. If you request each part you can respond to each dataset as it's being returned.
    // Below is an example on how to fetch each collection of data seperately. You'll notice when you run the app
    // the UI is updated as each dataset is returned by the API. Below this code is a commented example of how to
    // fetch everything in one operation...
    
    // We'll start with events. We already have worlds.
    [DurmandPriory fetchCollection:GW2APIDomainCollectionWorldVsWorld
                   completionBlock:^(GW2APIDomainCollection collection) {
                       
                       // Now that we have events let's get the previously selected world (you can get this, ultimately, from anywhere you've chosen to hold a reference to a world).
                       GW2World * activeWorld = [GW2World worldById:[DurmandPriory requestParameter:kGW2APIRequestParameterWorldID]];
                       [DurmandPriory fetch:activeWorld.matchup completionBlock:^(id domain) {
                           
                           // We have our world vs world matchup information!
                           wvw_redScoreLabel_.text   = [NSString stringWithFormat:@"%d", activeWorld.matchup.totalScores.red];
                           wvw_greenScoreLabel_.text = [NSString stringWithFormat:@"%d", activeWorld.matchup.totalScores.green];
                           wvw_blueScoreLabel_.text  = [NSString stringWithFormat:@"%d", activeWorld.matchup.totalScores.blue];
                           
                           wvw_redNameLabel_.text    = activeWorld.matchup.redWorld.name;
                           wvw_greenNameLabel_.text  = activeWorld.matchup.greenWorld.name;
                           wvw_blueNameLabel_.text   = activeWorld.matchup.blueWorld.name;
                       }];
                   
                       // Let's also grab events. All requests are ASYNCHRONOUS, meaning that while the API is fetching WvW information you can also ask it to fetch other stuff.
                       [DurmandPriory fetchCollection:GW2APIDomainCollectionEvents
                                      completionBlock:^(GW2APIDomainCollection collection) {
                                          
                                          // We have events, which will also ensure maps are available.
                                          eventCountLabel_.text = [NSString stringWithFormat:@"%d",
                                                                   [[GW2Event events] count]];
                                          mapCountLabel_.text = [NSString stringWithFormat:@"%d",
                                                                   [[GW2Map maps] count]];
                                          
                       }];
                       
                       // And let's grab some items, which we'll need in order to fetch recipes.
                       [DurmandPriory fetchCollection:GW2APIDomainCollectionItems
                                      completionBlock:^(GW2APIDomainCollection collection) {
                           
                                          itemCountLabel_.text = [NSString stringWithFormat:@"%d",
                                                                   [[GW2Item items] count]];
                                          
                                          // .. and now for recipes.
                                          [DurmandPriory fetchCollection:GW2APIDomainCollectionRecipes
                                                         completionBlock:^(GW2APIDomainCollection collection) {
                                                             
                                                             recipeCountLabel_.text = [NSString stringWithFormat:@"%d",
                                                                                      [[GW2Recipe recipes] count]];
                                                             
                                                             [activityIndicatorView_ stopAnimating];
                                                         }];
                       }];
                   }];
    
    
    // Get everything in one step;
    /*
     [DurmandPriory fetchCollection:GW2APIDomainCollectionEverything
     completionBlock:^(GW2APIDomainCollection collection) {
     
     GW2World * activeWorld = [GW2World worldById:[DurmandPriory requestParameter:kGW2APIRequestParameterWorldID]];
     wvw_redScoreLabel_.text   = [NSString stringWithFormat:@"%d", activeWorld.matchup.totalScores.red];
     wvw_greenScoreLabel_.text = [NSString stringWithFormat:@"%d", activeWorld.matchup.totalScores.green];
     wvw_blueScoreLabel_.text  = [NSString stringWithFormat:@"%d", activeWorld.matchup.totalScores.blue];
     
     wvw_redNameLabel_.text   = activeWorld.matchup.redWorld.name;
     wvw_greenNameLabel_.text = activeWorld.matchup.greenWorld.name;
     wvw_blueNameLabel_.text  = activeWorld.matchup.blueWorld.name;
     
     eventCountLabel_.text  = [NSString stringWithFormat:@"%d", [[GW2Event events] count]];
     mapCountLabel_.text    = [NSString stringWithFormat:@"%d", [[GW2Map maps] count]];
     itemCountLabel_.text   = [NSString stringWithFormat:@"%d", [[GW2Item items] count]];
     recipeCountLabel_.text = [NSString stringWithFormat:@"%d", [[GW2Recipe recipes] count]];
     
     [activityIndicatorView_ stopAnimating];
     }];
     */
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
