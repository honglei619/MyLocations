//
//  CategoryPickerViewController.m
//  MyLocations
//
//  Created by Lei on 15/5/26.
//  Copyright (c) 2015年 honglei. All rights reserved.
//

#import "CategoryPickerViewController.h"

@implementation CategoryPickerViewController{
    NSArray *_categories;
    NSIndexPath *_selectedIndexPath;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    _categories = @[@"No Category",
                    @"Apple Store",
                    @"Bar",
                    @"Book Store",
                    @"Grocery Store",
                    @"Historic Building",
                    @"House",
                    @"Icecream Vendor",
                    @"Landmark",
                    @"Park",
                    ];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_categories count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSString *categoryName = _categories[indexPath.row];
    cell.textLabel.text = categoryName;
    if([categoryName isEqualToString:self.selectedCategoryName]){ cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row != _selectedIndexPath.row){
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath]; newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_selectedIndexPath]; oldCell.accessoryType = UITableViewCellAccessoryNone;
        _selectedIndexPath = indexPath;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"PickedCategory"]){ UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell]; self.selectedCategoryName = _categories[indexPath.row];
    }
    
}

@end
