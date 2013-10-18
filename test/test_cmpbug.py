"""
"""
import unittest
from random import shuffle, randint
from oseq import OrderedSequence

class Item(object):
    def __init__(self, foo):
        self.foo = foo

def compare(a, b):
    if a.foo == b.foo:
        return 0
    elif a.foo < b.foo:
        return -1
    elif a.foo > b.foo:
        return 1

class testOrderedSequence(unittest.TestCase):
    def setUp(self):
        self.seq = OrderedSequence(compare)

    def tearDown(self):
        del self.seq

    def test_stable_sort(self):
        lst = [Item(1), Item(2), Item(3)]
        for item in lst:
            self.seq.add(item)
        assert len(self.seq) == 3
        while self.seq:
            self.seq.popleft()
        assert len(self.seq) == 0

    def test_unstable_sort_popleft(self):
        lst = [Item(1), Item(2), Item(3)]
        for item in lst:
            self.seq.add(item)
        lst[0].foo = 5
        self.assertRaises(IndexError, self.seq.popleft)

    def test_unstable_sort_pop(self):
        lst = [Item(1), Item(2), Item(3)]
        for item in lst:
            self.seq.add(item)
        lst[2].foo = 0
        self.assertRaises(IndexError, self.seq.pop)

if __name__ == '__main__':
    unittest.main()
