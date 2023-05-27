#!/usr/bin/env python3

import os
import time
import shutil

folder_to_track = '/home/transmission/downloads/complete/'
folder_destination = '/home/shared/samba/movies/'

def move_new_folders():
    folders = os.listdir(folder_to_track)
    
    for folder in folders:
        folder_path = os.path.join(folder_to_track, folder)
        
        if os.path.isdir(folder_path):
            destination_path = os.path.join(folder_destination, folder)
            
            shutil.move(folder_path, destination_path)
            print(f"Folder '{folder}' moved to '{destination_path}'")

while True:
    move_new_folders()
    time.sleep(60)