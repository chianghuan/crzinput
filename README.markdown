Introduction
===
<em>crzinput_ios</em> is an experimental English typing software on IOS. It can correct the user's input somewhat like [Fleksy](https://www.fleksy.com) does. The algorithm inside the project is simple and still distant from production. 

Dictionary
===
The dictionary used is from [words](http://en.wikipedia.org/wiki/Words_(Unix\)). Scripts under ./dictgen in the project can generate the dictionary(resource) files for crzinput_ios. 

You may:

1. Run BASH script 'gendict' to generate len1..24.dict files;

2. Edit keycord.dat, according to the layout of your keyboard UI, each line as a space-seperated tuple (char, x, y);

3. Run gendb.py by python 2.7

4. Copy veclen1..24.dict to xcode project resource folder and add them into the IOS project's copy-to-bundle list. 

Algorithm
===
As simple as junior school math. Take user input 'w', 'o', 'r', 'k' for example. When user touch the keyboard panel for the 4 letters, we have 4 touched 2D-coordinations, which lead to 3 2D-vectors: Vwo, Vor, Vrk. Listing the xs and ys we get a 6-dimension-vector:

> V = [Xvwo, Yvwo, Xvor, Yvor, Xvrk, Yvrk]; 

And using coordination data in keycord.dat we can calculate a standard vector of typing 'work':

> Vstandard = [x1, y1, x2, y2, x3, y3];

Then cosine(V, Vstandard) and |V| - |Vstandard| are used for evaluation of likelyhood between the two typing gestures. The rest is to pick the most-likely word for the typing gesture. 

Future Work
===
A lot to be done.

1. Index the dictionary to speedup matching process;

2. UX and UI optimization;

3. Reducing the number of words in the dictionary, eliminates unusual words, to speedup and increase accuracy;

4. Make various languages support =)
