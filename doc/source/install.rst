This is oseq version 1.0.1
===================================

Installation Instructions
-------------------------
For a system wide installation:

	python setup.py build
	sudo python setup.py install
	
For a development installation:

	python setup.py develop

Make sure to have a $HOME/.pydistutils.cfg and correct folder hierarchy in
this case.

Usage example
-------------------------
The module can be used as follows:

	>>> from oseq import OrderedSequence
	>>> seq = OrderedSequence()
	>>> seq.add(5)
	>>> seq.add(4)
	>>> seq.add(1)
	>>> seq.add(2)
	>>> seq.popleft()
	1
	>>> for item in seq: print item
	... 
	2
	4
	5
	>>> 

Copyright and License Information
---------------------------------
Copyright (c) 2009-2012 Martijn Meijers, Delft University of Technology.

oseq is licensed under the MIT_ license (see LICENSE).

.. _MIT: http://www.opensource.org/licenses/mit-license.php/
