//
//  QZViewController.m
//  HookMutableDictionary
//
//  Created by caomeili on 07/25/2017.
//  Copyright (c) 2017 caomeili. All rights reserved.
//

#import "QZViewController.h"
#import <HookMutableDictionary/NSMutableDictionary+HookC.h>
#import <HookMutableDictionary/MutableDictionaryObserver.h>

@interface QZViewController ()

@end

@implementation QZViewController

- (void)viewDidLoad
{
    MutableDictionaryObserver *observer = [[MutableDictionaryObserver alloc] init];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjects:@[@"1",@"2",@"3"] forKeys:@[@"a",@"b",@"c"]];
    
    observer.setObject = ^(NSMutableDictionary *dictionary, id object, id key) {
        NSLog(@"%@ %@  %@",object,key,dictionary);
        
    };
    observer.removeObjects = ^(NSMutableDictionary *dictionary, NSArray<id> *keys) {
        NSLog(@"%@ %@ ",dictionary,keys);
        
    };
    
    observer.setDictionary = ^(NSMutableDictionary *dictionary) {
        NSLog(@"%@",dictionary);
    };
    [dic addObserver:observer];
    
    [dic setObject:@"4" forKey:@"d"];
    [dic setObject:@"5" forKeyedSubscript:@"d"];
    [dic setValue:@"6" forKey:@"b"];
    [dic addEntriesFromDictionary:@{@"object":@"key"}];
    
    [dic removeObjectForKey:@"a"];
    [dic removeObjectsForKeys:@[@"c",@"b"]];
    [dic setDictionary:@{@"o":@"b"}];
    [dic removeAllObjects];

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
