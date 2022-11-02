#distutils: language = c++

from libcpp.unordered_map cimport unordered_map
from libcpp.vector cimport vector
from libcpp.string cimport string
from libc.string cimport memcpy
from libcpp.map cimport map
from libcpp.utility cimport pair
from libcpp cimport bool
from numpy import ascontiguousarray, asarray, uint8, dstack, float32, int32
from numpy cimport uint8_t, ndarray, int32_t
from cython cimport boundscheck, wraparound
from lib.PyObjectDetector cimport *

ctypedef enum Object:
    HAND
    ARM
    OBJECT

cdef class PyObjectDetector:
    cdef:
        Mat _image
        ObjectDetector * _detector

    def __cinit__(self, ndarray image):
 
        assert (image.size > 0), "array is empty"

        self._image = self.convert2Mat(image)
        self._detector = new ObjectDetector(self._image)
  

    def __deallocate__(self):
        del self._detector
    
    @boundscheck(False)
    @wraparound(False)
    cdef Mat getOriginalImage(self):
        return self._detector.getImage()

    @boundscheck(False)
    @wraparound(False)
    cdef Mat getBackgroundImage(self):
        return self._detector.getBackground()

    cdef void videoCapture(self, VideoCapture video):
        cdef:
            Mat frame 
        if not (video.isOpened()):
            raise Exception("Error opening video stream or file")
        while(video.isOpened()):
            video.read(frame)
         
            print("working", frame.cols)


    @boundscheck(False)
    @wraparound(False)
    cdef void py_searchForContoursWithArrayRange(self, int[:] lowRange, int[:] highRange, int[:] t_limits, string t_object, bool isolation, bool obj):
        
        cdef:
            Limits limits
            Object object

        cdef ndarray[int32_t, ndim=1, mode ='c'] low_buff = ascontiguousarray(lowRange, dtype=int32)
        cdef int* low = <int*> low_buff.data

        cdef ndarray[int32_t, ndim=1, mode ='c'] high_buff = ascontiguousarray(highRange, dtype=int32)
        cdef int* high = <int*> high_buff.data

        limits.area = t_limits[0]
        limits.width = t_limits[1]
        limits.height = t_limits[2]

        if(t_object=="hand"):
            self._detector.searchForContoursWithArrayRange(low, high, limits, HAND, isolation, obj)

        elif(t_object=="arm"):
            self._detector.searchForContoursWithArrayRange(low, high, limits, ARM, isolation, obj)

        elif(t_object=="object"):
            self._detector.searchForContoursWithArrayRange(low, high, limits, OBJECT, isolation, obj)
            
        else:
            print("Object not defined")

       
    @boundscheck(False)
    @wraparound(False)
    cdef Mat convert2Mat(self, ndarray image):
        
        if (image.ndim == 3):
            return self.np2Mat3D(image)
        else:
            raise Exception("array has no 3 Channels")

    @boundscheck(False)
    @wraparound(False)
    cdef Mat np2Mat3D(self, ndarray ary, bool bgr=False):
        assert ary.ndim==3 and ary.shape[2]==3, "ASSERT::3channel RGB only!!"
        if bgr:
            ary = dstack((ary[...,2], ary[...,1], ary[...,0])) #RGB -> BGR

        cdef ndarray[uint8_t, ndim=3, mode ='c'] np_buff = ascontiguousarray(ary, dtype=uint8)
        cdef unsigned int* im_buff = <unsigned int*> np_buff.data
        cdef int r = ary.shape[0]
        cdef int c = ary.shape[1]
        cdef Mat m
        m.create(r, c, CV_8UC3)
        memcpy(m.data, im_buff, r*c*3)

        return m

    @boundscheck(False)
    @wraparound(False)
    cdef object Mat2np(self, Mat m):
        # Create buffer to transfer data from m.data
        cdef Py_buffer buf_info

        # Define the size / len of data
        cdef size_t len = m.rows*m.cols*m.elemSize() # m.channels()*sizeof(CV_8UC3)

        # Fill buffer
        PyBuffer_FillInfo(&buf_info, NULL, m.data, len, 1, PyBUF_FULL_RO)

        # Get Pyobject from buffer data
        Pydata  = PyMemoryView_FromBuffer(&buf_info)

        # Create ndarray with data
        # the dimension of the output array is 2 if the image is grayscale
        if m.channels() >1 :
            shape_array = (m.rows, m.cols, m.channels())
        else:
            shape_array = (m.rows, m.cols)

        if m.depth() == CV_32F :
            ary = ndarray(shape=shape_array, buffer=Pydata, order='c', dtype=float32)
        else :
            #8-bit image
            ary = ndarray(shape=shape_array, buffer=Pydata, order='c', dtype=uint8)

        if m.channels() == 3:
            # BGR -> RGB
            ary = dstack((ary[...,2], ary[...,1], ary[...,0]))

        # Convert to numpy array
        pyarr = asarray(ary)
        return pyarr
    
    def calculate_countors(self, low, high, limits, object, isolation, obj):
        self.py_searchForContoursWithArrayRange(asarray(low, dtype=int32), asarray(high, dtype=int32), asarray(limits, dtype=int32), object, isolation, obj)

    def py_mask(self):
        return self.Mat2np(self._detector.getIsolatedImage())

    def py_original(self):
        return self.Mat2np(self.getOriginalImage())

    def py_background(self):
        return self.Mat2np(self.getBackgroundImage())




