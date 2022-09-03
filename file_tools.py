import os
import logging

log_name = 'tools.log'
logging.basicConfig(filename=log_name, filemode="a", level=logging.DEBUG)

def get_pure_file_name(absolute_path):
    return os.path.splitext(os.path.split(absolute_path)[1])[0]

def write_data(file_path, data):
    try:
        f = open(file_path, 'a')
        f.write(data)
    except Exception as e:
        logging.info("write data error:" + file_path + repr(e))
    finally:
        f.close()

def recursive_process_file(rootdir, process):
    file_list = os.listdir(rootdir)
    for i in range (0, len(file_list)):
        path = os.path.join(rootdir, file_list[i])
        if os.path.isfile(path):
            logging.info("process:" + path)
            process(path)
        if os.path.isdir(path):
            recursive_process_file(path, process)
