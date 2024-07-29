#!/bin/python3

import os
import shutil
import json
import math
import logging
import argparse

ulpc_sheet_definitions_path = "/home/andreas/src/git/Universal-LPC-Spritesheet-Character-Generator/sheet_definitions"
ulpc_spritesheets_path = "/home/andreas/src/git/Universal-LPC-Spritesheet-Character-Generator/spritesheets"

def main():
    input_path = "input"
    output_path = "output"
    current_path = "/home/andreas/src/git/SATF/LPC-Converter"
    


    ulpc_dict = {}
    with open("lpc-animations.json") as file:
        ulpc_dict = json.load(file)
      
    ulpc_animations = ulpc_dict['animations']
    
    spec_dict = {}
    with open("lpc-spec.json") as file:
        spec_dict = json.load(file)
        
    sprite_size = spec_dict['sprite_size']
        
    ulpc_satf_dict = {}
    
    ulpc_satf_dict['fps'] = spec_dict['fps']
    ulpc_satf_dict['origin'] = spec_dict['origin']
    ulpc_satf_dict['layers'] = []
    
    ulpc_asset_dict = {}
    with open(input_path + '/' + "superman.json") as file:
        ulpc_asset_dict = json.load(file)

    # TODO: support a mode without layers!

    for asset_layer in ulpc_asset_dict['layers']:
        # copy layer images to output path
        copy_src = ulpc_spritesheets_path + "/" + asset_layer['fileName']
        copy_dst = current_path + "/" + output_path + "/" + asset_layer['fileName']
        os.makedirs(os.path.dirname(copy_dst), exist_ok=True)
        shutil.copy2(copy_src, copy_dst)
        
        #sheet_definition = search_sheet_definition(asset_layer['name'])
        #print(sheet_definition)

        x_pos = 0
        y_pos = 0
        

        ulpc_satf_layer_dict = {}
        
        ulpc_satf_layer_dict['name'] = asset_layer['name']
        ulpc_satf_layer_dict['zPos'] = asset_layer['zPos']
        ulpc_satf_layer_dict['fileName'] = asset_layer['fileName']
        
        ulpc_satf_layer_animation_dict = {}
        
        
        for ulpc_anim in ulpc_animations:
            spec_animations = spec_dict['animations']
            if ulpc_anim in spec_animations:
                ulpc_satf_layer_animation_dict[ulpc_anim] = {}
                
                custom_frames = []
                
                if 'frames' in spec_animations[ulpc_anim]:
                    frames_count = spec_animations[ulpc_anim]['frames']
                    for i in range(frames_count):
                        custom_frames.append(i)
                elif 'custom_frames' in spec_animations[ulpc_anim]:
                    custom_frames = spec_animations[ulpc_anim]['custom_frames']
                else:
                    print("frame information missing in animation: ", ulpc_anim)
                        
                row = spec_animations[ulpc_anim]['row']
                #print(frames_count)
                for direction in spec_animations[ulpc_anim]['directions']:
                    x_pos = 0 # each new direction reset x
                    y_pos = row * sprite_size['h']  # each new direction move y cursor one sprite height down
                    
                    ulpc_satf_layer_animation_dict[ulpc_anim][direction] = []
                    for frame in custom_frames:
                        x_pos = frame * sprite_size['w'] # each new frame move x cursor one sprite width to the right
                        
                        frame_data = {}
                        anim_name = ulpc_anim + "_" + direction + "_" + str(frame).zfill(2)
                        frame_data['name'] = anim_name
                        frame_data['rect'] = {'x': x_pos, 'y': y_pos, 'w': sprite_size['w'], 'h': sprite_size['h']}
                        ulpc_satf_layer_animation_dict[ulpc_anim][direction].append(frame_data)
                        
                    row += 1
                        
        ulpc_satf_layer_dict['animations'] = ulpc_satf_layer_animation_dict
        ulpc_satf_dict['layers'].append(ulpc_satf_layer_dict)
    

    ## write metadata.json
    json_object = json.dumps(ulpc_satf_dict, indent=4) # remove indent for smaller file size!

    with open(output_path + '/' + 'metadata.json', "w") as outfile:
        outfile.write(json_object)

def search_sheet_definition(name: str) -> str:
    before_dir = os.getcwd()
    os.chdir(ulpc_sheet_definitions_path)
    for dirpath, dirnames, filenames in os.walk("."):
        del dirnames[:] # remove the dirs to disable recursive search
        for filename in filenames:
            if filename.endswith('.json'):
                with open(filename) as file:
                    sheet_definition = json.load(file)
                    #print(sheet_definition)
                    if sheet_definition['name'] == name:
                        # back to original path and return the first found file
                        os.chdir(before_dir)
                        return filename
    
    # back to original path and return empty string if nothing found
    os.chdir(before_dir)
    return ""


if __name__ == "__main__":
    main()
