The code in this repo was obtained from the bipy source code on the public github repository: https://github.com/tpoisot/bipy on Aug 30 2016.
 
# bipy

*bipy* is a collection of python scripts to analyze and visualize two-mode (bipartite) networks, mostly aimed at ecological datasets

*bipy* is released under the terms of the [GNU GPL](http://en.wikipedia.org/wiki/GNU_General_Public_License)

**Author** : Timothee Poisot <timothee.poisot@uqar.ca>
**Language** : Python  2.7 (although not tested, might work under 2.6)
**Requires** : numpy, scipy, pyx, tempfile, urllib, networkx

## Changes in this release (v1.0.2)

* Faster measures of nestedness and modularity
* q_c replaced by use_c, also used by nestedness
* import from and export to NetworkX
* method save in bipartite using pickle to keep a bipartite object
* function load to import a previously saved object
* networklevel method to output summary statistics


## For a list of the features...

... see the [website](http://tpoisot.github.com/bipy/).