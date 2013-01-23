Introduction
===
<em>crzinput</em> is an experimental English typing software on IOS. It can correct the user's input somewhat like [Fleksy](https://www.fleksy.com) does. The algorithm inside the project is simple and still distant from production. 

Dictionary
===
The dictionary used is from [words](http://en.wikipedia.org/wiki/Words_(Unix\)). Scripts under ./dictgen in the project can generate the dictionary(resource) files for <em>crzinput</em>. 

You may:

1. Run BASH script <em>'gendict'</em> to generate <em>len(1..24).dict</em> files;

2. Edit <em>keycord.dat</em> according to the layout of your keyboard UI, each line as a space-seperated tuple (char, x, y);

3. Run <em>gendb.py</em> by [python 2.7](http://www.python.org)

4. Copy <em>veclen(1..24).dict</em> to xcode project resource folder and add them into the IOS project's copy-to-bundle list. 

Algorithm
===
As simple as junior school math. Take user input 'w', 'o', 'r', 'k' for example. When user touch the keyboard panel for the 4 letters, we have 4 touched 2D-coordinations, which lead to 3 2D-vectors: Vwo, Vor, Vrk. Listing the xs and ys we get a 6-dimension-vector:

> V = [Xvwo, Yvwo, Xvor, Yvor, Xvrk, Yvrk]; 

And using coordination data in keycord.dat we can calculate a standard vector of typing 'work':

> Vstandard = [x1, y1, x2, y2, x3, y3];

Then <em>cosine(V, Vstandard)</em> and <em>|V| - |Vstandard|</em> are used for evaluation of likelyness between the two typing gestures. The rest is to pick the most-likely word for the typing gesture. 

TODOs
===

1. Make the dictionary thinner, to increase accuracy(exclude unusual words), and to reduce searching/matching time;

2. Index the dictionary to speedup matching process;

3. UX and UI optimization;

4. Various languages support.

