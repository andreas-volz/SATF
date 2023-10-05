#!/bin/python3

import os
import shutil
import json
import math

import logging
from PIL import Image

# TBD: test if pngquant works well as python module
#import pngquant

import txtrpacker.txtrpacker

### global variables ###
log = logging.getLogger(__name__)

# ensure to clean up the last generation run
def cleanup_dir(output_path: str) -> None:
    try:
        shutil.rmtree(output_path)
    except FileNotFoundError:
        pass # just ignore

def prepare_dir(output_path: str) -> None:
    os.makedirs(output_path)
    
def search_metadata(input_path: str) -> list[str]:
    metadata_path_list = []
    before_dir = os.getcwd()
    os.chdir(input_path)
    for dirpath, dirnames, filenames in os.walk("."):
        #del dirnames[:] # remove the dirs to disable recusive search
        filenames.sort()
        for filename in filenames:
            if filename == 'metadata.json':
                metadata_path_list.append(dirpath)
                #print("found metadata in dirpath: " + dirpath)
    os.chdir(before_dir)
    return metadata_path_list

def image_crop_alpha(image: Image) -> tuple[Image, tuple[int, int, int, int]]:
    """
        input: PIL Image
        return: crop the alpha area at borders and return a tuple with the Image and cropped border rect (x, y, w, h)
    """
    # Get the bounding box
    bbox = image.getbbox()

    # Crop the image to the contents of the bounding box
    image = image.crop(bbox)

    # Determine the width and height of the cropped image
    (width, height) = image.size
    
    # Create a new image object for the output image
    cropped_image = Image.new("RGBA", (width, height), (0, 0, 0, 0))

    # Paste the cropped image onto the new image
    cropped_image.paste(image, (0, 0))

    return cropped_image, bbox

def image_concat(im_list: list, vertical: bool = True) -> tuple[Image, list]:
    """
        input: a list of PIL Images
        return: a tuple with concat image and list of positions referencing the original input images
    """
    dst_width = 0
    dst_height = 0
    if vertical:
        dst_width = max(im.width for im in im_list)
        dst_height = sum(im.height for im in im_list)
    else: # horizontal
        dst_width = sum(im.width for im in im_list)
        dst_height = max(im.height for im in im_list)
    
    dst = Image.new('RGBA', (dst_width, dst_height), (0, 0, 0, 0))
    
    pos_list = []
    pos_x = 0
    pos_y = 0
    for im in im_list:
        pos_list.append((pos_x, pos_y, im.width, im.height))
        dst.paste(im, (pos_x, pos_y))
        if vertical:
            pos_y += im.height
        else: # horizontal
            pos_x += im.width
    
    return dst, pos_list

def image_add_border(image: Image) -> Image:
    """
        input: PIL Image
        return: same image in same size with a colored border (helpful to debug animation positions)
    """
    border_size = 1
    border_color = (255, 0, 0, 255) # hard coded red for now
    
    im_color = Image.new("RGBA", (image.width, image.height), border_color)
    im_crop = image.crop((border_size, border_size, image.width - border_size, image.height - border_size))
    im_color.paste(im_crop, (border_size, border_size))
        
    return im_color

def generate_trim_images(input_path: str, output_path: str) -> None:
    """
        input: path to a folder with metadata.json
        result: all referenced images are read and alpha area is trimmed; the rect is calculated and saved from bbox and global origin point
    """
    json_dict = {}
    with open(input_path + '/' + "metadata.json") as file:
      json_dict = json.load(file)
      
    json_origin = json_dict['origin']

    json_animations = json_dict['animations']

    for animation in json_animations:
        if isinstance(json_animations[animation], dict):
            print("animation: " + animation)
            for direction in json_animations[animation]:
                if isinstance(json_animations[animation][direction], list):
                    print("direction: " + direction)
                    for frame in json_animations[animation][direction]:
                        name = frame['name']
                        input_png = input_path + '/' + name + '.png'
                        output_png = output_path + '/' + name + '.png'
                        
                        image = Image.open(input_png)
                        image, bbox = image_crop_alpha(image)
                        #image = image_add_border(image) # Border DEBUG!!!
                        image.save(output_png)
                        
                        frame['origin'] = {'x': json_origin['x'] - bbox[0], 'y': json_origin['y'] - bbox[1]}
                else:
                    print("error: unexpected direction: " + direction)
        else:
            print("error: unexpected animation: " + animation)
    
    # delete global origin as for trimmed images the origin is written in each frame
    if 'origin' in json_dict:
        del json_dict['origin']
    # hint: global camera block is preserved as scene information as it doesn't hurt that much
    
    json_object = json.dumps(json_dict, indent=4)
     
    with open(output_path + '/' + 'metadata.json', "w") as outfile:
        outfile.write(json_object)

