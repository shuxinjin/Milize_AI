
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 28 23:04:58 2018

@author: shuxin.jin@hotmail.com
"""

import pandas as pd
import numpy as np
from sklearn.cluster import KMeans

#import matplotlib.pyplot as plt
import os,sys
from sklearn.model_selection import train_test_split 
from sklearn.preprocessing import StandardScaler
from django.db.backends.dummy.base import ignore
#from sklearn.ensemble import RandomForestClassifier
#from sklearn.preprocessing import Imputer
#import seaborn as sns
#import random


curPath = os.path.abspath(os.path.dirname(__file__))
rootPath = os.path.split(curPath)[0]
sys.path.append(rootPath)
sys.path.append(curPath)


#1.1 comprehensive strength process 
#add 2 columns fields with name  ROA  ROE
def Comprehensive(df):
    #1.1.1  formula process ,ROE   ???????
    df.eval('ROE = EQUITY_TO_ASSET_RATIO', inplace=True)

    #1.1.2  formula process ,ROA
    df.eval('ROA = COMPREHENSIVE_INCOME/TOTAL_ASSETS' , inplace=True)
    #'TOTAL_ASSETS',  'OPERATINGINCOME', 'EQUITY_TO_ASSET_RATIO', 'NET_ASSETS' ,'COMPREHENSIVE_INCOME'
    return df

#1.2 process , Profitability,add 1.2.1   1.2.2  1.2.3   1.2.4
def Profitability(df):
    #1.2.1 
        
    df.eval('R_GP_NS121 = GROSSPROFIT/NETSALES'   , inplace=True)
    
    #1.2.2   
    df.eval('R_OP_NS122 = OPERATINGINCOME/NETSALES'  , inplace=True)
    #(GROSSPROFIT-PROFIT_LOSS)
    #1.2.3  ????
    df.eval('R_OP_NS123 = (COMPREHENSIVE_INCOME -ORDINARY_INCOME_LOSS)/NETSALES'   , inplace=True)
    
    #1.2.4  ????
    df.eval('R_RP_NS124 = ( NETSALES- COSTOFSALES)/NETSALES'  , inplace=True)

    #1.2.4
    return df

#1.3 process 
def FinancialSolvency(df):
    #1.3.1 
    df.eval('Current_R131 = CURRENT_ASSETS/CURRENT_LIABILITIES' , inplace=True)
    
    #1.3.2   ???
    df.eval('Acid_test_R132 =CASHANDDEPOSITS/CURRENT_LIABILITIES' , inplace=True)
    #NON_CURRENT_LIABILITIES
    #1.3.3  
    df.eval('R_owner_equity133 = SHAREHOLDERSEQUITY /TOTAL_ASSETS' , inplace=True)
    
    #1.3.4  ????
    df.eval('Fixed_R134 = (TOTAL_ASSETS-CURRENT_ASSETS)/SHAREHOLDERSEQUITY ' , inplace=True)
   
    #1.3.5  ????
    df.eval('R_fixAsset_Lgterm135 = (TOTAL_ASSETS - NON_CURRENT_ASSETS)/(SHAREHOLDERSEQUITY+( LIABILITIES-CURRENT_LIABILITIES) )' , inplace=True)
 
    return df



#1.4 process 
def Efficiency(df):
    #1.4.1 
    df.eval('Ttl_asset_tnOver141 = NETSALES/TOTAL_ASSETS' , inplace=True)
    #1.4.2  
    df.eval('Rcv_tnOver142 = NETSALES/NOTESANDACCOUNTSRECEIVABLETRADE' , inplace=True)
    #1.4.3 
    df.eval('Invent_tnOver143 = COSTOFSALES/(MERCHANDISEANDFINISHEDGOODS + WORKINPROCESS + RAWMATERIALSANDSUPPLIES)' , inplace=True)
    #1.4.4  ????
    df.eval('Ttl_pay_tnOver_Period144 = COSTOFSALES/SHORTTERMLOANSPAYABLE' , inplace=True)
    #LONGTERMACCOUNTSPAYABLEOTHER
    return df


#1.5 Growth 
def Growth(df):
 
    star_date =None
    s_code = None
    star_date1=None
    s_code1 = None    
    
    NETSALES= None  
    ORDINARYINCOME= None  
    TOTAL_ASSETS= None  
  
    NETSALES1= None  
    ORDINARYINCOME1= None  
    TOTAL_ASSETS1= None  

    NETSALES2= None  
    ORDINARYINCOME2= None  
    TOTAL_ASSETS2= None  

    df.eval('R_rd_exp_sale154 = NONOPERATINGEXPENSES/NETSALES ' , inplace=True)
    
    #create 3 new columns
    col_name = df.columns.tolist()
    col_name.insert(col_name.index('R_rd_exp_sale154'),'Sale_growth_R151')# before 5_4 insert
    col_name.insert(col_name.index('R_rd_exp_sale154'),'Ord_profit_gwth_R152')# before 5_4 insert
    col_name.insert(col_name.index('R_rd_exp_sale154'),'Ttl_asset_gwth_R153')# before 5_4 insert
    df.reindex(columns=col_name)
    
    nums = len(df)
    #outer loop ,avoid error , no need process the last row
    for i in range(0,nums-2 ):
        star_date= df.iloc[i]['SETTLE_DATE_S']
        s_code = df.iloc[i]['STOCK_CODE']
        NETSALES   = df.iloc[i]['NETSALES']
        ORDINARYINCOME = df.iloc[i]['ORDINARYINCOME']  
        TOTAL_ASSETS=  df.iloc[i]['TOTAL_ASSETS']  

        if ( df.iloc[i]['QUATER'] =='Current' ):
            #print("record Current value of growth of A1_5_123,index of:"+str(i))
            #inner loop
            #for j in range(i+1,len(df) ): change the length  ,for saving
            if (i+50)>nums:
                jj =nums
            else:
                jj =i+50
            for j in range(i+1,jj ):
                if ( (df.iloc[j]['SETTLE_DATE_S'] == star_date) & (df.iloc[j]['QUATER'] =='Prior1') & (df.iloc[j]['STOCK_CODE'] == s_code ) ):  
                    star_date1 = df.iloc[j]['SETTLE_DATE_S']
                    s_code1    = df.iloc[j]['STOCK_CODE']
                    
                    NETSALES1             = df.iloc[j]['NETSALES']
                    ORDINARYINCOME1       = df.iloc[j]['ORDINARYINCOME']  
                    TOTAL_ASSETS1         = df.iloc[j]['TOTAL_ASSETS']  
             
                    df.iloc[i]['Sale_growth_R151'] = (NETSALES-NETSALES1 )/NETSALES
                    df.iloc[i]['Ord_profit_gwth_R152'] = ( ORDINARYINCOME - ORDINARYINCOME1 )/( ORDINARYINCOME1 )
                    df.iloc[i]['Ttl_asset_gwth_R153'] = (TOTAL_ASSETS -TOTAL_ASSETS1)/(TOTAL_ASSETS1 )
                    #print("find prior1 value of growth of A1_5_123,index of:"+str(j) +str(df.iloc[j]['SETTLE_DATE_S'] ) + str(df.iloc[j]['QUATER'] ) + str(df.iloc[j]['STOCK_CODE']) )
                    #df1.loc[0,'age']=25
                    #for k in range( j+1,len(df) ): change the length  ,for saving
                    if (j+50)>nums:
                        kk =nums
                    else:
                        kk =j+50
                    for k in range( j+1,kk ):
                        if ( (df.iloc[k]['SETTLE_DATE_S'] == star_date1) & (df.iloc[k]['QUATER'] =='Prior2') & (df.iloc[k]['STOCK_CODE'] == s_code1 ) ):  
                            star_date2 = df.iloc[k]['SETTLE_DATE_S']
                            s_code2    = df.iloc[k]['STOCK_CODE']
                            
                            NETSALES2             = df.iloc[k]['NETSALES']
                            ORDINARYINCOME2       = df.iloc[k]['ORDINARYINCOME']  
                            TOTAL_ASSETS2         = df.iloc[k]['TOTAL_ASSETS']  
                     
                            df.iloc[j]['Sale_growth_R151'] = (NETSALES1-NETSALES2 )/NETSALES1
                            df.iloc[j]['Ord_profit_gwth_R152'] = ( ORDINARYINCOME1 - ORDINARYINCOME2 )/( ORDINARYINCOME2 )
                            df.iloc[j]['Ttl_asset_gwth_R153'] = (TOTAL_ASSETS1 -TOTAL_ASSETS2)/(TOTAL_ASSETS2 )
                            #print("find prior2 value of growth of A1_5_123,index of:"+str(k) + str(df.iloc[k]['SETTLE_DATE_S'] ) + str(df.iloc[k]['QUATER'] ) + str(df.iloc[k]['STOCK_CODE'])) 
                            #print("record i,i,k:"+str(i)+","+str(j)+","+str(k))
                            j= j+1
                    i=i+1
                    
#         if ( df.iloc[i]['QUATER'] =='Current' ): 
#             #1.5.1 
#             df.eval('A1_5_1 = (NETSALES[-1] -NETSALES[-2] )/NETSALES[-1]' , inplace=True)
#             #1.5.2  
#             df.eval('A1_5_2 = ( ORDINARYINCOME[-1] - ORDINARYINCOME[-2] )/( ORDINARYINCOME[-2] )' , inplace=True)
#             #1.5.3 
#             df.eval('A1_5_3 =  (TOTAL_ASSETS[-1] -TOTAL_ASSETS[-2])/(TOTAL_ASSETS[-2])' , inplace=True)
#             #1.5.4  ????
#             df.eval('A1_5_4 = NONOPERATINGEXPENSES/NETSALES ' , inplace=True)
    
    return df
    
    
#1.6 process 
def Other_lia(df):
    #1.6.1  ???  INTERESTEXPENSESNOE/100 is temple value.
    df.eval('Interest_cov_R161 = (OPERATINGINCOME + DIVIDENDSINCOMENOI)/(INTERESTEXPENSESNOE + INTERESTEXPENSESNOE/100 )' , inplace=True)
    #1.6.2  ??
    df.eval('Sale_C_TnOver_Prd162 = NOTESANDACCOUNTSRECEIVABLETRADE/(NETSALES/365)' , inplace=True)
    #1.6.3 
    #unique fetch ,  if ( df['QUATER'] =='Prior1' )
    df.eval('Invent_tnOver_Prd163 = (MERCHANDISEANDFINISHEDGOODS + WORKINPROCESS + RAWMATERIALSANDSUPPLIES)/(COSTOFSALES/12)' , inplace=True)

    #1.6.4  ???? be omited from the requirement.
#     df.eval('1_6_4 = ' , inplace=True)
    
    return df



###################

#****another no process function,just connect dataset****
def clean_ufile(in_target,fname,corr,unique_row=False):
    # define the remove features
    fn='data_cleaned4.csv'
    # define the features
    STATISTICS=        [ 'EDI_CODE','STOCK_CODE', 'COMPANY_NAME', 'QUATER','SETTLE_DATE_S','GROSSPROFIT','PROFIT_LOSS','SHAREHOLDERSEQUITY','NON_CURRENT_ASSETS',
                         'NETSALES', 'TOTAL_ASSETS',   'EQUITY_TO_ASSET_RATIO', 'NET_ASSETS' ,'COMPREHENSIVE_INCOME','OPERATINGINCOME','ORDINARYINCOME',
                         'CURRENT_ASSETS','CURRENT_LIABILITIES','LIABILITIES','NON_CURRENT_LIABILITIES','CASHANDDEPOSITS','CURRENTASSETS','SHORTTERMLOANSPAYABLE',
                         'NOTESANDACCOUNTSRECEIVABLETRADE','MERCHANDISEANDFINISHEDGOODS', 'WORKINPROCESS' ,'RAWMATERIALSANDSUPPLIES','COSTOFSALES','INTERESTEXPENSESNOE',
                         'LONGTERMACCOUNTSPAYABLEOTHER','DIVIDENDSINCOMENOI','INTERESTINCOMENOI','ORDINARY_INCOME_LOSS','NONOPERATINGEXPENSES'
                     ] 
    
    CORR_Features=['EDI_CODE','STOCK_CODE', 'COMPANY_NAME','QUATER','SETTLE_DATE_S']
    


    # load the file
    financeData = pd.read_csv(curPath+'\\'+ fname,  encoding='utf-8',  keep_default_na=False)
    
    #financeData = financeData.T.drop_duplicates().T
    
    # Check the initial shape of the data. The result is 2930 rows, 82 columns
    #print ('Initial shape of the financeData is', financeData.shape)
    
    #keep the simple columns,20190802
    financeData = financeData[ STATISTICS ]
    
    # Check duplicates row in dataframe. The result is we find no duplicates in the data row.
    financeData[financeData.duplicated(keep=False)]

    # Removing spaces from column names to have better access
    financeData.columns = financeData.columns.str.replace(' ',"")
    financeData.columns = financeData.columns.str.replace('/',"_")
    # Change the empty field into NAN
    financeData.replace(to_replace = "", value = np.NAN,inplace=True)


    # See how many values are empty in each column which has empty value (empty row)
    #financeData.loc[:,financeData.columns[financeData.isnull().sum() != 0]].isnull().sum().sort_values()
    
    # ## DATA CLEANING ##

    
    
    #add by jin##############################
    # Change the empty field into NAN
    financeData[financeData.duplicated(keep=False)]
    financeData.replace(to_replace = "", value = np.NAN,inplace=True)
    #amusing data , who is the original author of this data source ,fool talent!
    financeData.replace(to_replace = "NULL", value = np.NAN,inplace=True)
    
    #print "a纵向用缺失值上面的值替换缺失值"
    financeData.fillna(axis=0,method='ffill')
    #first time process still null , then try fill it with 0 
    financeData.fillna(0)
    ########################################

    # c. Convert Y target to boolean value
    ### financeData["Status"].replace({"underperform": 0, "outperform": 1}, inplace=True)
    #financeData["Status"].sample(10)

    # d. For the other categorical variables which is not ordinal values, we can drop it

    #should index first, then remove some columns
    financeData.reset_index(drop = True,inplace=True)
    #financeData[['Ticker', 'Date']].rename(columns={'Ticker':'Brands'})
    
    #print(financeData.columns)
    
    financeData.select_dtypes(exclude=[np.integer]).columns
   
    #clean the inf value
    pd.set_option('mode.use_inf_as_na', True)
    
    # We need to convert those variables to numeric
    cols1 =    [
       'GROSSPROFIT', 'PROFIT_LOSS', 'SHAREHOLDERSEQUITY',
       'NON_CURRENT_ASSETS', 'NETSALES', 'TOTAL_ASSETS',
       'EQUITY_TO_ASSET_RATIO', 'NET_ASSETS', 'COMPREHENSIVE_INCOME',
       'OPERATINGINCOME', 'CURRENT_ASSETS', 'CURRENT_LIABILITIES',
       'LIABILITIES', 'NON_CURRENT_LIABILITIES', 'CASHANDDEPOSITS',
       'CURRENTASSETS', 'SHORTTERMLOANSPAYABLE','ORDINARYINCOME',
       'NOTESANDACCOUNTSRECEIVABLETRADE', 'MERCHANDISEANDFINISHEDGOODS',
       'WORKINPROCESS', 'RAWMATERIALSANDSUPPLIES', 'COSTOFSALES',
       'INTERESTEXPENSESNOE', 'LONGTERMACCOUNTSPAYABLEOTHER',
       'DIVIDENDSINCOMENOI', 'INTERESTINCOMENOI', 'ORDINARY_INCOME_LOSS',
       'NONOPERATINGEXPENSES']
    
    for col in cols1:
        #print(col) 
        financeData[col] = pd.to_numeric(financeData[col])



    financeData=financeData.drop_duplicates(subset=None,keep='first',inplace=False)
    #1.1 comprehenasive strength data process
    #will add 2 fields of 1.1.1 and 1.1.2 with name ROE  ROA
    financeData = Comprehensive( financeData )
    #print(financeData.shape) 
    
    #1.2Profitability data process
    financeData = Profitability( financeData )
    #print(financeData.shape) 
    
    #1.3
    financeData = FinancialSolvency(financeData)
    #print(financeData.shape) 
       
    #1.4
    financeData = Efficiency(financeData)
    #print(financeData.shape) 
       
    #1.5
    financeData = Growth(financeData)
    #print(financeData.shape) 
    
    #1.6
    financeData = Other_lia(financeData)
#     print("financedata columns after formula: ") 
#     print( financeData.columns ) 
#     print( financeData.shape )  
#     print( financeData.sample(10) )  
    
    pd.DataFrame(financeData).to_csv(curPath+'\\' + fn)
    # ## Divide the financeData into trainset and testset, then normalize x_train an x_test by using StandardScaler


    tmpd2 = (financeData[CORR_Features]).copy()
    
    financeData.drop(CORR_Features, inplace=True, axis=1)
    
    #Divide data into training set and test set = 80 % : 20%
    trainset, testset = train_test_split(financeData, test_size=0.2)
    
    # Convert all columns with type integer (except EBITDA) to float 32 to save some memory.
    trainset = trainset.astype('float32')
    testset = testset.astype('float32')
        
    x_trainset = trainset.drop([ in_target ],axis=1)
    x_testset = testset.drop([ in_target ],axis=1)
    #will use this for sample data
#     new_columns= x_testset.columns
    scaler = StandardScaler()
    
    x_train = scaler.fit_transform(trainset.drop([ in_target ],axis=1).values)
    y_train = scaler.fit_transform(trainset[ in_target ].values.reshape(-1, 1))
    y_train = np.ravel(y_train)
    
    x_test = scaler.fit_transform(testset.drop([in_target],axis=1).values)
    y_test = scaler.fit_transform(testset[ in_target ].values.reshape(-1, 1))
    y_test = np.ravel(y_test)
    

  
    
    ##############    ##############    ##############
    # 1.concat predicts
    # 2.concat together
    # 3.violin chart
    # 4.give conclusion
    #Another classify method 2, not only consider the stock status
    # step 1, Connect the predicts data with the original data 
    # 2, cut the data
    # 3. output the violin chart, special color with the predict color
    # 4, filter ,and conclusion
    original_len = len(financeData)
    #print(original_len)

    #merge TICKER quater name  together, need different color  
    financeData = pd.concat( [ tmpd2 ,financeData ], axis=1, ignore_index=False)  
    
    financeData.reset_index(drop = True,inplace=True)
    merge_data= financeData
    #
    #print(merge_data.shape)
    
#     ############    ###########################################
#     numerical_features = ['EBITDA', 'EarningsGrowth', 'MarketCap',  
#    'Price_Book',  'ProfitMargin', 'ReturnonAssets',
#    'Revenue',  'ShortRatio', 
#    'TotalCash', 'TrailingP_E']
#     #sub plots numbers, fig size
#     nrow=2
#     ncol=5
#     fig, axs = plt.subplots(ncol, nrow, figsize=(20, 16))
#     
#     ii=0
#     jj=0
#     #print(merge_data.columns)
#     
#     for name, ax in zip(numerical_features, axs.flatten()):
#     
#         sns.regplot( merge_data[name][:original_len].values.reshape(-1, 1), merge_data[ in_target ][:original_len],ax=axs[ii,jj] )
# 
#         #show the last data with special color
#  
#         ax.set_title(name + ",Log Scale")
#         ii = ii + 1
#         #return to new column
#         if ii==ncol:
#             ii=0
#             jj=jj+1
#         #return to new row
#         if jj==nrow:
#             jj=0
#     
#     fig.tight_layout()
#     plt.style.use('bmh')    
#     plt.savefig(in_target+" data regression plot.png")
   
    
#     if unique_row ==True:
#         grpCls_by_fi = pd.DataFrame(columns = merge_data.columns)
#         #Fetch the only one row of one ticker and list it with dataframe
#         #Assume the last date is same.because hope will improve the basic data set,unique value
#         lst= list( set(merge_data['Ticker']))
#        
#         #print(merge_data.columns)
#         for tk in lst:
#             #print (str(tk))
#             #ddd= merge_data.loc[merge_data['column_name'].isin(some_values)]
#             ddd= merge_data.loc[merge_data['Ticker'] == tk]
#             #ddd= merge_data[ 'EBITDA' ].groupby( merge_data[ 'Ticker' ] )
#             
#             #ddd = ddd[ddd['Ticker'].isin([0.0])]
#             
#             #print(ddd)
#             grpCls_by_fi = grpCls_by_fi.append( ddd[-1:] , ignore_index=False)  #忽略索引,往dataframe中插入一行数据
#             #print(grpCls_by_fi)
#             #merge_data[merge_data['Ticker'].isin([tk])]
#     #            ind         = lst.index(stock)
#     #start_date =  data.iloc[-1:,[0] ].values
#     
#     #not filter to unique row data
#     else:
#         grpCls_by_fi = merge_data
# 
# 
#             
#     #filter only keep one last row
#     
#     
#     #outer one loop to create 30 data table
#     
#     #if only cluster ,why need the predict?  
#     
#     #should 2 charts , 1 is the windata and financedata kmean cluster   . 2 is the next windata and financedata kmean cluster chart.
#             
#     grpCls_by_fi1=grpCls_by_fi.copy()
#     #print( grpCls_by_fi )
#     grpCls_by_fi1.reset_index(drop = True,inplace=True)
    return  merge_data.reset_index(drop = True,inplace=True)


    
    
######
#kmeans cluster ,call the neibor  last   ,one file input
def in1file_km_cluster_nb(cols,fname,eva_lbl,corr,unique_row):
    grp_num = 18
    #*******************************#

    
    if ( os.path.isfile(curPath+'\\''data_cleaned4.csv') ):
        grpCls_by_fi = pd.read_csv(curPath+'\\''data_cleaned4.csv',  encoding='utf-8',  keep_default_na=False)
    else:
        grpCls_by_fi = clean_ufile(cols[0],fname,corr,False)
         
    #kmeans chart here
    #print(grpCls_by_fi.shape)
    #print(grpCls_by_fi.columns)
    
    #km = KMeans(n_clusters=9, n_jobs=-1, random_state = 42)
    #need clean again
    grpCls_by_fi.replace(to_replace = "", value = np.NAN,inplace=True)
    #amusing data , who is the original author of this data source ,fool talent!
    grpCls_by_fi.replace(to_replace = "NULL", value = np.NAN,inplace=True)
    #数据缺失的太过了，之间的关联关系已经不完整，如果简单的移除nan会导致没有多少数据留下。所以只能用清洗先看数据，如果系统需要，第一步是需要完善基础数据本身。
    #print "a纵向用缺失值上面的值替换缺失值"
    grpCls_by_fi.fillna(axis=0,method='ffill')
    grpCls_by_fi[ cols[0] ].fillna(0)
    grpCls_by_fi[ cols[1] ].fillna(0)
    grpCls_by_fi[ cols[2] ].fillna(0)
    grpCls_by_fi[ cols[3] ].fillna(0)
    
    
    grpCls_by_fi.drop(grpCls_by_fi[grpCls_by_fi[ cols[1] ] == float("inf")].index, inplace = True)
    grpCls_by_fi.drop(grpCls_by_fi[grpCls_by_fi[ cols[1] ] == float("-inf")].index, inplace = True)

    predict_null = pd.isnull(grpCls_by_fi[ cols[1] ])
#     data_null = grpCls_by_fi[predict_null == True]
    #print(data_null)

    #,target2,target3,target4
    # We need to convert those variables to numeric
    cols1 =    ['GROSSPROFIT', 'PROFIT_LOSS', 'SHAREHOLDERSEQUITY',
       'NON_CURRENT_ASSETS', 'NETSALES', 'TOTAL_ASSETS',
       'EQUITY_TO_ASSET_RATIO', 'NET_ASSETS', 'COMPREHENSIVE_INCOME',
       'OPERATINGINCOME', 'ORDINARYINCOME', 'CURRENT_ASSETS',
       'CURRENT_LIABILITIES', 'LIABILITIES', 'NON_CURRENT_LIABILITIES',
       'CASHANDDEPOSITS', 'CURRENTASSETS', 'SHORTTERMLOANSPAYABLE',
       'NOTESANDACCOUNTSRECEIVABLETRADE', 'MERCHANDISEANDFINISHEDGOODS',
       'WORKINPROCESS', 'RAWMATERIALSANDSUPPLIES', 'COSTOFSALES',
       'INTERESTEXPENSESNOE', 'LONGTERMACCOUNTSPAYABLEOTHER',
       'DIVIDENDSINCOMENOI', 'INTERESTINCOMENOI', 'ORDINARY_INCOME_LOSS',
       'NONOPERATINGEXPENSES', 'ROE', 'ROA', 'R_GP_NS121', 'R_OP_NS122',
       'R_OP_NS123', 'R_RP_NS124', 'Current_R131', 'Acid_test_R132',
       'R_owner_equity133', 'Fixed_R134', 'R_fixAsset_Lgterm135',
       'Ttl_asset_tnOver141', 'Rcv_tnOver142', 'Invent_tnOver143',
       'Ttl_pay_tnOver_Period144', 'R_rd_exp_sale154', 'Interest_cov_R161',
       'Sale_C_TnOver_Prd162'
       ]
    

    #need float convert again
    for col in cols1:
        grpCls_by_fi[col] = pd.to_numeric(grpCls_by_fi[col])

    #1, kmeans cluster
    km = KMeans(n_clusters= grp_num )
    
    km_pred = km.fit( grpCls_by_fi[[ cols[0] ]] )
    kmlabel= km_pred.labels_
    #print(km_pred)
    #print(km_pred.labels_)
    kmlabel = pd.DataFrame(kmlabel)
    kmlabel.columns =['km_cluster']
    #print(kmlabel)
    #concat the kmean label result with the original filter data set
    grpCls_by_fi = pd.concat( [ grpCls_by_fi , kmlabel ], axis=1, ignore_index=False)
    
    ##################################add the forest result
#     forestb=False
#     if forestb:

#         encoded = grpCls_by_fi[ cols[0] ]
#         #print(encoded )
#     #     le = LabelEncoder()
#     #     encoded = le.fit_transform(financeData[in_target] )
#         #convert algorithm, inner algorithm
#         splitx =  max( encoded )
#         
#     #     splits=[0,splitx//30, (2*splitx)//30 ,(3*splitx)//30,(4*splitx)//30,(5*splitx)//30,(6*splitx)//30,(7*splitx)//30,(8*splitx)//30,(9*splitx)//30,(10*splitx)//30,
#     #             (11*splitx)//30,(12*splitx)//30,(13*splitx)//30,(14*splitx)//30,(15*splitx)//30,(16*splitx)//30,(17*splitx)//30,(18*splitx)//30,(19*splitx)//30,(20*splitx)//30,
#     #             (21*splitx)//30,(22*splitx)//30,(23*splitx)//30,(24*splitx)//30,(25*splitx)//30,(26*splitx)//30,(27*splitx)//30,(28*splitx)//30,(29*splitx)//30,
#     #             (splitx+1)]
#     #     labelss=['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19','20','21', '22', '23', '24', '25', '26', '27', '28', '29','30']
#         splits=[0,splitx/9, (2*splitx)/9 ,(3*splitx)/9,(4*splitx)/9,(5*splitx)/9,(6*splitx)/9,(7*splitx)/9,(8*splitx)/9,(splitx+0.1)]
#         labelss=['1', '2', '3', '4', '5', '6', '7', '8', '9']
#         
#             
#         
#         encoded = pd.cut( encoded, splits,labelss)
#         
#         #xx=X['Market Cap']
#         #print(encoded)
#         encoded = np.asarray(encoded, dtype="|S6")
#         #encoded = le.fit_transform( encoded )  
#       
#         #print(encoded)
#         y = encoded
#     
#     
#     
#         XX=grpCls_by_fi[['GROSSPROFIT', 'PROFIT_LOSS', 'SHAREHOLDERSEQUITY',
#            'NON_CURRENT_ASSETS', 'NETSALES', 'TOTAL_ASSETS',
#            'EQUITY_TO_ASSET_RATIO', 'NET_ASSETS', 'COMPREHENSIVE_INCOME',
#            'OPERATINGINCOME', 'ORDINARYINCOME', 'CURRENT_ASSETS',
#            'CURRENT_LIABILITIES', 'LIABILITIES', 'NON_CURRENT_LIABILITIES',
#            'CASHANDDEPOSITS', 'CURRENTASSETS', 
#            'WORKINPROCESS', 'COSTOFSALES','ORDINARY_INCOME_LOSS'
#            ]]
#         
#         #PROCESS the nan null
#     
#         #imputer = Imputer(missing_values='Nan', strategy='mean')
#         imputer = Imputer(missing_values = 'NaN',strategy="most_frequent")
#         
#         imputer.fit(XX)
#         
#         XX = imputer.transform(XX)
#     
#         X_train, X_test, y_train, y_test = train_test_split(XX, y, test_size = 0.2, random_state = 0)
#     
#     
#         rf_classifier = RandomForestClassifier(n_estimators = 50, random_state = 0)
#         rf_classifier.fit(X_train, y_train)
#         xxx = rf_classifier.predict(XX)
#         xxx = pd.DataFrame(xxx)
#         xxx.columns =['forest_clu']
#         #print( 'forest cluster shape:' )
#         #print(xxx.shape)
#       
#         #end of forest
#         grpCls_by_fi = pd.concat( [ grpCls_by_fi , xxx ], axis=1, ignore_index=False)

    
    spect =False
    
    if spect:
        XX=grpCls_by_fi[['GROSSPROFIT', 'PROFIT_LOSS', 'SHAREHOLDERSEQUITY',
           'NON_CURRENT_ASSETS', 'NETSALES', 'TOTAL_ASSETS',
           'EQUITY_TO_ASSET_RATIO', 'NET_ASSETS', 'COMPREHENSIVE_INCOME',
           'OPERATINGINCOME', 'ORDINARYINCOME', 'CURRENT_ASSETS',
           'CURRENT_LIABILITIES', 'LIABILITIES', 'NON_CURRENT_LIABILITIES',
           'CASHANDDEPOSITS', 'CURRENTASSETS', 
           'WORKINPROCESS', 'COSTOFSALES','ORDINARY_INCOME_LOSS'
           ]]
        
        
        
        from sklearn.cluster import SpectralClustering
        SC = SpectralClustering(affinity='rbf', assign_labels='discretize', coef0=1,
                  degree=3, eigen_solver=None, eigen_tol=0.0, gamma=1.0,
                  kernel_params=None, n_clusters=3, n_init=10, n_jobs=None,
                  n_neighbors=10, random_state=0)
        Y_SC = SC.fit_predict( XX )
        
        Y_SC = pd.DataFrame(Y_SC)
        Y_SC.columns =['spec_clu']

        #end of forest
        grpCls_by_fi = pd.concat( [ grpCls_by_fi , Y_SC ], axis=1, ignore_index=False)
    
    
    
    
    #remove duplicated index column 0
    pd.DataFrame(grpCls_by_fi).to_csv(curPath+'\\' + 'data_cln_grp2.csv')
    #print(grpCls_by_fi.shape)
    
    # Visualize clusters predicted by KMeans
#     fig = plt.figure(figsize=(30,10))
#     sns.lmplot( cols[1], cols[0], data=grpCls_by_fi, hue='km_cluster', fit_reg=False, size=6,aspect=1.5, palette='husl');
# 
#     #sns.lmplot('ReturnonAssets', in_target, data=grpCls_by_fi[-2:-1], hue='km_cluster', fit_reg=False, size=6,aspect=1.5,markers="X", palette='husl');
#     plt.title('Financial indicator clustered into 9 groups');
#     
#     #plt.savefig( curPath+cols[0]+"_"+eva_lbl+"_noFltMulDataClu .png")
#     
#     
#     ##plot in 3D space
# 
#     fig = plt.figure()
#     ax = fig.add_subplot(111, projection = '3d')
#     ax.scatter( grpCls_by_fi[ cols[0] ], grpCls_by_fi[ cols[1] ], grpCls_by_fi[ cols[2] ], c = grpCls_by_fi['km_cluster'], marker = 'o', s=100)
#     ax.set_xlabel(cols[0])
#     ax.set_ylabel( cols[1] )
#     ax.set_zlabel( cols[2] )
#     plt.title(eva_lbl+"3D Plot");
    #plt.savefig(curPath+ cols[0] +"_"+eva_lbl+"_3D_Cluster.png")

    return cols[0] +"_"+eva_lbl+"_noFltMulDataClu.png",cols[0] +"_"+eva_lbl+"_3D_Cluster.png"
 

##############
def finder(radarData,ticker,dt_1 ):
    # 以后再加日期，比较烂的数据库
    indx = radarData.loc[( radarData['STOCK_CODE'].astype(float)==float(ticker) ) & (radarData['QUATER'].astype(str)=='Current') & ( radarData['SETTLE_DATE_S'].str.contains(dt_1) ) ]

    if indx.empty:
        return -1

    return indx.index[0]


##########
############
def lst_tbl(df,ticker,indx,cols,in_target,algo):
    #print(algo)
    #df = df.copy() 
    idx = df.loc[(df.index==indx)]
    if algo =='kmean':       
        idx =idx[['STOCK_CODE','km_cluster','SETTLE_DATE_S']]
        #to clear the warning
        ca= idx['km_cluster'].values
        cb= idx['SETTLE_DATE_S'].values
        #idx = np.array2string(np.array(idx).reshape(  (-1, 3 ) )    ,  separator=',' )
        # idx=df.loc[ indx,[ticker,'km_cluster','SETTLE_DATE_S'] ].values # idx=df.loc[ [indx],[ticker,'km_cluster','SETTLE_DATE_S'] ] #idx=df.loc[ [indx],[ticker,'km_cluster','SETTLE_DATE_S'] ]  #idx=df.loc[ indx,[ticker,'km_cluster','SETTLE_DATE_S'] ].copy() #idx=df.loc[ indx,[ticker,'km_cluster','SETTLE_DATE_S'] ].copy() #idx=df.loc[ indx,[ticker,'km_cluster','SETTLE_DATE_S'] ] #idx=df.loc[ indx,[ticker,'km_cluster','SETTLE_DATE_S'] ].values
        
        #tbl = df.loc[( df['km_cluster']==idx[1]) & (df['QUATER'].astype(str)=='Current')  & ( df['SETTLE_DATE_S']==idx[2])]
        tbl = df.loc[( df['km_cluster']==ca[0]) & (df['QUATER'].astype(str)=='Current')  & ( df['SETTLE_DATE_S']==cb[0])  ]
    else:

        idx =idx[['STOCK_CODE','forest_clu','SETTLE_DATE_S'] ]
        ca= idx['km_cluster'].values
        cb= idx['SETTLE_DATE_S'].values
        tbl = df.loc[( df['forest_clu']==ca[0]) & (df['QUATER'].astype(str)=='Current')  & ( df['SETTLE_DATE_S']==cb[0])]
    
    #select out put 
    tbl.groupby('SETTLE_DATE_S')[cols].mean().sort_values(by= in_target)
  
    tbl.fillna("")
    return tbl


    
###########
def radar_plot( fname,plotn,ticker,name1,cols,in_target,algo,dt_1,reg_create,his_col ):


    #print("root path 7r53:",(curPath))
    
    wh_f_col =['Ticker','Date','Comprehensive','Profitability','FinancialSolvency','Efficiency','Growth','Other']
    
    # load the file,englis
    radarData = pd.read_csv(curPath+'\\'+ fname     , encoding='utf-8')
    #japanese
    #radarData = pd.read_csv(curPath+'\\'+ fname     , encoding='shift_jis')
    
    #print(radarData.shape)
    
    #radarData['STOCK_CODE'] = radarData['STOCK_CODE'].round().astype('int64')
    #radarData['STOCK_CODE'] = radarData['STOCK_CODE'].mask(radarData['STOCK_CODE'].notnull(),radarData['STOCK_CODE'].round().astype('int64').values)
    #radarData['STOCK_CODE'] = radarData['STOCK_CODE'].round().astype('int64')
    #radarData['STOCK_CODE'] = radarData['STOCK_CODE'].mask(radarData['STOCK_CODE'].notnull(),radarData['STOCK_CODE'].values.round().astype(int) )
    
    #labels=np.array(['総合力','収益性','安全性','効率性','成長性','その他'])
    #print('fname:')
    #print( radarData['STOCK_CODE'].sample(5) )
    #labels=np.array(['Comprehensive','Profitability','FinancialSolvency','Efficiency','Growth','Other'])
#     labels=np.array(cols)
#     n = len(labels)
    #radarData = radarData.T.drop_duplicates().T
    indx=finder(radarData,ticker,dt_1 )
    if indx<0:
        return"",-1,None,None,None
    #print(indx)
    #print('asss')
    #print(labels)
    
    #show the row values of index row in radar result csv
#     stats=radarData.loc[indx,labels].values
    #print(stats)
#     
    
    # Removing spaces from column names to have better access
    radarData.columns = radarData.columns.str.replace(' ',"")
    radarData.columns = radarData.columns.str.replace('/',"_")
    # Change the empty field into NAN
    radarData.replace(to_replace = "", value = np.NAN,inplace=True)



    # See how many values are empty in each column which has empty value (empty row)
    radarData.loc[:,radarData.columns[radarData.isnull().sum() != 0]].isnull().sum().sort_values()
    

 
 

#     angles=np.linspace(0, 2*np.pi, len(labels), endpoint=False)
#     # close the plot
#     stats=np.concatenate((stats,[stats[0]]))
#     angles=np.concatenate((angles,[angles[0]]))
#     
#     
#     fig=plt.figure()
#     ax = fig.add_subplot(111, polar=True)
#     ax.plot(angles, stats, 'o-', linewidth=2,color ='firebrick' )
#     #ax.fill(angles, stats, alpha=0.25, color = 'greenyellow')
# 
#     # 自己画grid线（5条环形线）
#     for i in [0.4,0.8,1.2,1.6,2]:
#         ax.plot(angles, [i]*(n+1), 'b-',lw=0.5,color='coral') # 之所以 n +1，是因为要闭合！
# 
#     #ax.fill(angles, stats, facecolor='greenyellow', alpha=0.5)
#     # 填充底色
#     ax.fill(angles, [2]*(n+1), facecolor='g', alpha=0.5)
#     # 自己画grid线（6条半径线）
#     for i in range(n):
#         ax.plot([angles[i], angles[i]], [0, 2], 'b-',lw=0.5,color='coral')
# 
# 
# 
#     ax.set_thetagrids(angles * 180/np.pi, labels,color ='darkorange' )
# 
#     ax.spines['polar'].set_visible(False)
#     #should change the name to ticker when apply it in module
#     ax.set_title( "Ticker:"+str(int( radarData.loc[indx,name1] )) )
#     ax.grid(False)
#     #ax.set_rlim(0,2)
#     
#     # 关闭数值刻度
#   
#     #ax.set_yticks( range(0.0, 2.0, 0.4))
#     ax.set_yticks( np.arange(0.4, 2.4, step=0.4) )
    #ax.set_yticklabels(np.arange(0.4, 2, step=0.4), verticalalignment='bottom', horizontalalignment='right')

   
    #plt.show()
    #plt.savefig( curPath+plotn + '_plot.png')
    #cols = cols ,is the input 
    r_list = lst_tbl(radarData,ticker,indx,cols,in_target,algo)
    indx_val=radarData.loc[indx]
    indx_val.columns=radarData.columns
    indx_val.fillna("")
    
    
    #call regression
    numerical_features=['GROSSPROFIT', 'PROFIT_LOSS',
                   'SHAREHOLDERSEQUITY', 'NETSALES', 'TOTAL_ASSETS',
                   'EQUITY_TO_ASSET_RATIO', 'NET_ASSETS', 
                   'OPERATINGINCOME',  'LIABILITIES', 'CASHANDDEPOSITS'
                   ]
 


    #print(indx_val)
    return plotn+"_plot.png",indx,indx_val,r_list


#add by jin
def getjson( r_list, sec_name, tk,  tbl_cols,indx_val ,rank_plot_lst ):
    
#     counti=1#add by jin
#     mainww=0
#     tmps=''#add by jin
#     #the title you can change as your request
#     #add by jin,JSON
#   
#     serformat= "{'name': '%s','ratio': '%s','codeid':'%s','link':'%s'},"
#     serdata22=""
#     
#     json_cat3 = '{\n "name": "'+ sec_name  +'",  \n "children": [\n'
#     
#     category11=set()#add by jin
#     category12=set()#add by jin
# 
#     print(r_list[0])
#     for refer in r_list:
#         if refer not in category11:
#                 #removerepeat(json_cat2, '   { \"name\": \"'+ referred +'\",     \"value\": \"'  +str(counti)+ '"       }')
#                 json_cat3+=   '{\"name\": \"'+ refer +  '\",   \"children\": ['          +'\n'
#         counti=counti+1 #add by jin    
#         category11.add(refer)#add by jin
#         #not cat 1| json cat2 ,then can be add to cat 2 | json cat3
#         category12.add(referred)#add by jin
#         #    once complete children word, I dont care whether you repeat
#         if tmps==refer:
#             
#             json_cat3 +=   '    { \"name\": \"'+ referred +'\",     \"value\": \"'  + str('%.03f'%prob) + '"       }'
#           
#             serdata22 +=  serformat % (referred, str('%.03f'%prob),tk,'reports')
#           
#             ################
#             counti=counti+1 #add by jin
#             mainww=0
#             
#             json_cat3+=  ',\n'
#         else:
#             #cat2 begin ,so dont repeat write and flag
#             mainww=1
#         tmps=refer
#         ###### 
#     json_cat3=  json_cat3[:-2]#remove ","
#     json_cat3+=     '\n] }\n'
#     # the close of root|json cat1 
#     json_cat3+=  '] }\n'#add by jin,JSON
#     
#     return json_cat3,serdata22

    return "",""



#####generate html file#####################
def gen_html_more(tk , sec_name , current_dir , tbl_cols,indx_val ,r_list,rank_plot_lst,cols):
    np.set_printoptions(precision=3)
#     json_cat2=''
#     json_cat2 ,serdata22  = getjson(r_list, sec_name, tk,  tbl_cols,indx_val  ,rank_plot_lst )
# 
# 
#     fnm=''
#     fnm='j'+str(random.randint(100,200))
    
    #
    html_head_0 = os.path.join(current_dir,  'jtree_top.txt')
    html_tail_1 = os.path.join(current_dir,  'jtree_t1.txt')
  

    
    with open(html_head_0 , 'r', encoding = 'utf-8') as f:
        head_text0 = f.read()
    with open(html_tail_1 , 'r', encoding = 'utf-8') as f:
        tail_text1 = f.read()

    #########
   
    #--r_list['STOCK_CODE']   = r_list[  'STOCK_CODE'].mask(r_list['STOCK_CODE'].notnull(),r_list[  'STOCK_CODE'].values.round().astype(int) )
    
    
    jsonfile1=""
    #the ticker 
    tk_name=[]
    lns= len(cols )
    lng= len( r_list )
    tt = indx_val[cols]
    tt = tt.fillna(0) #replace as 0 , seen not make sense , temply method
    tk_name.append( str(tk) )
    tt = np.array2string(np.array(tt).reshape(  (-1, lns ) )    ,  separator=',' )
    jsonfile1 = "var data1 = "+ tt \
                +" ;\n" 
                
                
                
    #rows calc            
    for kk in range(0, len( r_list )):
         
        aa= (r_list.iloc[kk]['STOCK_CODE']).astype(str).split('.')
        
      
        tk_name.append( aa[0] )
        tmp=r_list.iloc[kk][cols]
        tmp = tmp.fillna(0)
        #seperate it into arrays
        tmp = "var data"+str(kk+1)+" = " + np.array2string(np.array(tmp).reshape(  (-1, lns ) )    ,  separator=',' )
        jsonfile1 = jsonfile1 \
                    + tmp+" ;\n" 
      
        
    #columns calc      
    ss = r_list[cols]
    ss = ss.fillna(0)
    
    #the max value   
    jfile2=""
    col_max=[]
    for mm in range( 0,lns ):
        col_max.append( ( ss[ cols[mm] ].astype('float32').max() +1 )  )

    jsonfile1 = jsonfile1 \
                + " \n " \
                +  "var lineStyle = { normal: {  width: 1, \n opacity: 0.5   }}; \n" \
                + "option = { \n  backgroundColor: \'#161627\',   \n title: {  \n   text: \'Ratios Radar Chart\'," \
                +   "        left: \'center\',    \n    textStyle: {    \n        color: \'#eee\'       \n }   \n }, \n   legend: { \n       bottom: 5,   \n     data:"
   
    t_str = ""
    t_str = "','".join(tk_name) 
    t_str = "'"+t_str+"'"
    jsonfile1 = jsonfile1 \
                +"["+ t_str +"], \n" \
                + "  itemGap: 20, \n  textStyle: { \n   color: \'#fff\',  \n   fontSize: 14   \n   }, \n  selectedMode: \'single\'    }," \
                + " \n   radar: { \n  indicator: [  \n " \
                + " \n "
                
    #loop the name of indicators,generate axis of 6
    for ii in range(0,  lns):
        if (  (ii+1) ==lns ):
            tmphtm = "{ name: \'"+ cols[ii] +"\', max:"+ str(col_max[ii]) + "} \n"
       
        else:
            tmphtm = "{name: \'"+ cols[ii] +"\', max:"+ str(col_max[ii]) + "}, \n"
        jsonfile1 = jsonfile1  + tmphtm

   


    #generate the series
    for ii in range(0,  lng):
        if (  (ii+1) ==lng ):
            jfile2 = jfile2 +" \n"\
                + " \n { name: \'"+ tk_name[ii] +"\',   type: \'radar\',  \n  lineStyle: lineStyle, \n data: data"+str(ii+1)+", \n symbol: \'none\', \n itemStyle: {  \n  normal: { \n color: \'#F9713C\' \n } \n }, \n areaStyle: { \n" \
                + "   normal: {  opacity: 0.1   }  \n   }  \n  } \n" 
               
        else:
            jfile2 = jfile2 +" \n"\
                     + " \n { name: \'"+ tk_name[ii] +"\', \n  type: \'radar\', \n  lineStyle: lineStyle, \n data: data"+str(ii+1)+", \n symbol: \'none\', \n  itemStyle: { \n  normal: { \n color: \'#F9713C\'  } }, \n areaStyle: { \n " \
                     + "   normal: {  opacity: 0.1   }  \n   }  \n  }, \n" 

    
          
    jfile2 = jfile2 +"\n" \
                    +"       ]   \n  };  \n if (option && typeof option === \"object\") \n { myChart.setOption(option, true);    \n   }  \n  </script> \n </body> \n  </html>"
    
                

    #ss = np.array2string(np.array( ss ).reshape(  (-1, lns ) )    ,  separator=',' )
    ##gaigaigaigai
 

    try:
        with open( 'C:/SimuTest/app/controllers/py/default_py8.erb', 'w', encoding = 'utf-8' ) as f:
            f.write(head_text0  + jsonfile1+ tail_text1 + jfile2  )  #add the ABSTRACT
        
    
        return "1",'default_py.erb'
    except:
        return "0",'default.erb'



#########
def cal_rank(cols,ticker):
    """views for the home page of the site."""    
    #0 is the temp file  , should changed it to 2 when data ready.
    fname1= "data_cln_grp2.csv"
    name_col ='STOCK_CODE'
    plotn =ticker+"_radar_"
    ranknum=10
 
    in_target=cols[0]
    #retrain it,WHEN the original data is re clean , can set it to 1.
    if 0:
        fname='jp_db_whl.csv'
        in1file_km_cluster_nb(cols,fname,'3DFinIndicator',[],False)
  
    #in_target is the main target , certainly can change it from the post value
    r_plot,indx,indx_val,r_list  = radar_plot(fname1,plotn,ticker,name_col,cols,in_target,'kmean', '2017',False,[] )
    if indx == -1:
        return None,None,r_plot,indx,indx_val,r_list,[]
    #mul line data set
    r_list.fillna("")
    indx_val.fillna("")
    
    r_list =r_list[[ 'EDI_CODE', 'STOCK_CODE', 'COMPANY_NAME',
                    'SETTLE_DATE_S', 'GROSSPROFIT', 'PROFIT_LOSS',
                   'SHAREHOLDERSEQUITY', 'NETSALES', 'TOTAL_ASSETS',
                   'EQUITY_TO_ASSET_RATIO', 'NET_ASSETS', 
                   'OPERATINGINCOME' ] +cols ]
    #sing line data set
    indx_val =indx_val[[ 'EDI_CODE', 'STOCK_CODE', 'COMPANY_NAME',
                    'SETTLE_DATE_S', 'GROSSPROFIT', 'PROFIT_LOSS',
                   'SHAREHOLDERSEQUITY', 'NETSALES', 'TOTAL_ASSETS',
                   'EQUITY_TO_ASSET_RATIO', 'NET_ASSETS', 
                   'OPERATINGINCOME'] +cols  ]
    ####draw the rank 10 graph ,and return the graph name
    r_list = r_list[:ranknum]
    #get top 10 tickers
    ten_tk = np.array(r_list['STOCK_CODE'])

    #len is not sure 10 ,perhaps only 5


##########draw radar by matplotlib################
#     r_plot1=""
    rank_plot_lst = []
#   
#     for kk in range( 0,len(ten_tk) ):
#         #fname1 is grp2.csv
#         print( "calculate rank "+str(kk)+" radar chart..." )
#         tmptk = ten_tk[kk]
# 
#         tmptk= str( int(tmptk) )
#         
#         #regress name is discard
#         #r_list is single data set , be discard
#         #
#         r_plot1 , _ ,_ , _  = radar_plot(fname1, tmptk+"_radar_" , tmptk ,name_col,cols,in_target,'kmean', '2017',False,[] )
#         rank_plot_lst.append( r_plot1 )
        

    return r_plot,indx,indx_val,r_list,rank_plot_lst    
    
    
    
################
def call_Py(tk,colss):

    cols=colss.split(",")
    #print(cols)        
    tbl_cols= ['EDI_CODE', 'STOCK_CODE', 'COMPANY_NAME',
               'SETTLE_DATE_S', 'GROSSPROFIT', 'PROFIT_LOSS',
               'SHAREHOLDERSEQUITY', 'NETSALES', 'TOTAL_ASSETS',
               'EQUITY_TO_ASSET_RATIO', 'NET_ASSETS', 
               'OPERATINGINCOME']+cols
    
    
    r_plot,indx,indx_val,r_list,rank_plot_lst = cal_rank(cols,str(int(tk)))
            
    if indx == -1:
        final_rt = 'default.erb'
        #print('0'+"#"+final_rt,end=" ")
    ###a智能重新组织成文件输出了。      
#     return render_to_response('assess_rank.html',{"r_plot": r_plot,
#                                                                      --qi"dt_1": '2017',
#                                                                      qi---"cols": cols,
#                                                                      qi--"algo": 'kmean',
#                                                                      --"r_cols": np.array(tbl_cols),
#                                                                      --"indx_val": np.array(indx_val),
#                                                                     -- "r_list": np.array(r_list),
#                                                                    ---  "ticker":tk,
#                                                                    --  "plot_list": rank_plot_lst,
#                                                               
#                                                                                                                                
#                                                                      })
    else:
        sec_name =indx_val['COMPANY_NAME']
        
        #gen_flag,final_rt = gen_html_more(tk, sec_name,curPath,tbl_cols,indx_val ,r_list, rank_plot_lst,cols  )
        gen_flag,final_rt = gen_html_more(tk, sec_name,curPath,tbl_cols,indx_val ,r_list, rank_plot_lst,cols  )
        #print(gen_flag+"#"+final_rt , end=" ")
    
#
first_arg = sys.argv[1]
s_arg = sys.argv[2]

call_Py( first_arg, s_arg)