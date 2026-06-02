# -*- coding: utf-8 -*-
"""
Created on Wed Oct  6 16:53:29 2024

@author: zjz
@email: 3160100534@zju.edu.cn
@function: merge the blocks with vertical sprout vessels and save 
@note: Need large RAM to run this code (at least 32GB)
"""
from skimage import io
import numpy as np
import os

if __name__ == "__main__":
    path_data = './Data/'
    file = 'mouse_eye'
    path_vs = path_data + 'vertical_sprout.tif'
    if os.path.exists(path_vs):
        print('Exist:', path_vs)

    im = io.imread(f'{path_data}{file}.tif').astype('uint8')
    if np.max(im) == 1:
        im = im * 255
        print('*255')
    
    blk = np.load(path_data + 'blk.npy')
    
    mask = np.zeros(im.shape, dtype=np.uint8)
    
    for coor in blk:
        st_z, st_y, st_x, en_z, en_y, en_x = coor[0], coor[1], coor[2], coor[3], coor[4], coor[5]
        mask[st_z:en_z, st_y:en_y, st_x:en_x] = 1
    
    im = im * mask
    io.imsave(path_vs, np.array(im, dtype=np.uint8))
    print('Save vertical sprout vessel:', path_vs)
