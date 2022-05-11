#!/usr/bin/env python3 
#!/usr/bin/sh

# run in terminal using python3 Exam4.py
# example string is ATTTGGATT
import pandas as pd 


# function to output the number of possible kmers of size k from string x
def string_count_po(x,k):
    '''This function takes 2 arguments: 1) a list of string or a single string and 2) an integer, k, representing the length of substring. The output is the number of possible kmers of size k from the string. If a list of strings then a list of possible kmers is produced.
    '''
    if type(k) is not int:
        return ("k must be an integer")
    if k < 0 :
        return ("k cannot be negative")
    if k == 0 :
        return 0
    answer_array = []  # empty array to be filled later
    if type(x) is list:  # if the input is a list of strings
        for line in x:   # for each element in x, now assigned to variable "line"
            line = line.replace("\n","") # gets rid of the special next line symbol by replacing with blank space
            if type(line) is not str:
                return ("x must be a string")
            if k > len(line):  
                return ("k cannot be larger than the length of the string being searched")
            num_slot = len(line) - k + 1  # of possible slots that's the same size as the desired substring
            num_unique_values = len(set(line))  # length of the string turned into a set
            num_substring = num_unique_values ** k 
            answer_array_addition = min(num_slot, num_substring)
            answer_array.append(answer_array_addition)  
        return answer_array # a list of answers, corresponding for each string in the input list
    if type(x) is not list:  # if x is a single string then the same calculations are done on the single input string
        if type(x) is not str:
            return ("x must be a string")
        if k > len(x):
            return ("k cannot be larger than the length of the string being searched")
        num_slot = len(x) - k + 1  
        num_unique_values = len(set(x))
        num_substring = num_unique_values ** k
        return min(num_slot, num_substring)

def string_count_ob(x,k):
    '''This function takes 2 arguments: 1) a string or a list of strings and 2) an integer, k, representing the length of substring. The output is the number of observed, unique, kmers of size k from the string. If a list of strings then a list of observed kmers is produced.
    '''
    if type(k) is not int:
        return ("k must be an integer")
    if k < 0 :
        return ("k cannot be negative")
    if k == 0 :
        return 0
    if type(x) is not list:
        if type(x) is not str:
            return ("x must be a string")
        if k > len(x):
            return ("k cannot be larger than the length of the string being searched")
        i = 0   # a counter variable
        strings = [] # an empty list
        for j in x:  # iterating over every character in string x
            k_strings = x[i: i+k] # checks chunks of code of size k in the x input string. Assign to k_strings 
            if len(k_strings) < k: # if you run through all chuncks of size k in x then stop this loop
                break 
            if k_strings not in strings :  # add the unique substrings to a list strings that was previously created
                strings.append(k_strings)
            i = i + 1  # increases counter so the next chunk character of the string to size k is checked
        return len(strings) # counts the number of kmers
    answer_array = []  # empty list to store the answers generated for each element of list x  
    if type(x) is list: 
        for line in x:  # if the input x is a list of strings then the same calculations as above is run for each element of that list. 
            line = line.replace("\n","")
            if k > len(line):
                return ("k cannot be larger than the length of the string being searched")
            i = 0
            strings = []
            for j in line:
                k_strings = line[i: i+k]
                if len(k_strings) < k:
                    break 
                if k_strings not in strings :
                    strings.append(k_strings)
                i = i + 1
            answer_array_addition = len(strings)
            answer_array.append(answer_array_addition)  
        return answer_array

