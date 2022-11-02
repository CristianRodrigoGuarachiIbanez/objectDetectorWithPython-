#distutils: language = c++

from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.utility cimport pair
from libcpp cimport bool

from openCVModuls cimport *

cdef extern from "<map>" namespace "std":
    cdef cppclass multimap[K, T]: # K: key_type, T: mapped_type
        cppclass iterator:
            pair[K,T]& operator*()
            iterator operator++()
            bint operator==(iterator)
            bint operator!=(iterator)
        multimap()
        bint empty()
        size_t size()
        iterator begin()
        iterator end()
        iterator find(K)
        iterator insert(pair[K, T])
        void erase(iterator)
        pair[iterator, iterator] equal_range(K)
        void clear()
        size_t count(K)

cdef extern from "../../objectDetectorCpp/NonMaximumSuppression/NMS.h" namespace "nms":
    cdef cppclass NMS:
        #public:
        NMS(vector[Rect] srcRects) except +

        void calculateNMS(vector[Rect]& resRects, float thresh, int neighbors);
        #private:
        multimap[int, size_t] idxs;
        const vector[Rect] Rects;
        void sort_BB(const vector[Rect]& srcRects)


cdef extern from "../../objectDetectorCpp/objectDetector.h" namespace "ObjDet":
    cdef cppclass Limits:
        int area;
        int height
        int width

    cdef cppclass COORDINATES:
        int tlx
        int tly
        int brx
        int bry

    cdef cppclass Object:
        pass

    cdef cppclass ObjectElements:
        Object object
        Point position;
        Rect rect;
        ObjectElements() except +
        ObjectElements(Object object, Rect rect, int x, int y) except +


    cdef cppclass ObjectDetector:

            vector[ObjectElements] OBJECTS;
        
            ObjectDetector(Mat&image) except +
            ObjectDetector(Mat&src, int lowLimit[3], int highLimit[3], Limits limit, Object object, bool iso) except +
            void searchForContoursWithArrayRange(int lowLimit[3], int highLimit[3], Limits limits, Object object, bool iso, bool obj);
            void getChannels(string colorSpace);
            vector[COORDINATES] getObjectCoordinates();

            Mat getBackground()
            Mat getImage()


            vector[Mat] splittedChannels()
            Mat getIsolatedImage()
    

            #private:
               
            Scalar low;
            Scalar high;
            Mat background, img, isolatedImage
            Mat blue, green, red
            vector[Mat] spl;
            vector[ObjectElements] OBJECTS;
            vector[Rect]srcRects;

            void selectImage(Mat&src, Mat&img, int imageChannels)
            void duplicateMat(Mat&src, Mat&target);
            void getObject(Mat&img, Scalar low, Scalar high, Limits limits, Object object, bool iso, bool obj)
            void drawObject(Mat&background);
            void drawNMSObject(Mat&background, vector[Rect]&Rects, Object object);
            void isolateObject(Mat&inputHSV, Mat&resultHSV, Mat&mask, Scalar minHSV, Scalar maxHSV)
            void splitChannels(Mat&image, Mat&r, Mat&g, Mat&b)

            void NonMaxSupp(vector[Rect] srcRects, vector[Rect] resRects, float threshold, float neighboors);