"""
"""
import unittest
from random import shuffle, randint
from oseq import OrderedSequence

class testOrderedSequence(unittest.TestCase):
    def setUp(self):
        self.seq = OrderedSequence()

    def tearDown(self):
        del self.seq
    
    def test_empty_tree_has_no_min(self):
        self.assertRaises(IndexError, self.seq.min)

    def test_empty_tree_has_no_max(self):
        self.assertRaises(IndexError, self.seq.max)

    def test_empty_tree_is_zero_len(self):
        self.assertEqual( len(self.seq), 0)

    def test_insert_4_means_len_4(self):
        for i in range(0, 4):
            self.seq.add((i, 1))
        self.assertEqual( len(self.seq), 4)

    def test_min(self):
        for i in range(0, 4):
            self.seq.add((i, 1))
        self.assertEqual( self.seq.min(), (0, 1.0))

    def test_max(self):
        for i in range(0, 4):
            self.seq.add((i, 1))
        self.assertEqual( self.seq.max(), (3, 1.0))

    def test_empty_seq(self):
        self.assertEqual( len(self.seq), 0)
        self.assertRaises(IndexError, self.seq.min)
        self.assertRaises(IndexError, self.seq.max)
    
    def test_insert_and_remove_random(self):
        L = []
        jmax = 0
        nr = 1000
        for i in range(nr):
            j = randint(0, 10)
            L.append((j, j)) 
            if j > jmax:
                jmax = j
        for itm in L:
            self.seq.add(itm)
        self.assertEqual( len(self.seq), nr)
        self.assertEqual( self.seq.max(), (jmax, jmax))
        for itm in L:
            self.seq.remove(itm)
        self.assertEqual( len(self.seq), 0)
        self.assertRaises(IndexError, self.seq.min)
        self.assertRaises(IndexError, self.seq.max)
            
    def test_in_tree(self):
        L = []
        for i in range(0, 4):
            L.append((i, 1))
            self.seq.add(L[i])
        for j, i in enumerate(self.seq):
            assert i in self.seq
            assert L[j] in self.seq 
        assert (-1, 1) not in self.seq
        assert (4, 1) not in self.seq

    def test_contains(self):
        for i in range(0, 4):
            a = (i, 1)
            self.seq.add(a)
        assert a in self.seq

    def test_in_tree_pop(self):
        L = []
        for i in range(0, 4):
            L.append((i, 1))
            self.seq.add(L[i])
        for j, i in enumerate(self.seq):
            assert i in self.seq
            assert L[j] in self.seq
        for i in range(0, 4):
            self.seq.pop()
        assert len(self.seq) == 0
    
        
#    def test_lot_values(self):
#        for i in range(0, 10000):
#            self.seq.add((i, i*2))
#        self.assertEqual( self.seq.min(), (0, 0.0))
#        self.assertEqual( self.seq.max(), (9999, 9999*2.0))
#        self.assertEqual( len(self.seq), 10000)
#        
    def test_one_add(self):
        a = (573376.21, 156)
        self.seq.add(a)
        self.assertEqual( len(self.seq), 1)
        assert self.seq.pop() == a
        self.assertEqual( len(self.seq), 0)

    def test_two_add(self):
        a = (660981.5, 5967)
        self.seq.add(a)
        self.seq.add((573376.21, 156))
        self.assertEqual( len(self.seq), 2)
        self.seq.remove(a)
        self.assertEqual( len(self.seq), 1)

    def test_remove_not_there(self):        
        self.seq.add((5253.99, 2637))
        self.assertRaises(IndexError, self.seq.remove, (5253.99, 2635))

    def test_duplicate_1(self):
        self.assertRaises(IndexError, self.seq.remove, (1, 1))

    def test_duplicate_1a(self):
        a = (1, 1)
        self.seq.add(a)
        self.seq.remove( (1,1) )

    def test_duplicate_1b(self):
        self.seq.add((1, 1))
        self.assertRaises(IndexError, self.seq.remove, (1, 2))

    def test_duplicate_1c(self):
        for i in range(0, 100):
            self.seq.add((1, 1))
        self.assertRaises(IndexError, self.seq.remove, (1000000, 1))        

    def test_duplicate_2(self):
        a = (1, 1)
        b = (1, 1)
        c = (1, 1)
        self.seq.add(a)
        self.seq.add(b)
        self.seq.remove(a)
        self.seq.remove(b)


    def test_duplicate_3(self):
        a = (1, 2)
        self.seq.add((1, 1))
        self.seq.add(a)
        self.seq.remove(a)

    def test_duplicate_4(self):
        a = (1, 1)
        self.seq.add((1, 1))
        self.seq.add(a)
        for i in range(25):
            self.seq.add((1, 2))
        self.seq.add((1, 1))
        self.seq.add((1, 3))
        self.seq.remove(a)
