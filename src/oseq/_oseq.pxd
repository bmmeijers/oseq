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

cdef class _DirectedInOrderIterator:
    cdef bint forward
    cdef list stack
    cdef _RedBlackNode nil, last_node
    
cdef class OrderedSequence:
    cdef object _cmp
    cdef _RedBlackNode _nil, _root
    cdef unsigned int _ct
    # Private methods / Cython implementation
    #------------------------------------------------------------------------    
    cdef _RedBlackNode _find(self, obj) 
    cdef _RedBlackNode _min(self)
    cdef _RedBlackNode _max(self)
    cdef _RedBlackNode _insert(self, obj)
    cdef bint _remove(self, obj)
    cdef void _insert_fixup(self, _RedBlackNode x)
    cdef void _delete_fixup(self, _RedBlackNode x)
    cdef void _rotate_left(self, _RedBlackNode x)
    cdef void _rotate_right(self, _RedBlackNode x)