import nltk
import os
import math
import string
import sentence
import re


class process_text(object):


    ''' Method for file IO processes. Opens a file, Removes HTML tags and tokenizes the file'''

    def processFile(self, file_path_and_name):
        try:
            f = open(file_path_and_name,'r')
            text = f.read()

            text = re.sub('<[^<]+?>', '', text)
            sent_tokenizer = nltk.data.load('tokenizers/punkt/english.pickle')
                
            lines = sent_tokenizer.tokenize(text.strip())

            text = lines

            sentences = []
            porter = nltk.PorterStemmer()
            
            for sent in lines:
                OG_sent = sent[:]
                sent = sent.strip().lower()
                line = nltk.word_tokenize(sent)
            
                stemmed_sentence = [porter.stem(word) for word in line]
                stemmed_sentence = filter(lambda x: x!='.'and x!='`'and x!=','and x!='?'and x!="'"
                                    and x!='!' and x!='''"''' and x!="''" and x!="'s", stemmed_sentence)
                if stemmed_sentence != []:
                    sentences.append(sentence.sentence(file_path_and_name, stemmed_sentence, OG_sent))
            
            return sentences


        except IOError:
            print ('Oops! File not found',file_path_and_name)
            return [sentence.sentence(file_path_and_name, [],[])]


      
    ''' Method to get all file names from a directory '''

    def get_all_files(self, path = None):
        retval = []
        
        if path == None:
            path = os.getcwd()

        for root, dirs, files in os.walk(path):
            for name in files:
                retval.append(os.path.join(root,name))
        return retval


    ''' Method to open all documents in a given directory '''

    def openDirectory(self, path=None):
        file_paths = self.get_all_files(path)
        
        sentences = []
    
        for file_path in file_paths:        
            sentences = sentences + self.processFile(file_path)
            
        return sentences