#
    def test_duplicate_5(self):
        a = (5253.99, 2635)
        b = (660981.5, 5967)
        self.seq.add((1,1))
        self.seq.add((2,2))
        self.seq.add((5253.99, 2637))
        self.seq.add(b)
        self.seq.add((5253.99, 2636))
        self.seq.add((5253.99, 2635))
        self.seq.add((5253.99, 2634))
        self.seq.add((5253.99, 2633))
        self.seq.add((5253.99, 2638))
        self.seq.add(a)
        self.assertEqual( len(self.seq), 10)
        self.seq.remove(a)
        self.assertEqual( len(self.seq), 9)
        self.seq.remove(b)
        assert b not in self.seq
        self.assertEqual( len(self.seq), 8)

    def test_duplicate_6(self):
        
        self.seq.add((1,1))
        self.seq.add((2,2))
        self.seq.add((5253.99, 2637))
        self.seq.add((660981.5, 5967))
        self.seq.add((5253.99, 2636))
        self.seq.add((5253.99, 2635))
        self.seq.add((5253.99, 2634))
        self.seq.add((5253.99, 2634))
        self.seq.add((5253.99, 2633))
        self.seq.add((5253.99, 2638))
        self.seq.add((5253.99, 2635))
        self.seq.remove(self.seq.min())
        self.assertRaises(IndexError, self.seq.remove, (5253.99, 2632))

    def test_duplicate_7(self):
        L = [(8, 8), (10, 10), (1, 1), (1, 1), (2, 2), (2, 2), (5, 5), (1, 1), 
             (1, 1), (10, 10), (1, 1), (2, 2), (1, 1), (1, 1), (4, 4), (9, 9), 
             (2, 2), (7, 7), (4, 4), (3, 3), (4, 4), (4, 4), (2, 2), (7, 7), 
             (10, 10), (6, 6), (9, 9), (4, 4), (6, 6), (3, 3), (8, 8), (6, 6), 
             (9, 9), (3, 3), (4, 4), (1, 1), (3, 3), (6, 6), (5, 5), (1, 1), 
             (1, 1), (9, 9), (10, 10), (10, 10), (7, 7), (2, 2), (1, 1), 
             (1, 1), (8, 8), (10, 10), (5, 5), (7, 7), (10, 10), (10, 10), 
             (6, 6), (10, 10), (2, 2), (9, 9), (2, 2), (7, 7), (1, 1), (4, 4), 
             (3, 3), (9, 9), (3, 3), (7, 7), (10, 10), (1, 1), (7, 7), (8, 8), 
             (7, 7), (8, 8), (6, 6), (9, 9), (10, 10), (9, 9), (6, 6), (7, 7), 
             (2, 2), (10, 10), (4, 4), (10, 10), (4, 4), (1, 1), (10, 10), 
             (1, 1), (1, 1), (3, 3), (4, 4), (10, 10), (1, 1), (9, 9), (5, 5), 
             (10, 10), (2, 2), (1, 1), (6, 6), (5, 5), (5, 5), (10, 10)]
        for itm in L:
            self.seq.add(itm)
        self.assertEqual( len(self.seq), len(L))
        for itm in L:
            self.seq.remove(itm)
        self.assertEqual( len(self.seq), 0)

    def test_duplicate_8(self):
        # Failing test case
        L = [(8, 8), (6, 6), (9, 9), (10, 10), (9, 9)]
        for itm in L:
            self.seq.add(itm)
        self.assertEqual( len(self.seq), len(L))
        for itm in L:
            self.seq.remove(itm)
        self.assertEqual( len(self.seq), 0)
        
    def test_duplicate_9(self):
        # Failing test case
        L = [(1,1), (1,2), (1,3)]
        for itm in L:
            self.seq.add(itm)
        self.assertEqual(len(self.seq), len(L))
        self.assertEqual(self.seq.max(), (1,3) )

    def test_duplicate_10(self):
        # Failing test case
        L = [(1,1), (1,2), (1,3)]
        for itm in L:
            self.seq.add(itm)
        self.assertEqual(len(self.seq), len(L))
        self.assertEqual(self.seq.min(), (1, 1) )

#class testOrderedSequenceOrdering(unittest.TestCase):
#    def setUp(self):
#        self.seq = OrderedSequence()
#
#    def tearDown(self):
#        del self.seq
        
    def test_ordering_max_min(self):
        num = 10000
        L = list(range(num))
        shuffle(L)
        L.extend(L)
        for i in L:
            self.seq.add(i)
#        fh = open('/tmp/order', 'w')
#        self.seq.dump_dot(fh)
#        fh.close()
        L.sort()
#        L.reverse()
        while len(self.seq):
            a, b = self.seq.pop(), L.pop()
            assert a == b
        assert len(self.seq) == 0

    def test_ordering_min_max(self):
        num = 10000
        L = list(range(num))
        shuffle(L)
        L.extend(L)
        for i in L:
            self.seq.add(i)
#        fh = open('/tmp/order', 'w')
#        self.seq.dump_dot(fh)
#        fh.close()
        L.sort()
        L.reverse()
        while len(self.seq):
            a, b = self.seq.popleft(), L.pop()
            assert a == b
        assert len(self.seq) == 0
        
if __name__ == '__main__':
    unittest.main()
