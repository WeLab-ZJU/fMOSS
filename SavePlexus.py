# -*- coding: utf-8 -*-
"""
Created on Wed Oct  6 19:46:08 2024

@author: zjz
@email: 3160100534@zju.edu.cn
@function: save the plexus vessels
@note: Need large RAM to run this code (at least 32GB)
"""

from skimage import io
import os
import numpy as np

if __name__ == "__main__":
    file = 'mouse_eye'
    path_data = './Data/' 
    path_vs = path_data + 'vertical_sprout.tif'
    path_pl = path_data +  'plexus.tif'

    if os.path.exists(path_pl):
        print('Exist: ', path_pl)
    print('Processing:', path_pl)

    path_skel = f'{path_data}{file}.tif'
    vs = io.imread(path_vs)
    im = io.imread(path_skel)
    if np.max(im) == 1:
        im = im * 255
        print('*255')
    im_plexus = im - vs
    io.imsave(path_pl, im_plexus)
    print('Save plexus vessel:', path_pl)
