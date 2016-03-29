//
//  LMMainViewController.m
//  LMComBoxView
//
//  Created by qsy on 14-8-15.
//  Copyright (c) 2014年 qsy. All rights reserved.
//

 

#import "LMMainViewController.h"
#import "LMContainsLMComboxScrollView.h"

#define kDropDownListTag 1000

@interface LMMainViewController ()
{
    LMContainsLMComboxScrollView *bgScrollView;
    NSMutableDictionary *addressDict;   //地址选择字典
    NSArray *areaTotalArray;//总的数组
    NSArray *province;
    NSArray *city;
    NSArray *district;
    
    NSDictionary *proviceCode;
    NSDictionary *cityCode;
    NSDictionary *districtsCode;
    
// 获取到该省行对应的城市的所有数据（包括区）
    NSArray *cityArray;
    
    NSString *selectedProvince;
    NSString *selectedCity;
    NSString *selectedArea;
}
@end

@implementation LMMainViewController

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
    // Do any additional setup after loading the view.
    
    //解析全国省市区信息
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"region" ofType:@"plist"];
    areaTotalArray =[[NSArray alloc] initWithContentsOfFile:plistPath];
    
#pragma mark  获取省
    NSMutableArray  *proviceNameArray = [[NSMutableArray alloc]init];
    NSMutableDictionary  *proviceCodeDic = [[NSMutableDictionary alloc]init];
    
    for (NSDictionary *dic in areaTotalArray) {
        [proviceNameArray addObject:dic[@"provinceName"]];
        [proviceCodeDic setObject:dic[@"provincCode"] forKey:[NSString stringWithFormat:@"provice%@",dic[@"provinceName"]]];
    }
    province = [[NSArray alloc] initWithArray:proviceNameArray];
    proviceCode = [[NSDictionary alloc] initWithDictionary:proviceCodeDic];
#pragma mark 获取市
    
    NSMutableArray  *cityNameArray = [[NSMutableArray alloc]init];
    NSMutableDictionary  *cityCodeDic = [[NSMutableDictionary alloc]init];
    NSDictionary *dic1 = areaTotalArray[0];
    for (NSDictionary *dic2 in dic1[@"citys"]) {
        [cityNameArray addObject:dic2[@"cityName"]];
        [cityCodeDic setObject:dic2[@"cityCode"] forKey:[NSString stringWithFormat:@"city%@",dic2[@"cityName"]]];
        
    }
    NSArray *tempArray = dic1[@"citys"];
    NSMutableArray *cityMutableArray = tempArray.mutableCopy;
    cityArray = [[NSArray alloc] initWithArray:cityMutableArray];
    city = [[NSArray alloc] initWithArray:cityNameArray];
    cityCode = [[NSDictionary alloc] initWithDictionary:cityCodeDic];
#pragma mark 获取区
    NSMutableArray  *districtsNameArray = [[NSMutableArray alloc]init];
    NSMutableDictionary  *districtsCodeDic = [[NSMutableDictionary alloc]init];
    NSDictionary *dic3 = areaTotalArray[0][@"citys"][0];
    for (NSDictionary *dic4 in dic3[@"cityRegion"]) {
        [districtsNameArray addObject:dic4[@"regionName"]];
        [districtsCodeDic setObject:dic4[@"regionCode"] forKey:[NSString stringWithFormat:@"district%@",dic4[@"regionName"]]];
        
    }
    
    district = [[NSArray alloc] initWithArray:districtsNameArray];;
    districtsCode = [[NSDictionary alloc] initWithDictionary:districtsCodeDic];

//    将省市区加到字典中
    addressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   province,@"province",
                   city,@"city",
                   district,@"area",nil];
    
    selectedProvince = [province objectAtIndex:0];
    selectedCity = [city objectAtIndex:0];
    selectedArea = [district objectAtIndex:0];
    
    
    bgScrollView = [[LMContainsLMComboxScrollView alloc]initWithFrame:CGRectMake(0, 20,  [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height -20)];
    bgScrollView.backgroundColor = [UIColor cyanColor];
    bgScrollView.showsVerticalScrollIndicator = NO;
    bgScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:bgScrollView];
    
    [self setUpBgScrollView];
}

-(void)setUpBgScrollView
{
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 21)];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"选择省市区";
    [bgScrollView addSubview:titleLable];
    
    NSArray *keys = [NSArray arrayWithObjects:@"province",@"city",@"area", nil];
    for(NSInteger i=0;i<3;i++)
    {
        LMComBoxView *comBox = [[LMComBoxView alloc]initWithFrame:CGRectMake(50+(63+3)*i, 55, 63, 24)];
        comBox.backgroundColor = [UIColor whiteColor];
        comBox.arrowImgName = @"down_dark0.png";
        NSMutableArray *itemsArray = [NSMutableArray arrayWithArray:[addressDict objectForKey:[keys objectAtIndex:i]]];
        comBox.titlesList = itemsArray;
        comBox.delegate = self;
        comBox.supView = bgScrollView;
        [comBox defaultSettings];
        comBox.tag = kDropDownListTag + i;
        [bgScrollView addSubview:comBox];
    }
}