# A nicely formatted pandas data frame is generated when the input is a single string, and not for a list of strings. This is because printing a list of strings will only show a regular data frame.
def pd_df(x):
    '''If this function is passed an input as a string, it creates a pandas data frame with 3 columns: 1) possible kmer length, 2) the number of observed, and 3) the number of possible kmers. If this function is passed an input as a list of strings, it will create a data frame with 3 columns as described before for each string in the list and output each dataframe to a different file.
    '''
    if type(x) is not list:
        k = list(range(1,len(x)+1))
        ob = [] 
        po = []
        i = 1  # counter i
        while i <= len(x): #going through the input string and every loop increase i which is the kmer length
            o = string_count_ob(x,i) # outputs string_count_ob() for each successive increase in kmer length i
            p = string_count_po(x,i) # outputs string_count_po() for each successive increase in kmer length i
            ob.append(o) # outputs the value of string_count_ob into list ob
            po.append(p)       
            i = i + 1
        my_substrings_df = pd.DataFrame(  # creates a pandas data frame with 3 columns 'k', 'Observed', 'Possible'
            {
            'k': k,
            'Observed': ob,
            'Possible': po
            }
        )
 #       return my_substrings_df
        with open('exam4_dataframes.txt', 'a') as f:  # creates a new file name 'exam4_dataframes' using open()
            dfAsString = my_substrings_df.to_string(header=True, index=True) # change my dataframes to string to write them into the txt file. Keep header and index or they will be removed
            f.write("Dataframe of string is:") # headline text
            f.write("\n") # spaces so the document is easy to read
            f.write(dfAsString)
            f.write("\n")
            f.write("\n")
    if type(x) is list:
        c = 0 # create a counter variable
        for line in x:  # for x input as a list of strings, create a data frame for each string in the list
            line = line.replace("\n","")
            k = list(range(1,len(line)+1))
            ob = []
            po = []
            i = 1
            while i <= len(line):
                o = string_count_ob(line,i)
                p = string_count_po(line,i)
                ob.append(o)
                po.append(p)       
                i = i + 1
            my_substrings_df = pd.DataFrame(
                {
                'k': k,
                'Observed': ob,
                'Possible': po
                }
            )
            c = c + 1
#            print("Dataframe of string " + str(c) + " is:")
#            print(my_substrings_df)
#            print(" ")
            name = 'string' + str(c) + '_' + 'exam4_dataframes.txt'
            with open(name, 'a') as f:  # creates a new file name 'string_exam4_dataframes' using open() for each string in the list
                dfAsString = my_substrings_df.to_string(header=True, index=True) # change my dataframes to string to write them into the txt file. Keep header and index or they will be removed
                f.write("Dataframe of string " + str(c) + " is:") # headline text
                f.write("\n") # spaces so the document is easy to read
                f.write(dfAsString)
                f.write("\n")
                f.write("\n")

def lin_comp(x):
    '''This function takes as argument a string and calculates the languistic complexity of the string. Languistic complexity is defined as the number of kmers that are observed for all possible k-mer lengths, divided by the total number that are theoretically possible. 
    '''
    if type(x) is not list:
        ob = []
        po = []
        i = 1
        while i <= len(x):
            o = string_count_ob(x,i)
            p = string_count_po(x,i)
            ob.append(o) # creates a list of all observed kmers and stores in list ob
            po.append(p) # creates a list of all possible kmers and stores in list po    
            i = i + 1
        lin_comp = sum(ob) / sum(po) # calculates the language complexity
        print("The languistic complexity is: ")
        return lin_comp
    if type(x) is list:
        c = 0
        for line in x: # for each string in the list x, calculate linguistic complexity
            line = line.replace("\n","")
            ob = []
            po = []
            i = 1
            while i <= len(line):
                o = string_count_ob(line,i)
                p = string_count_po(line,i)
                ob.append(o)
                po.append(p)       
                i = i + 1
            lin_comp = sum(ob) / sum(po)
            c = c + 1
        #    print("The languistic complexity is: " + str(lin_comp))
            print("The languistic complexity of "+ str(c) +" is: ")
            print(lin_comp)
            print(" ")



# only run this if running the script. When script is run in the the terminal this will promt the user to input the file to be read which is the document containing strings to be used as x
if __name__ == '__main__':
    v = input("Enter name of input text file in current directory to read(omit extension): ")
    n = v + ".txt"
    f = open(n,"r")
    x = f.readlines()
#    k = input("Enter a numerical k value: ")
    print(" ")
    lin_comp(x)
    pd_df(x)



    

          



          


          
