"""Ordered Sequence of Objects with duplicates allowed for Python
"""

#
# TODO:
#
# - test what happens if inserted object its comparison field is changed 
#   (i.e. change happens outside of OrderedSequence -> will it ruin stuff?)
#

def compare(x, y):
    """
    Return negative if x<y, zero if x==y, positive if x>y.
    
    This comparison function is an example, the default one that is used
    is ``cmp''.
    """
    if x < y:
        return -1
    elif x == y:
        return 0
    else:
        return 1

__all__ = ['OrderedSequence']

cdef enum Color:
    BLACK
    RED
    DUPLICATE

cdef enum cmp_result:
    LT = -1
    EQ = 0
    GT = 1

# Forward declaration
cdef class _RedBlackNode

cdef class _RedBlackNode:
    cdef object obj
    cdef Color color
    cdef _RedBlackNode left, right, parent, next

    def __init__(self, object val, 
                       Color color = BLACK, 
                       _RedBlackNode left = None, 
                       _RedBlackNode right = None, 
                       _RedBlackNode parent = None, 
                       _RedBlackNode next = None):
        self.obj = val
        self.color = color
        if left is None:
            self.left = self
        else:
            self.left = left
        if right is None:
            self.right = self
        else:
            self.right = right
        self.parent = parent
        # non-unique obj items can be inserted in the tree
        # they form a single linked list in one node 
        # with duplicates stored in the single linked list
        self.next = next 
    
    def __str__(self):
        return "Node<{0} [{1}] p:{2}>".format(id(self), self.obj, id(self.parent))


cdef class _DirectedInOrderIterator:
    """Iterator that traverses in-order over given tree (depth first)
    """
    cdef bint forward
    cdef list stack
    cdef _RedBlackNode nil, last_node
    
    def __init__(self, 
                 _RedBlackNode root, _RedBlackNode nil, bint forward = True):
        """Sets up stack for Iterator
        
        Finds first element in sequence (min or max, dependent on ``forward''), 
        stacking the traversed items for processing in next()
        """
        cdef _RedBlackNode node, n
        self.forward = forward
        self.stack = []
        self.nil = nil
        # last_node is needed to traverse duplicate nodes only once
        self.last_node = None 
        node = root
        while node is not nil:
            self.stack.append(node)
            if node.next is not None:
                n = node.next
                while n is not None:
                    self.stack.append(n)
                    n = n.next
            if self.forward:
                node = node.left
            else:
                node = node.right

    def __iter__(self):
        """Iterator protocol
        """
        return self

    def __next__(self): # Note: Python normal naming convention is next(self)
        """Returns next element in traversal
        """
        cdef _RedBlackNode node, n
        if self.stack:
            node = self.stack.pop()
            if node.right is not self.nil:
                if self.forward:
                    n = node.right
                else:
                    n = node.left
                while n is not self.nil:
                    self.stack.append(n)
                    if self.forward:
                        n = n.left
                    else:
                        n = n.right
            if node.next is not None and node.next is not self.last_node:
                n = node.next
                while n is not None:
                    self.stack.append(n)
                    n = n.next
            self.last_node = node
            return node.obj
        else:
            raise StopIteration()


