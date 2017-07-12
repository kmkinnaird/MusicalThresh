# jazzConverter.py
# Created Feb 13 2017 by Katherine M. Kinnaird
# Updated Jul 12 2017 by Katherine M. Kinnaird
# Released with ``Examining Musical Meaning in Similarity
#      Thresholds'' (ISMIR 2017) by Katherine M. Kinnaird
# 
# jazzConverter.py converts **jazz files to *kern files
#
# This converter is used following jazzparser.sh by Yuri Broze
# jazzparser.sh was released with the iRb Corpus v1.0

## =-=-=-=-=-=-=-=-=-=-=
## To use this converter in python3, run the following lines: 
# import numpy as np
# from jazzConverter import *
# 
## For a file with filename NAME, run the following:
#
# newfile_check(NAME) 
# jazzkern2chromacsv(NAME)
# 
## The first line checks for errors, while the second converts 
## the file to *kern format. 
## =-=-=-=-=-=-=-=-=-=-=

import numpy as np
import numpy.matlib 

def jazzkern2chromacsv(filename):
	""" JAZZKERN2CHROMACSV takes in a **kern file created from 
	a **jazz file and extracts the notes presented in the listed
	chord. The **kern files from the **jazz files do not break 
	out each note of the chords, instead listing the root and 
	type of chord. This script details that conversion."""

	# Open the .txt file that is the "kern"
	infile = open(filename, 'r')

	# Initialize with a list of zeros. To be removed later
	notes_mat = np.zeros((12,1))

	# For each line, load in each line
	for aline in infile:
		# Check if the leading character is a number or letter
		# Rows with symbols are not notes
		if (aline[0].isnumeric() or aline[0].isalpha()):
			note_info = aline.split('\n')[0].split('\t')

			# Break down the note info into the minimal needed
			dur = note_info[6]
			note = note_info[1]
			chord = note_info[2]
			
			# Get tones present in lead sheet:
			chord_out = find_chord(chord, note)

			# Preallocate the array needed
			dur = int(float(dur))
			mat = numpy.matlib.repmat(dur*chord_out,1, dur)

			# Add the new information to matrix of notes.
			notes_mat = np.concatenate((notes_mat, mat), axis=1)
			

	# Remove the list of zeros at the beginning of the matrix
	notes_mat = notes_mat[:,1:]

	# Save the results
	savename = filename.split('/')[2].split('.')[0] + ".csv"
	outfile = './csvfiles/' + savename
	np.savetxt(outfile,notes_mat, delimiter = ",")

def newfile_check(filename):
	""" NEWFILE_CHECK checks that the chords and notes in the file  
	have already been added to the dictionary. """

	# Open the .txt file that is the "kern"
	infile = open(filename, 'r')

	file_ok = True

	# For each line, load in each line
	for aline in infile:
		# Check if the leading charartver is a number or letter
		# Rows with symbols are not notes
		if (aline[0].isnumeric() or aline[0].isalpha()):
			note_info = aline.split('\n')[0].split('\t')

			# Break down the note info into the minimal needed
			dur = note_info[6]
			note = note_info[1]
			chord = note_info[2]

			#print('Testing Chord:', chord)
			chord_out = chordshape(chord)
			if type(chord_out) == type("a"):
				print(chord_out)
				file_ok = False

			#print('Testing note:', note)
			note_out = note2num(note)
			if type(note_out) == type("a"):
				print(note_out)
				file_ok = False

			# Test that DUR is of the form K.000
			# If not, print an error message:
			if float(dur) != int(float(dur)):
				print('Jazz assumption off! See:', dur, note, chord) 
				file_ok = False



