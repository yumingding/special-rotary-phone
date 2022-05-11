#!/usr/bin/env python3 
from Exam4 import *

# reads in the input file and places each line as an element in a list and set list equal to x
f = open("sampledna.txt.txt","r")
x = f.readlines()

# tests the simple case to make sure the answer is the expected answer
def test_simple_ob():
    assert string_count_ob(x, 2) == [5, 14, 3] 

def test_simple_po():
    assert string_count_po(x, 2) == [8, 16, 9]

def test_simple_ob():
    assert string_count_ob(x, 5) == [5, 47, 3]

def test_simple_po():
    assert string_count_po(x, 5) == [5, 51, 14]

    
# tests the case where an inputed substring length is zero
def test_zero_ob():
    expected = 0
    assert string_count_ob(x, 0) == expected
    
def test_zero_po():
    expected = 0
    assert string_count_po(x, 0) == expected
    
# tests the case where an inputed substring length happens to be negative
def test_negative_ob():
    expected = "k cannot be negative"
    assert string_count_ob(x, -2) == expected
    
def test_negative_po():
    expected = "k cannot be negative"
    assert string_count_po(x, -2) == expected

# tests the case where an input subsring length is not an integer
def test_type_ob():
    expected = "k must be an integer"
    assert string_count_ob(x, "r") == expected

def test_type_po():
    expected = "k must be an integer"
    assert string_count_po(x, "r") == expected

# tests the case where a non-string or list of strings is entered for x  
def test_str_ob():
    expected = "x must be a string"
    assert string_count_ob(2,3) == expected

def test_str_po():
    expected = "x must be a string"
    assert string_count_po(2,3) == expected

    
# tests the case where sub-string length k is larger than the string being searched
def test_lengthK_ob():    
    expected = "k cannot be larger than the length of the string being searched"
    assert string_count_ob(x, 12) == expected
    
def test_lengthK_po():    
    expected = "k cannot be larger than the length of the string being searched"
    assert string_count_po(x, 12) == expected
    
