#!/usr/bin/python

# imports
import getopt
import os
import sys
import pandas as pd

def main(argv):
	# set
	input_file = None
	output_file = None

	# read input and output files
	opts, _ = getopt.getopt(argv,"i:o:")
	for opt, arg in opts:
		if opt == "-i":
			input_file = arg
		elif opt == "-o":
			output_file = arg

	# error out
	if input_file is None or output_file is None:
		print("ERROR: Input (-i) or output (-o) not provided!")
		sys.exit(1)

	# load data
	if os.path.exists(input_file):
		df = pd.read_csv(input_file)
	else:
		print("ERROR: Input file [%s] does not exist!" % input_file)
		sys.exit(2)

	# sum
	sum = 0
	for _, row in df.iterrows():
		sum = sum + row[0] + row[1]

	# save the result in output file
	f = open(output_file, "a")
	f.write("Sum = %s\n" % sum)
	f.close()

if __name__ == "__main__":
	main(sys.argv[1:])