def merge_animations_metadata(base_dict, add_dict) -> None:
    """
        input: one base JSON and one addition JSON
        result: one merged JSON (overwrites base_dict in memory, caller needs to create a (deep) copy if original base is needed after the call
    """
    base_animations = base_dict['animations']
    add_animations = add_dict['animations']
    
    for add_anim in add_animations:
        if isinstance(add_animations[add_anim], dict):
            #print("animation: " + add_anim)
            if not add_anim in base_animations:
                # animation not found in base so add the complete new animation to the base
                base_animations[add_anim] = add_animations[add_anim]
            else:
                # same animation found in base => merge directions
                # in case the direction exists in base it replaces all frames with the new one => no frame merging! 
                for direction in add_animations[add_anim]:
                    if isinstance(add_animations[add_anim][direction], list):
                        #print("add direction: " + direction)
                        if not direction in base_animations[add_anim]:
                            base_animations[add_anim][direction] = add_animations[add_anim][direction]
                        else:
                            print("error: unable to replace existing animation frames: " + add_anim + ':' + direction)
                    else:
                        print("error: unexpected direction: " + direction)
        else:
            print("error: unexpected animation: " + add_anim)
    
def generate_merged_animations_metadata(merge_path: str, remove_merged_files: bool = True):
    metadata_trimmed_list = search_metadata(merge_path)

    base_dict = {}
    with open(merge_path + '/' + metadata_trimmed_list[0] + '/' + "metadata.json") as file:
      base_dict = json.load(file)
          
    i = 0
    for path in metadata_trimmed_list:
        if i > 0:
            json_file = merge_path + '/' + path + '/' + 'metadata.json'
            with open(json_file) as file:
              merge_dict = json.load(file)
              
            merge_animations_metadata(base_dict, merge_dict)
        i += 1
        
    bytes_written = 0
    json_object = json.dumps(base_dict, indent=4)
    merged_json_file =  merge_path + '/' + 'metadata.json'
    with open(merged_json_file, "w") as outfile:
        if(outfile.write(json_object)):
            # clean merged files after the merged file is successful written
            print("write merged file: " + merged_json_file)
            if remove_merged_files:
                for path in metadata_trimmed_list:
                    json_file = merge_path + '/' + path + '/' + 'metadata.json'
                    os.remove(json_file)

