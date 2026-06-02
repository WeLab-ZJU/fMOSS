# -*- coding: utf-8 -*-
"""
Created on Tue Oct 12 20:18:31 2024
@author: zjz
@email: 3160100534@zju.edu.cn
@function: use the normal vector to find the blocks with vertical sprout vessels
@note: Need large RAM to run this code (at least 32GB)

"""

import numpy as np
from skimage import io
# from numpy import random
import scipy.io as sci
import time
import os
import multiprocessing

def max_vec(coor):
    ''' Calculate the max direction'''
    coor = coor - np.mean(coor, axis=0)
    N = coor.shape[0]
    cor_mat = np.zeros((3,3))
    for i in range(3):
        for j in  range(3):
            cor_mat[i, j] = 1/N*np.sum(np.dot(coor[:,i], coor[:,j]))
    # print('cor_mat', cor_mat)
    eig, vec = np.linalg.eig(cor_mat)
    # print(eig, vec)
    # idx = np.where(abs(eig) == np.max(abs(eig)))
    # idx = idx[0][0]
    # vec_max = vec[:,idx]
    eig = np.squeeze(np.abs(eig))
    return eig, vec


def sprout_cal(coor_blk, blocks, path_):
    sprout = []
    norm_vec = np.load(path_ + 'verts_normals.npy')
    print('norm_vec:', norm_vec[0,:])
    norm_vec = norm_vec[:, [2,1,0]]
    print('norm_vec:', norm_vec[0,:])
    coor_point = np.load(path_ + 'points.npy')
    coor_point = coor_point[:, [2,1,0]]
    coor_point = coor_point - 1
    print(coor_point[0, :])
    
    print(norm_vec.shape)
    print(coor_point.shape)
    
    num_blk = len(coor_blk)
    for i, st_en in enumerate(coor_blk):
        if np.mod(i, 1000) == 0:
            print('Running: {:.2%}'.format(i/num_blk))
        st_z, st_y, st_x, en_z, en_y, en_x = st_en[0], st_en[1], st_en[2], st_en[3], st_en[4], st_en[5]
        # blk = im[st_z:en_z, st_y:en_y, st_x:en_x]
        blk = blocks[i]
            
        coor = np.transpose(np.nonzero(blk))
        eig, vec = max_vec(coor)
        ordr = np.argsort(eig)[::-1]
        
        cen_blk = (np.array([st_z, st_y, st_x]) + np.array([en_z, en_y, en_x]))/2
        distance = np.linalg.norm(coor_point - cen_blk, axis=1)
        
        idx = np.argsort(distance)[0:3]
        
        
        rad = np.mean(norm_vec[idx, :], axis=0)
        
        vec_1 = np.squeeze(vec[:,ordr[0]])
        vec_2 = np.squeeze(vec[:,ordr[1]])
        
        theta_1 = np.arccos(np.dot(rad, vec_1)/np.linalg.norm(rad)/np.linalg.norm(vec_1))
        theta_2 = np.arccos(np.dot(rad, vec_2)/np.linalg.norm(rad)/np.linalg.norm(vec_2))
        
        
        if theta_1 > np.pi/2:
            theta_1 = np.pi - theta_1
        if theta_2 > np.pi/2:
            theta_2 = np.pi - theta_2
        
        if theta_1 < 40/180*np.pi:
            if theta_2 > 45/180*np.pi:
                if eig[ordr[1]] < 9/(theta_2/np.pi*180)*eig[ordr[0]]:
                    sprout.append(st_en)
            else:
                sprout.append(st_en)
    return sprout
            

