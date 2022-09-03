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

def fileFilter(filePath):
    print(os.path.splitext(filePath)[1])
    if os.path.splitext(filePath)[1] == ".py":
        return True
    else:
        return False

def process(filePath):
    f = open(filePath, "r")
    lines = f.readlines()
    lines = filter(f, lines)
    for i in lines:
        print(i)

def recursive_process_file(rootdir, fileFilter, process):
    file_list = os.listdir(rootdir)
    for i in range (0, len(file_list)):
        path = os.path.join(rootdir, file_list[i])
        if os.path.isfile(path):
            if fileFilter(path):
                logging.info("process:" + path)
                process(path)
        elif os.path.isdir(path):
            recursive_process_file(path, fileFilter, process)
        else:
            print("file type unknow")


if __name__ == "__main__":
    recursive_process_file("/Users/fusionbolt/Desktop/python/sql", fileFilter, process)
