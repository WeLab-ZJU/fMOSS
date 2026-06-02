# -*- coding: utf-8 -*-
"""
Created on Tue Oct 12 16:50:47 2024
@author: zjz
@email: 3160100534@zju.edu.cn
@function: use the surface points calculate the normal vector of each point
@note: the '*.pcd' file can be visualized by 'ccViewer' software from https://www.cloudcompare.org/

"""

import os
import numpy as np
import open3d as o3d
import scipy.io as io

 
def read_obj(obj_path):
    with open(obj_path) as file:
        points = []
        faces = []
        while 1:
            line = file.readline()
            if not line:
                break
            strs = line.split(" ")
            if strs[0] == "v":
                points.append((float(strs[1]), float(strs[2]), float(strs[3])))
            if strs[0] == "f":
                faces.append((int(strs[1]), int(strs[2]), int(strs[3])))
    points = np.array(points)
    faces = np.array(faces)
 
    return points, faces
 
def save_pcd(filename, pcd):
    num_points = np.shape(pcd)[0]
    f = open(filename, 'w')
    f.write('# .PCD v0.7 - Point Cloud Data file format\n')
    f.write('VERSION 0.7\n')
    f.write('FIELDS x y z\n')
    f.write('SIZE 4 4 4\n')
    f.write('TYPE F F F\n')
    f.write('COUNT 1 1 1\n')
    f.write('WIDTH {}\n'.format(num_points))
    f.write('HEIGHT 1\n')
    f.write('VIEWPOINT 0 0 0 1 0 0 0\n')
    f.write('POINTS {}\n'.format(num_points))
    f.write('DATA ascii\n')
    for i in range(num_points):
        f.write('{} {} {}\n'.format(pcd[i,0], pcd[i,1], pcd[i,2]))
    f.close()

def norm_vec(path):
    normalPath = path.replace(".pcd", "_normal.pcd")
     
    print("Load a pcd point cloud, print it, and render it")
    pcd = o3d.io.read_point_cloud(path)
    print("Compute the normal of the origin point cloud")
    print(pcd.estimate_normals(search_param=o3d.geometry.KDTreeSearchParamKNN(knn=80)))
    path_, file = os.path.split(path)
    np.save(file=os.path.join(path_, "verts_normals.npy"), arr=np.asarray(pcd.normals))
    io.savemat(os.path.join(path_, "verts_normals.mat"), mdict={'verts_normals': np.asarray(pcd.normals)})
    print(np.asarray(pcd.normals).shape)
     
    normal_point = o3d.utility.Vector3dVector(pcd.normals)
    normals = o3d.geometry.PointCloud()
    normals.points = normal_point
    normals.paint_uniform_color((0, 1, 0))
    o3d.visualization.draw_geometries([pcd, normals], "Open3D noramls points", width=800, height=600, left=50, top=50,
                                      point_show_normal=False, mesh_show_wireframe=False,
                                      mesh_show_back_face=False)
    o3d.io.write_point_cloud(normalPath, normals)
    print('Finished saving normal pcd to: ', normalPath)


if __name__ == "__main__":
    '''Load the surface points from .mat file and save as .pcd file'''
    data_path = './Data/'
    points_dir = os.path.join(data_path, 'surface_points.mat')
    points = io.loadmat(points_dir)
    points = points['points']
    print(f'Points on the surface: {points}')
    np.save(points_dir.replace('.mat', '.npy'), points)

    pcd_dir =  os.path.join(data_path, 'surface_points.pcd')
    save_pcd(pcd_dir, points)
    
    ''' Calculate the normal vectors'''
    norm_vec(pcd_dir)