def wether_norm(p):
    st_en = p[0]
    blk = p[1]
    st_z, st_y, st_x, en_z, en_y, en_x = st_en[0], st_en[1], st_en[2], st_en[3], st_en[4], st_en[5]
    # blk = im[st_z:en_z, st_y:en_y, st_x:en_x]
    # blk = blocks[i]
        
    coor = np.transpose(np.nonzero(blk))
    # print(coor)
    eig, vec = max_vec(coor)
    ordr = np.argsort(eig)[::-1]
    
    cen_blk = (np.array([st_z, st_y, st_x]) + np.array([en_z, en_y, en_x]))/2
    distance = np.linalg.norm(coor_point - cen_blk, axis=1)
    
    idx = np.argsort(distance)[0:3]
    
    
    rad = np.mean(norm_vec[idx, :], axis=0)
    
    vec_1 = np.squeeze(vec[:,ordr[0]])
    vec_2 = np.squeeze(vec[:,ordr[1]])
    
    theta_1 = np.arccos(np.dot(rad, vec_1)/np.linalg.norm(rad)/np.linalg.norm(vec_1))
    theta_2 = np.arccos(np.dot(rad, vec_2)/np.linalg.norm(rad)/np.linalg.norm(vec_2))
    
    if theta_1 > np.pi/2:
        theta_1 = np.pi - theta_1
    if theta_2 > np.pi/2:
        theta_2 = np.pi - theta_2
    
    if theta_1 < 45/180*np.pi:
        if theta_2 > 45/180*np.pi:
            if eig[ordr[1]] < 13.5/(theta_2/np.pi*180)*eig[ordr[0]]:
                # sprout.append(st_en)
                return st_en
        else:
            # sprout.append(st_en)
            return st_en
    
if __name__ == '__main__':
    file = 'mouse_eye'
    print('Processing {}'.format(file))
    path_data = './Data/'
    blk_path = path_data + 'blk.npy'

    if os.path.exists(blk_path):
        print('File exist...')
    
    st = time.time()
    im = io.imread(f'{path_data}{file}.tif')
    if np.max(im) == 255:
        print('Max: 255')
        im = im//255
        
    blk_sz = [9, 9, 9]
    step =   [2, 2, 2]

    Z, Y, X = im.shape
    iz = np.floor((Z - blk_sz[0])//step[0] + 1).astype('int32')
    iy = np.floor((Y - blk_sz[1])//step[1] + 1).astype('int32')
    ix = np.floor((X - blk_sz[2])//step[2] + 1).astype('int32')

    coor_blk = []
    blocks = []
    para = []
    path_para = f'{path_data}para.npy'

    for iiz in range(iz):
        print(iiz, '----', iz)
        for iiy in range(iy):
            for iix in range(ix):
                st_z = iiz*step[0]
                st_y = iiy*step[1]
                st_x = iix*step[2]
                en_z = st_z + blk_sz[0]
                en_y = st_y + blk_sz[1]
                en_x = st_x + blk_sz[2]
                blk = im[st_z:en_z, st_y:en_y, st_x:en_x]
                if np.sum(blk) > 10:
                    # coor_blk.append([st_z, st_y, st_x, en_z, en_y, en_x])
                    # blocks.append(blk)
                    tp = ([st_z, st_y, st_x, en_z, en_y, en_x], blk)
                    para.append(tp)
                    
    # sprout = sprout_cal(coor_blk, blocks, path_)

    # for i in range(10000):
    #     sq = np.zeros((15,15,15), dtype=np.uint8)
    #     sq[5,5,5] = 1
    #     sq[5,5,6] = 1
    #     sq[1,2,3] = 1
    #     sq[2,4,5] = 1
    #     sq[7,2,5] = 1
    #     tp = ([1]*6, sq)
    #     para.append(tp)

    norm_vec = np.load(path_data + 'verts_normals.npy')
    print('norm_vec:', norm_vec[0,:])
    norm_vec = norm_vec[:, [2,1,0]]
    print('norm_vec:', norm_vec[0,:])
    coor_point = np.load(path_data + 'surface_points.npy')
    coor_point = coor_point[:, [2,1,0]]
    coor_point = coor_point - 1
    print(coor_point[0, :])
    print(norm_vec.shape)
    print(coor_point.shape)
    
    p = multiprocessing.Pool(4)
    b = p.map(wether_norm, para)
    p.close()
    p.join()
    sprout = list(filter(None, b))

    sci.savemat(path_data + 'blk.mat', {'blk': np.array(sprout)})
    np.save(path_data + 'blk.npy', sprout)

    en = time.time()
    print('running...', en - st, ' seconds')
