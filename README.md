# Getting Started with the Semantic API
This repo has code and data samples for using the Semantic API.


## Submitting Documents for Analysis
The Ruby script `analyze.rb` analyzes all the text files in a specified folder:

    ruby analyze.rb -b SERVICE_URL -k API_KEY -c CUSTOMER_ID path/to/document/folder

You can also analyze a single text document like this:

    ruby analyze.rb -b SERVICE_URL -k API_KEY -c CUSTOMER_ID path/to/document.txt


## Sample Data

This repository includes sample emails extracted from the Enron dataset. The sample emails are for 4 of the 10 key people mentioned in this article:
http://www.nytimes.com/2006/01/29/business/businessspecial3/29profiles.html?pagewanted=all&_r=0

You can download the full Enron dataset from:
https://www.cs.cmu.edu/~./enron/enron_mail_20110402.tgz

The extraction script `extract.rb` can be used to extract the
e-mail body text for a list of people - see the source code for details.

		ruby extract.rb

