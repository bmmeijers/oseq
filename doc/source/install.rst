This is oseq version 1.0.1
===================================

An Ordered Sequence of objects where duplicates are allowed.

Installation Instructions
-------------------------
For a system wide installation ::

   $ python setup.py build
   $ sudo python setup.py install
	
For a development installation (optional, depends on setuptools) ::

   $ python setup.py develop

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

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
