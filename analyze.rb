$:.unshift File.dirname(__FILE__)
require 'bundler/setup'
require 'client'
require 'optparse'
require 'pathname'

def read_text_file(file)
  contents = File.open(file, "r").read
  contents.encode('UTF-8', :undef => :replace, :invalid => :replace, :replace => "")
end

def read_documents(file_path)
  documents = []

  if file_path.directory?
    Dir[file_path.join("*")].each do |file|
      next unless File.file?(file)

      contents = read_text_file(file)
      documents << { id: file, text: contents }
    end
  else
    contents = read_text_file(file)
    documents << { id: file_path, text: contents }
  end

  documents
end


options = {}
options[:host_url]    = "http://localhost:3000"
options[:api_key]     = "1234"
options[:customer_id] = "1"

OptionParser.new do |opts|
  opts.banner = "Usage: ruby analyze.rb [options] document_path OR document_dir_path"

  opts.on("-b", "--base_url URL", "Base url of the service") do |base_url|
    options[:host_url] = base_url
  end
  opts.on("-k", "--key KEY", "API key") do |api_key|
    options[:api_key]  = api_key
  end
  opts.on("-c", "--customer CUSTOMER_ID", "Customer ID") do |customer_id|
    options[:customer_id] = customer_id
  end

  options[:enrichments] = [
    "language_identification",
    "categorization",
    "semantic_tagging",
    "sentiment_analysis",
    "theming",
    "top_terms"
  ]

  options[:language_tag]    = nil
  opts.on("-l", "--language language_tag", "Language tag for all documents,  overrides language detection") do |lt|
    options[:language_tag]  = lt
  end
end.parse!


if ARGV.length < 1
  puts "please specify an input directory or a path to a document to be analyzed"
  exit(0)
end

input_path = Pathname.new(ARGV[0])
if !input_path.directory? && !(input_path.file? && input_path.extname.downcase == ".json")
  STDERR.puts "please specify a valid directory path or a json request path"
  exit(1)
end

documents = read_documents(input_path)
unless options[:language_tag].nil?
  documents.each { |d| d[:languageTag] = options[:language_tag] }
end

client = Client.new(options[:host_url], options[:api_key])
analyzed = client.analyze_documents(documents, options[:customer_id], options[:enrichments])
puts JSON.pretty_generate(analyzed)