cdef class OrderedSequence:
    """Ordered Sequence of Python Objects (allowing duplicates)
    
    For maintaining the order of the objects a Red Black Tree 
    (a self-balancing binary search tree) is used. The order of Objects
    that compare equal is LIFO.

    WARNING:
    
    It is important to note that the remove / contains semantics 
    are not exact (that is, they do not use the ``is'' operator).
    
    Thus, with duplicate (equal) objects we can not remove the exact object, 
    if the comparison function does only take one aspect of such an object into 
    account (e.g. only the ``key'' property).
    """
    
    cdef object _cmp
    cdef _RedBlackNode _nil, _root
    cdef unsigned int _ct

    def __init__(self, cmp = cmp):
        # Make nil node (nil nodes point to self)
        self._nil = _RedBlackNode(val = None, color = BLACK)
        # Let Root node be the nil node at start
        self._root = self._nil
        self._ct = 0
        self._cmp = cmp # defaults to cmp func
    
    def __iter__(self):
        """Returns Iterator for Iterator protocol"""
        return _DirectedInOrderIterator(self._root, self._nil)

    def __reversed__(self):
        """Returns Iterator in reversed direction for Iterator protocol"""
        return _DirectedInOrderIterator(self._root, self._nil, forward = False)

    def __len__(self):
        """Returns number of items in the tree
        """
        return self._ct

    def __contains__(self, obj):
        """Returns whether ``obj'' is in the OrderedSequence
        """
        return self._find(obj) is not None

    def add(self, obj): # rename to add ??
        """Inserts ``obj'' in the OrderedSequence
        """
        self._insert(obj)
    
    def remove(self, obj):
        """Removes ``obj'' from the OrderedSequence.
        
        It is an error if obj is not in the OrderedSequence.
        """
        result = self._remove(obj)
        if not result:
            raise IndexError("""OrderedSequence.remove(x): \
x not in OrderedSequence""")
    
    def discard(self, obj):
        """Removes ``obj'' from the OrderedSequence, 
        also if it is not present in the OrderedSequence
        """
        self._remove(obj)
    
    def pop(self):
        """Removes and returns largest object of OrderedSequence
        """
        cdef _RedBlackNode current
        if self._ct > 0:
            current = self._max()
            self._remove(current.obj)
            return current.obj
        else:
            raise IndexError('pop from an empty OrderedSequence')

    def popleft(self):
        """Removes and returns smallest object of OrderedSequence
        """
        cdef _RedBlackNode current
        if self._ct > 0:
            current = self._min()
            self._remove(current.obj)
            return current.obj
        else:
            raise IndexError('pop from an empty OrderedSequence')

    def min(self):
        """Finds smallest obj in OrderedSequence
        """
        cdef _RedBlackNode current
        if self._ct > 0:
            current = self._min()
            return current.obj
        else:
            raise IndexError("Empty OrderedSequence has no min")

    def max(self):
        """Finds largest obj in OrderedSequence
        """
        cdef _RedBlackNode current
        if self._ct > 0:        
            current = self._max()
            return current.obj
        else:
            raise IndexError("Empty OrderedSequence has no max")

    # Private methods / Cython implementation
    #------------------------------------------------------------------------    
    cdef _RedBlackNode _find(self, obj): 
        """Get a node in the tree by its ``obj'' value
        """
        cdef _RedBlackNode z
        z = self._root
        while z is not self._nil:
            # if obj == z.obj:
            if self._cmp(obj, z.obj) == EQ:
                break
            else:
                if self._cmp(obj, z.obj) == LT:
                #if obj < z.obj:
                    z = z.left
                else:
                    z = z.right
        if z is not self._nil:
            while z.next is not None:
                #if z.obj == obj:
                if self._cmp(obj, z.obj) == EQ:
                    break
                z = z.next
    
            #if z.obj == obj:
            if self._cmp(obj, z.obj) == EQ:
                return z
        return None
    
    cdef _RedBlackNode _min(self):
        """Descends tree to left as far as possible
        """
        cdef _RedBlackNode current
        current = self._root
        while current.left is not self._nil:
            current = current.left
        return current
    
    cdef _RedBlackNode _max(self):
        """Descends tree to right as far as possible
        """
        cdef _RedBlackNode current 
        current = self._root
        while current.right is not self._nil:
            current = current.right
        while current.next is not None:
            current = current.next
        return current

    cdef _RedBlackNode _insert(self, obj):
        """Allocate node for data and insert in tree
        """
        cdef _RedBlackNode current, parent, x
        parent = None
        current = self._root
        while current is not self._nil:
            if self._cmp(obj, current.obj) == EQ:
                self._ct += 1
                # insert in this node as duplicate, at end of list
                while current.next is not None:
                    current = current.next
                x = _RedBlackNode(obj, color = DUPLICATE, 
                                  left = self._nil, 
                                  right = self._nil,
                                  parent = None)
                current.next = x
                return x
            parent = current
            if self._cmp(obj, current.obj) == LT:
                current = current.left
            else:
                current = current.right
        # setup new node
        x = _RedBlackNode(obj, color = RED, 
                          left = self._nil, 
                          right = self._nil,
                          parent = parent,
                          next = None)
        # insert node in tree
        if parent is None:
            x.color = BLACK
            self._root = x
        else:
            #if obj < parent.obj:
            if self._cmp(obj, parent.obj) == LT:
                parent.left = x
            else:
                parent.right = x
        self._insert_fixup(x)
        self._ct += 1
        return x      

    cdef bint _remove(self, obj):
        """Delete node with ``obj'' from tree
        
        Returns True when ``obj'' was found, returns False when not present.
        """
        cdef bint found
        cdef _RedBlackNode x, y, z
        found = False
        z = self._root
        while z is not self._nil:
            # _RedBlackNode in list has obj we are looking for
            if self._cmp(obj, z.obj) == EQ:
            #if obj == z.obj:
                break
            else:
                if self._cmp(obj, z.obj) == LT:
                #if obj < z.obj:
                    z = z.left
                else:
                    z = z.right
        if z is not self._nil:
            #if z.next is None and z.obj == obj:
            if z.next is None and self._cmp(obj, z.obj) == EQ:
                if z.left is self._nil or z.right is self._nil:
                    # y has a self._nil node as a child
                    y = z
                else:
                    # find tree successor with a self._nil node as a child
                    y = z.right
                    while y.left is not self._nil:
                        y = y.left
                # x is y's only child
                if y.left is not self._nil:
                    x = y.left
                else:
                    x = y.right
                # remove y from the parent chain
                x.parent = y.parent
                if y.parent:
                    if y is y.parent.left:
                        y.parent.left = x
                    else:
                        y.parent.right = x
                else:
                    self._root = x
                if y is not z:
                    z.obj = y.obj
                    z.next = y.next
                if y.color is BLACK:
                    self._delete_fixup(x)
                #
                self._ct -= 1
                return True
    
            # elif z.next is not None and z.obj == obj:
            elif z.next is not None and self._cmp(obj, z.obj) == EQ:
                y = z.next
                y.next = z.next.next
                # update tree upwards
                if z.parent:
                    if z is z.parent.left:
                        z.parent.left = y
                    else:
                        z.parent.right = y
                else:
                    self._root = y
                # update tree downwards
                if z.left is not self._nil:
                    z.left.parent = y
                if z.right is not self._nil:
                    z.right.parent = y

                y.parent = z.parent
                y.color = z.color
                y.left = z.left
                y.right = z.right
                self._ct -= 1
                #
                return True             
            
            else:
                while z.next is not None:
                    if self._cmp(z.next.obj, obj) == EQ:
                    #if z.next.obj == obj: # find exact dup by using is keyword
                        # _RedBlackNode is duplicate in list (body)
                        # Just delete from list by correcting next pointers
                        y = z.next
                        z.next = y.next
                        self._ct -= 1
                        #
                        return True
                    z = z.next
        # if we arrive here, there is no such node in the tree
        return False

    cdef void _insert_fixup(self, _RedBlackNode x):
        """Maintain Red-Black tree balance after inserting node x
        """
        cdef _RedBlackNode y
        # check Red-Black properties
        while x is not self._root and x.parent.color is RED:
            # we have a violation
            if x.parent is x.parent.parent.left:
                y = x.parent.parent.right
                if y.color is RED:
                    # uncle is RED
                    x.parent.color = BLACK
                    y.color = BLACK
                    x.parent.parent.color = RED
                    x = x.parent.parent
                else:
                    # uncle is BLACK
                    if x is x.parent.right:
                        # make x a left child
                        x = x.parent
                        self._rotate_left(x)
                    # recolor and rotate
                    x.parent.color = BLACK
                    x.parent.parent.color = RED
                    self._rotate_right(x.parent.parent)
            else:
                # mirror image of above code
                y = x.parent.parent.left
                if y.color is RED:
                    # uncle is RED
                    x.parent.color = BLACK
                    y.color = BLACK
                    x.parent.parent.color = RED
                    x = x.parent.parent
                else:
                    # uncle is BLACK
                    if x is x.parent.left:
                        x = x.parent
                        self._rotate_right(x)
                    x.parent.color = BLACK
                    x.parent.parent.color = RED
                    self._rotate_left(x.parent.parent)
        self._root.color = BLACK
        
    cdef void _delete_fixup(self, _RedBlackNode x):
        """Maintain Red-Black tree balance after deleting node x
        """
        cdef _RedBlackNode w
        while x is not self._root and x.color is BLACK:
            if x is x.parent.left:
                w = x.parent.right
                if w.color is RED:
                    w.color = BLACK
                    x.parent.color = RED
                    self._rotate_left(x.parent)
                    w = x.parent.right
                if w.left.color is BLACK and w.right.color is BLACK:
                    w.color = RED
                    x = x.parent
                else:
                    if w.right.color is BLACK:
                        w.left.color = BLACK
                        w.color = RED
                        self._rotate_right(w)
                        w = x.parent.right
                    w.color = x.parent.color
                    x.parent.color = BLACK
                    w.right.color = BLACK
                    self._rotate_left(x.parent)
                    x = self._root
            else:
                w = x.parent.left
                if w.color == RED:
                    w.color = BLACK
                    x.parent.color = RED
                    self._rotate_right(x.parent)
                    w = x.parent.left
                if w.right.color == BLACK and w.left.color == BLACK:
                    w.color = RED
                    x = x.parent
                else:
                    if w.left.color == BLACK:
                        w.right.color = BLACK
                        w.color = RED
                        self._rotate_left(w)
                        w = x.parent.left
                    w.color = x.parent.color
                    x.parent.color = BLACK
                    w.left.color = BLACK
                    self._rotate_right(x.parent)
                    x = self._root
        x.color = BLACK

    cdef void _rotate_left(self, _RedBlackNode x):
        """Rotate node x to left
        """
        cdef _RedBlackNode y
        y = x.right
        # establish x.right link
        x.right = y.left
        if y.left is not self._nil:
            y.left.parent = x
        # establish y.parent link
        if y is not self._nil:
            y.parent = x.parent
        if x.parent:
            if x is x.parent.left:
                x.parent.left = y
            else:
                x.parent.right = y
        else:
            self._root = y
        # link x and y
        y.left = x
        if x is not self._nil:
            x.parent = y

    cdef void _rotate_right(self, _RedBlackNode x):
        """Rotate node x to right
        """
        cdef _RedBlackNode y
        y = x.left
        # establish x.left link
        x.left = y.right
        if y.right is not self._nil:
            y.right.parent = x
        # establish y.parent link
        if y is not self._nil:
            y.parent = x.parent
        if x.parent:
            if x is x.parent.right:
                x.parent.right = y
            else:
                x.parent.left = y
        else:
            self._root = y
        # link x and y
        y.right = x
        if x is not self._nil:
            x.parent = y

    #-------------------------------------------------------------------#
    def dump_dot(self, to_file):
        """Dump tree structure to dot-file (for visualization with graphviz)
        """
        to_file.write("digraph G {")
        if self._root is not self._nil:
            self._dump(self._root, to_file)
        to_file.write("}")
    
    def _dump(self, _RedBlackNode x, buf):
        """Dumps all nodes in the tree to a buffer like object"""
        color = "yellow"
        fillcolor = "#fffacd"
        if x.color == RED:
            color = "red"
            fillcolor = "#ffcccc"
        elif x.color == BLACK:
            color = "black"
            fillcolor = "#ececec"
        buf.write('"{0}"[label = "{1}" '
                        'color = "{2}" fillcolor = "{3}"'
                        'style = "filled"];'.format(id(x), 
                                                x.obj, color, fillcolor))
        if x.left is not self._nil:
            self._dump(x.left, buf)
        if x.right is not self._nil:
            self._dump(x.right, buf)
        if x.next is not None:
            buf.write('"{0}" -> "{1}" ;'.format(id(x), id(x.next)))
            self._dump(x.next, buf)
        buf.write('"{0}" -> "{1}" [label="l"] ;'.format(id(x), id(x.left)))
        buf.write('"{0}" -> "{1}" [label="r"] ;'.format(id(x), id(x.right)))
        buf.write('"{0}" -> "{1}" [label="p"] ;'.format(id(x), id(x.parent)))
