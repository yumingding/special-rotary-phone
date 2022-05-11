# Overview 
The Exam4.py script includes functions that will output the observed and possible kmers of strings of text. This output is in dataframe and is generated for each string in a text file. If the input is a *single string*, the output is stored in a file called **'exam4_dataframes.txt'.**
If the input is a *list of strings* the output for each string is stored in a separate file that ends in **'exam4_dataframes.txt'.**

# Running the script
Run the script by calling ***python3 Exam4.py*** in the terminal. When the script is run you will be asked to input the name of a text file to read. Enter the name of the file without the extension. For example the file **sampledna.txt.txt** should be entered as ***sampledna.txt*** This text file must be in the same directory as the script. 

# Testing

To run a test call ***py.test*** in the terminal and the conditions in **test_e4.py** will be checked. The input file is hard coded in as **sampledna.txt.txt**.

# Functions

## string_count_po(x,k)
This function will output the number of possible kmers of size k from string x. This function takes 2 arguments: 1) a list of string or a single string and 2) an integer, k, representing the length of substring. The output is the number of possible kmers of size k from the string. If a list of strings then a list of possible kmers is produced.

## string_count_ob(x,k)
This function will output the number of observed kmers of size k from string x. This function takes 2 arguments: 1) a string or a list of strings and 2) an integer, k, representing the length of substring. The output is the number of observed, unique, kmers of size k from the string. If a list of strings then a list of observed kmers is produced.

## pd_df(x)
If this function is passed an input as a string, it creates a pandas data frame with 3 columns: 1) possible kmer length, 2) the number of observed, and 3) the number of possible kmers. If this function is passed an input as a list of strings, it will create a data frame with 3 columns as described before for each string in the list and output each dataframe to a different file.

## lin_comp(x)
This function takes as argument a string and calculates the languistic complexity of the string. Languistic complexity is defined as the number of kmers that are observed for all possible k-mer lengths, divided by the total number that are theoretically possible. 

## Special Note
Part of the script is only run when the script itself is run. This part asks for the name of the input text file. This part is hidden for testing.
