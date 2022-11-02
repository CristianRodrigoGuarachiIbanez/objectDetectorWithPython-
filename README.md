# Object Detection/segmentation Based On Thresholding with Python

<p>The current algorithmus was designed to segment images in real-time inside a 3D-Icub-Simulator with python. It detects the arm of the iCub-robot as well as the object
on the images delivered by the cameras placed in the eyes.</p>

<img src="./tests/outputs/example.gif" alt="image" width="500" height="333">


## Dependencies

<p> To run the algorithmus, the following <strong>libraries should be installed:</strong></p>
        <pre class="notranslate"><code> OpenCV >= 4.6.0 </code></pre> 
        <pre class="notranslate"><code> imageio >= 2.22.2 </code></pre> 
        <pre class="notranslate"><code> matplotlib >= 3.6.0 </code></pre> 

###  Installing dependencies from requiriments

<p>The necessary libraries could be installed from the requirements file</p> 
the following should be run on the terminal:

<pre class="notranslate"><code> python3.? -m pip install -r ./requirements.txt <code></pre>


## Run 

<p> Navigate to the file ./ObjectPyDetector, where the main.py file is placed. There, compile the important modules:</p>

        python3.? test.py --path=./path_to/video_file --gif=False

<p> Dont forget to set the `--gif` argument to  False, otherwise it will output a gif file, when it is done. </p>


    