def generate_packed_texture(input_path: str, output_path: str):
    """
        input: path to a folder with metadata.json and refenced images
        output_path: to place the generated files
        result: take all referenced animations/direction images from metadata and bin-pack them together into one big image sheet
    """
    json_dict = {}
    with open(input_path + '/' + "metadata.json") as file:
      json_dict = json.load(file)
    
    json_animations = json_dict['animations']

    image_list = []
    for animation in json_animations:
        if isinstance(json_animations[animation], dict):
            #print("animation: " + animation)
            for direction in json_animations[animation]:
                if isinstance(json_animations[animation][direction], list):
                    #print("direction: " + direction)
                    for frame in json_animations[animation][direction]:
                        name = frame['name']
                        input_png = input_path + '/' + animation + '/' + direction + '/' + name + '.png'
                        input_png_id = animation + '/' + direction + '/' + name + '.png'
        
                        image = Image.open(input_png)
                        #image = image_add_border(image) # Border DEBUG!!!
                        image_list.append((input_png_id, image))
                else:
                    print("error: unexpected direction: " + direction)
        else:
            print("error: unexpected animation: " + animation)
    
    padding = 0
    sorting = "maxarea" # maxwidth, maxheight maxarea
    maxdim = 16384 # maximum image dimension in Godot
    dest = output_path + '/' + "animations.png"
    placements = txtrpacker.txtrpacker.pack_images(image_list, padding, sorting, maxdim, dest)
    
    # resort the image list as dict for later JSON assignment
    image_dict = {}
    for image_place in placements:
        image_dict[image_place[1]] = image_place[0]
    
    for animation in json_animations:
        if isinstance(json_animations[animation], dict):
            #print("animation: " + animation)
            for direction in json_animations[animation]:
                if isinstance(json_animations[animation][direction], list):
                    #print("direction: " + direction)
                    for frame in json_animations[animation][direction]:
                        name = frame['name']
                        input_png_id = animation + '/' + direction + '/' + name + '.png'
                        #print("png: " + input_png_id)
                        rect = image_dict[input_png_id]
                        #print("rect: " + str(rect.get_left()) + ' ' + str(rect.get_bottom()) + ' ' + str(rect.get_width()) + ' ' + str(rect.get_height()))
                        frame['rect'] = {'x': rect.get_left(), 'y': rect.get_bottom(), 'w': rect.get_width(), 'h': rect.get_height()}
                else:
                    print("error: unexpected direction: " + direction)
        else:
            print("error: unexpected animation: " + animation)
    
    json_object = json.dumps(json_dict, indent=4)
     
    with open(output_path + '/' + 'metadata.json', "w") as outfile:
        outfile.write(json_object)
    
def generate_rotated_images(input_path: str, output_path: str) -> None:
    """
        input: path to a folder with metadata.json
        output_path: rotate images and metadata
    """
    json_dict = {}
    with open(input_path + '/' + "metadata.json") as file:
      json_dict = json.load(file)

    json_animations = json_dict['animations']

    for animation in json_animations:
        if isinstance(json_animations[animation], dict):
            print("animation: " + animation)
            for direction in json_animations[animation]:
                if isinstance(json_animations[animation][direction], list):
                    print("direction: " + direction)
                    for frame in json_animations[animation][direction]:
                        name = frame['name']
                        input_png = input_path + '/' + animation + '/' + direction + '/' + name + '.png'
                        output_png = output_path + '/' + animation + '/' + direction + '/' + name + '.png'
                        
                        image = Image.open(input_png)
                        
                        if image.width > image.height:
                            image = image.transpose(Image.ROTATE_90)
                            frame['rotated'] = True
                            
                        image.save(output_png)
                        
                else:
                    print("error: unexpected direction: " + direction)
        else:
            print("error: unexpected animation: " + animation)
    
    # delete global origin as for trimmed images the origin is written in each frame
    if 'origin' in json_dict:
        del json_dict['origin']
    # hint: global camera block is preserved as scene information as it doesn't hurt that much
    
    json_object = json.dumps(json_dict, indent=4)
     
    with open(output_path + '/' + 'metadata.json', "w") as outfile:
        outfile.write(json_object)
    
### main ####

def main():
    # cleanup everything while development
    cleanup_dir("trimmed")
    cleanup_dir("rotated")
    cleanup_dir("packed")

    metadata_input_list = search_metadata('input')

    for path in metadata_input_list:
        prepare_dir('trimmed/' + path)

    for path in metadata_input_list:
        prepare_dir('rotated/' + path)

    prepare_dir('packed')

    for path in metadata_input_list:
        generate_trim_images('input/' + path, 'trimmed/' + path)
    
    generate_merged_animations_metadata('trimmed', False) # False is to debug the json generation, in normal run it's ok to remove them
    
    #generate_rotated_images('trimmed', 'rotated')

    generate_packed_texture('trimmed', 'packed')

if __name__ == "__main__":
    main()

