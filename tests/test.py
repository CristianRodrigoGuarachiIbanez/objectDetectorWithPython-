
from operator import getitem
import cv2 as cv 
import argparse
import imageio

from PyDetector.objectDetector import PyObjectDetector
import matplotlib.pyplot as plt 
from matplotlib.colors import LogNorm
from matplotlib import cm
from matplotlib import colors



def main(path, gif):

    cap = cv.VideoCapture(path)
    image_list = []
    limits = [130,160,160]
    # Check if camera opened successfully
    if (cap.isOpened()== False): 
        raise Exception("Error opening video stream or file")
    
    # Read until video is completed
    while(cap.isOpened()):
        ret, frame = cap.read()
        if ret == True:
            
            detector = PyObjectDetector(frame)
            detector.calculate_countors([0, 0, 150], [0, 48, 181], limits, b"hand", True, False)
            detector.calculate_countors([98, 109, 20], [112, 255, 255], limits, b"arm", False, False)
            detector.calculate_countors([120, 51, 51], [180, 255, 76], limits, b"object",False, False)
            
            img = detector.py_background()
            cv.imshow("detector", img)
            if gif:
                image_list.append(img)

            if cv.waitKey(25) & 0xFF == ord('q'):
                break
        # Break the loop
        else: 
            break
 
    # When everything done, release the video capture object
    cap.release()
    
    # Closes all the frames
    cv.destroyAllWindows()
    if gif:
        imageio.mimsave(".outputs/example.gif", image_list, fps=25)
"""





back = detector.py_background()
mask = detector.py_mask()
if mask.size == 0:
    cv.imwrite("mask.png", mask)
else:
    pass

cv.imwrite("original.png", img)
cv.imwrite("background.png", back)

"""

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="object detector")
    parser.add_argument("--path", type=str, default=".", help="Path for loading the video")
    parser.add_argument("--gif", type=bool, default=True)
    args = parser.parse_args()
    main(**vars(args))