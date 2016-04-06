//
//  LMComBoxView.h
//  ComboBox
//
//  Created by qsy on 14-7-9.
//  Copyright (c) 2014年 Eric Che. All rights reserved.
//  实现下拉框ComBox

 

#import <UIKit/UIKit.h>
#define imgW 10
#define imgH 10
#define tableH 150
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define kBorderColor [UIColor colorWithRed:219/255.0 green:217/255.0 blue:216/255.0 alpha:1]
#define kTextColor   [UIColor darkGrayColor]

@class LMComBoxView;
@protocol LMComBoxViewDelegate <NSObject>
//选择单个tableView的cell
-(void)selectAtIndex:(int)index inCombox:(LMComBoxView *)_combox;
//设置默认的省、市和区
- (void)setDefaultCityNum:(int)indexNum inCombox:(LMComBoxView *)_combox;


@end

@interface LMComBoxView : UIView<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,assign)BOOL isOpen;
@property(nonatomic,strong)UITableView *listTable;
@property(nonatomic,strong)NSMutableArray *titlesList;
@property(nonatomic,assign)int defaultIndex;
@property(nonatomic,assign)float tableHeight;
@property(nonatomic,strong)UIImageView *arrow;
@property(nonatomic,copy)NSString *arrowImgName;//箭头图标名称
@property(nonatomic,assign)id<LMComBoxViewDelegate>delegate;
@property(nonatomic,strong)UIView *supView;
@property (nonatomic, strong) UILabel *titleLabel;

-(void)defaultSettings;
-(void)reloadData;
-(void)closeOtherCombox;
-(void)tapAction;

@end


/*
    注意：
    1.单元格默认跟控件本身的高度一致
 */