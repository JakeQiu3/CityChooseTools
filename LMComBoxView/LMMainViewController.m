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
    NSArray *province;//默认的省数组
    NSArray *city;
    NSArray *district;
    
    NSDictionary *proviceCode;
    NSDictionary *cityCode;
    NSDictionary *districtsCode;
//    获取到默认的省对应的市数组
    NSArray *defaultCitysNameArray;
//    NSArray *defaultCityRegionArray;
    NSArray *defaultRegionsNameArray;
//    默认省市区的3个序号
    int provinceNum;
    int cityNum;
    int districtNum;
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
    
    district = [[NSArray alloc] initWithArray:districtsNameArray];
    districtsCode = [[NSDictionary alloc] initWithDictionary:districtsCodeDic];

//  将省市区加到字典中
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
    
    //    设置默认的序号
    provinceNum = 3;
    cityNum = 3;
    districtNum = 3;
    
    for(NSInteger i=0;i<3;i++)
    {
        LMComBoxView *comBox = [[LMComBoxView alloc]initWithFrame:CGRectMake(50+(63+3)*i, 55, 63, 24)];
        comBox.backgroundColor = [UIColor whiteColor];
        comBox.arrowImgName = @"down_dark0.png";
        NSMutableArray *itemsArray = [NSMutableArray arrayWithArray:[addressDict objectForKey:[keys objectAtIndex:i]]];
        comBox.titlesList = itemsArray;
        comBox.delegate = self;
        comBox.supView = bgScrollView;
        comBox.tag = kDropDownListTag + i;
        [comBox defaultSettings];
        [bgScrollView addSubview:comBox];
    }
      NSLog(@"===%@===%@===%@",selectedProvince,selectedCity,selectedArea);
}

#pragma mark -LMComBoxViewDelegate 设置默认的数据：indexNum为所在tableview数据源的序号
- (void)setDefaultCityNum:(int)indexNum inCombox:(LMComBoxView *)_combox {
    NSInteger tag = _combox.tag -kDropDownListTag;
    switch (tag) {//设置默认省
        case 0:
//    获取到省的数据源province和该省对应的位置index
            indexNum = provinceNum;
            _combox.titleLabel.text = [province objectAtIndex:indexNum];
            selectedProvince =_combox.titleLabel.text;
            break;
        case 1://设置市
//    获取省对应市的数据源和对应的index
            indexNum = cityNum;
            [self getDefaultCitysArray:indexNum];
            //刷新区
            _combox.titlesList = [[NSArray alloc]initWithArray:defaultCitysNameArray].mutableCopy;
            NSLog(@"city---------%@",city);
            [_combox reloadData];
             _combox.titleLabel.text = [defaultCitysNameArray objectAtIndex:indexNum];
             selectedCity = _combox.titleLabel.text;
            [self modifyCityArray];
            [addressDict setObject:_combox.titlesList forKey:@"city"];
            break;
        case 2://设置区
//            获取市对应区的数据源和对应的index
            indexNum = districtNum;
            [self getDefaultRegionsArray:indexNum];
            _combox.titlesList = [[NSArray alloc]initWithArray:defaultRegionsNameArray].mutableCopy;
            [_combox reloadData];
            _combox.titleLabel.text = [defaultRegionsNameArray objectAtIndex:indexNum];
             selectedArea = _combox.titleLabel.text;
            [addressDict setObject:_combox.titlesList forKey:@"area"];
            NSLog(@"region---------%@",[addressDict objectForKey:@"area"]);
            break;
        default:
            break;
    }
}

- (void)modifyCityArray{
    NSDictionary *proviceDic = areaTotalArray[provinceNum];
    NSArray *tempArray = proviceDic[@"citys"];
    cityArray = [[NSArray alloc] initWithArray:tempArray];
    NSLog(@"city:---------%@",cityArray);
    
}

- (void )getDefaultCitysArray:(int)indexNum {
    NSDictionary *cityTempDic = [areaTotalArray objectAtIndex:provinceNum];
    NSArray *citysArray =cityTempDic[@"citys"];
    NSMutableArray *cityNameArray = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in citysArray) {
        [cityNameArray addObject:dic[@"cityName"]];
        
    }
    defaultCitysNameArray = [[NSArray alloc]initWithArray:cityNameArray];
}

- (void )getDefaultRegionsArray:(int)indexNum {
    NSDictionary *cityTempDic = [areaTotalArray objectAtIndex:provinceNum];
    NSArray *citysArray =cityTempDic[@"citys"];
    NSDictionary *rempArr = [citysArray objectAtIndex:cityNum];
    NSArray *regionArray = rempArr[@"cityRegion"];
    NSMutableArray *regionNameArray = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in regionArray) {
        [regionNameArray addObject:dic[@"regionName"]];
    }
    defaultRegionsNameArray = [[NSArray alloc]initWithArray:regionNameArray];
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



@end
