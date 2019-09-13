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


first_arg = 3
s_arg = 2

def call_Py( tk , colss ):
    print(tk+colss)


call_Py( first_arg, s_arg)