#pragma mark -LMComBoxViewDelegate
-(void)selectAtIndex:(int)index inCombox:(LMComBoxView *)_combox
{
    NSInteger tag = _combox.tag - kDropDownListTag;
    switch (tag) {
        case 0:
        {
            selectedProvince =  [[addressDict objectForKey:@"province"]objectAtIndex:index];
            NSArray *cityTempArray = areaTotalArray[index][@"citys"];
            NSMutableArray *cityMutableArray = cityTempArray.mutableCopy;
            cityArray = [[NSArray alloc]initWithArray:cityMutableArray];
            //       获取到该省行对应的城市的所有数据（包括区）
            NSMutableArray  *cityNameArray = [[NSMutableArray alloc]init];
            NSMutableDictionary  *cityCodeDic = [[NSMutableDictionary alloc]init];
            NSDictionary *dic1 =areaTotalArray[index];
            for (NSDictionary *dic2 in dic1[@"citys"]) {
                [cityNameArray addObject:dic2[@"cityName"]];
                [cityCodeDic setObject:dic2[@"cityCode"] forKey:[NSString stringWithFormat:@"city%@",dic2[@"cityName"]]];
            }
            city = [[NSArray alloc] initWithArray:cityNameArray];
            cityCode = [[NSDictionary alloc] initWithDictionary:cityCodeDic];
            
//    移除之前地区的数据内容:根据市来调动对应的地区
            NSMutableArray  *districtsNameArray = [[NSMutableArray alloc]init];
            NSMutableDictionary  *districtsCodeDic = [[NSMutableDictionary alloc]init];
            NSDictionary *dic3 = areaTotalArray[index][@"citys"][0];
            for (NSDictionary *dic4 in dic3[@"cityRegion"]) {
                [districtsNameArray addObject:dic4[@"regionName"]];
                [districtsCodeDic setObject:dic4[@"regionCode"] forKey:[NSString stringWithFormat:@"district%@",dic4[@"regionName"]]];
                
            }
            district = [[NSArray alloc] initWithArray:districtsNameArray];;
            districtsCode = [[NSDictionary alloc] initWithDictionary:districtsCodeDic];

            //刷新市、区
            addressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           province,@"province",
                           city,@"city",
                           district,@"area",nil];
            LMComBoxView *cityCombox = (LMComBoxView *)[bgScrollView viewWithTag:tag + 1 + kDropDownListTag];
            cityCombox.titlesList = [NSMutableArray arrayWithArray:[addressDict objectForKey:@"city"]];
            [cityCombox reloadData];
            LMComBoxView *areaCombox = (LMComBoxView *)[bgScrollView viewWithTag:tag + 2 + kDropDownListTag];
            areaCombox.titlesList = [NSMutableArray arrayWithArray:[addressDict objectForKey:@"area"]];
            [areaCombox reloadData];

            selectedCity = [city objectAtIndex:0];
            selectedArea = [district objectAtIndex:0];
            break;
        }
        case 1:
        {
            selectedCity = [[addressDict objectForKey:@"city"]objectAtIndex:index];
            //    获取到选择哪行的市
            NSMutableArray  *districtsNameArray = [[NSMutableArray alloc]init];
            NSMutableDictionary  *districtsCodeDic = [[NSMutableDictionary alloc]init];
            NSDictionary *dic3 = cityArray[index];
            for (NSDictionary *dic4 in dic3[@"cityRegion"]) {
                [districtsNameArray addObject:dic4[@"regionName"]];
                [districtsCodeDic setObject:dic4[@"regionCode"] forKey:[NSString stringWithFormat:@"district%@",dic4[@"regionName"]]];
                
            }
            district = [[NSArray alloc] initWithArray:districtsNameArray];;
            districtsCode = [[NSDictionary alloc] initWithDictionary:districtsCodeDic];
            //刷新区
            addressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           province,@"province",
                           city,@"city",
                           district,@"area",nil];
            LMComBoxView *areaCombox = (LMComBoxView *)[bgScrollView viewWithTag:tag + 1 + kDropDownListTag];
            areaCombox.titlesList = [NSMutableArray arrayWithArray:[addressDict objectForKey:@"area"]];
            [areaCombox reloadData];
            
            selectedArea = [district objectAtIndex:0];
            break;
        }
        case 2:
        {
            selectedArea = [[addressDict objectForKey:@"area"]objectAtIndex:index];
            break;
        }
        default:
            break;
    }
    NSLog(@"===%@===%@===%@",selectedProvince,selectedCity,selectedArea);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
