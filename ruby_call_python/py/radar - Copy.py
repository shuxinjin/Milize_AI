#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 28 23:04:58 2018

@author: shuxin.jin@hotmail.com
"""



import os,sys

curPath = os.path.abspath(os.path.dirname(__file__))
rootPath = os.path.split(curPath)[0]
sys.path.append(rootPath)
sys.path.append(curPath)


first_arg = sys.argv[1]
s_arg = sys.argv[2]

def call_Py( tk , colss ):


    
    print('filenameof Py'+tk+colss)


    jfile2 = "\n"  +tk+colss+" </html>"
    
                
    #print(curPath)
    #ss = np.array2string(np.array( ss ).reshape(  (-1, lns ) )    ,  separator=',' )
    ##gaigaigaigai
 

    
    with open( 'C:/milize/FA_V001/fin_assess/default_py5.erb', 'w', encoding = 'utf-8' ) as f:
        f.write(jfile2 ) 
    #return ('return filenameof Py'+tk+colss)
#c1='1377'
#3c2 ="ROE,ROA,Ratio of gross profit to net sales,Ratio of Operating profit to net sales"






call_Py( first_arg, s_arg)