def chordshape(chord_str):
	""" The function CHORDSHAPE takes in one string called 
	CHORD_STR and returns the two copies of the shape of the 
	chord relative to the root of the chord."""

	# Below is the chord dictionary. We will keep adding to this 
	# as we process each jazz standard. 
	chord_list = {'maj':np.array([[1,0,0,0,1,0,0,1,0,0,0,0]]), 
		'maj7':np.array([[1,0,0,0,1,0,0,1,0,0,0,1]]), 
		'7':np.array([[1,0,0,0,1,0,0,1,0,0,1,0]]), 
		'dom7':np.array([[1,0,0,0,1,0,0,1,0,0,1,0]]),
		'min':np.array([[1,0,0,1,0,0,0,1,0,0,0,0]]), 
		'min6':np.array([[1,0,0,1,0,0,0,1,0,1,0,0]]),
		'min7':np.array([[1,0,0,1,0,0,0,1,0,0,1,0]]), 
		'min:maj7':np.array([[1,0,0,1,0,0,0,1,0,0,0,1]]), 
		'dim7':np.array([[1,0,0,1,0,0,1,0,0,1,0,0]]), 
		'o7':np.array([[1,0,0,1,0,0,1,0,0,1,0,0]]),
		'7#9':np.array([[1,0,0,1,1,0,0,1,0,0,1,0]]),
		'7b13':np.array([[1,0,0,0,1,0,0,1,0,1,1,0]]),
		'+':np.array([[1,0,0,0,1,0,0,0,1,0,0,0]]),
		'6':np.array([[1,0,0,0,1,0,0,1,0,1,0,0]]),
		'7b9':np.array([[1,1,0,0,1,0,0,1,0,0,1,0]]),
		'7#5':np.array([[1,0,0,0,1,0,0,0,1,0,1,0]]),
		'7#11':np.array([[1,0,0,0,1,0,1,1,0,0,1,0]]),
		'h7':np.array([[1,0,0,1,0,0,1,0,0,0,1,0]]),
		'm7b5':np.array([[1,0,0,1,0,0,1,0,0,0,1,0]]),
		'min7b5':np.array([[1,0,0,1,0,0,1,0,0,0,1,0]]),
		'm7#5':np.array([[1,0,0,1,0,0,0,0,1,0,1,0]]),
		'7b9#5':np.array([[1,1,0,0,1,0,0,0,1,0,1,0]]),
		'7#5b9':np.array([[1,1,0,0,1,0,0,0,1,0,1,0]]),
		'7sus':np.array([[1,0,0,0,0,1,0,1,0,0,1,0]]),
		'7sus4':np.array([[1,0,0,0,0,1,0,1,0,0,1,0]]),
		'9':np.array([[1,0,1,0,1,0,0,1,0,0,1,0]]),
		'^9':np.array([[1,0,1,0,1,0,0,1,0,0,1,0]]),
		'min9':np.array([[1,0,1,1,0,0,0,1,0,0,1,0]]),
		'min6':np.array([[1,0,0,1,0,0,0,1,0,1,0,0]]),
		'69':np.array([[1,0,1,0,1,0,0,1,0,1,0,0]]),
		'9sus':np.array([[1,0,1,0,0,0,0,1,0,0,1,0]]),
		'7alt':np.array([[1,1,0,1,1,0,1,0,2,0,1,0]]),
		'13':np.array([[1,0,1,0,1,0,0,1,0,1,1,0]])
		}

	chord_base = chord_list.get(chord_str,0)

	# The below is temporary, as we build the chord dictionary
	if type(chord_base) == type(0):
		chord_double = 'Add ' + chord_str + ' to the chord list.' 
	else:
		chord_double = numpy.matlib.repmat(chord_base,1,2)

	return chord_double

def note2num(note_str):
	""" The function NOTE2NUM takes in one string called 
	NOTE_STR and returns the tone number associated to the
	given note. """

	# Below is the note dictionary. We will add to this as 
	# we process each jazz standard. 
	note_list = {'C':0, 'C#': 1, 'D-':1, 'D':2, 'D#':3,
		'E-':3, 'E':4, 'E#':5, 'F-':4, 'F':5, 'F#':6, 
		'G-':6, 'G':7, 'G#':8, 'A-':8, 'A':9, 'A#':10,
		'B-':10, 'B':11, 'B#':0, 'C-':11}

	note_out = note_list.get(note_str,'None')

	if type(note_out) == type('None'):
		note_out = 'Add ' + note_str + ' to the note list.' 

	return note_out

def find_chord(chord_str, note_str):
	""" Find the tones for the given chord and base note.  """
	note_num = note2num(note_str)
	two_chords = chordshape(chord_str)

	return two_chords[:,(12-note_num):(24-note_num)].T