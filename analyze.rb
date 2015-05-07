$:.unshift File.dirname(__FILE__)
require 'bundler/setup'
require 'client'
require 'optparse'
require 'pathname'
require 'twitter'
require 'awesome_print'

# twitter_client = Twitter::REST::Client.new do |config|
#   config.consumer_key = "YaCpwZ5AKC2ZXJe9NwVsva6hy"
#   config.consumer_secret = "tgu5PDtQTjAXJ5ru6BBYCulHj6pVKs4z8bINpx3VQflWQTj3kL"
#   config.access_token = "14946422-sH0QrisSMCx2xJymf8jk3VaIDTlFNmKJ3SOedA4fd"
#   config.access_token_secret = "kuHqPuwq2y80mOVabsEOk1fkQS58PmEijC1LvrBuXmNYP"
# end
twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key = "F1a3zWbDH2kmVEySPh08bLBw8"
  config.consumer_secret = "boWwZxDc7Yn2U6mKTKjNQeq4DuhEmmLy1pM2QKyNQXFhiOP2g9"
  config.access_token = "14946422-jiVHdIvDXiqfBESOfkvEXfVrV22tPdMRN8SrmnUVJ"
  config.access_token_secret = "tbkImDLizATNqh6Fln3bZW4oNZWRww8hiKzc3aegpPXAZ"
end

texts = []
$id = 0

term = "carly fiorina"

def language_tweets(term, language, texts, twitter_client)
  twitter_client.search(term, lang: language, result_type: "recent", count: 100).each do |tweet|
    texts << {id: "#{$id}", text: tweet.text}
    $id += 1
  end
end

["fr", "de", "nl"].each do |lang|
  language_tweets(term, lang, texts, twitter_client)
end

puts "Tweets found: #{texts.size}"


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
      documents << {id: file, text: contents}
    end
  else
    contents = read_text_file(file)
    documents << {id: file_path, text: contents}
  end

  documents
end


options = {}
options[:host_url] = "http://localhost:3000"
options[:api_key] = "1234"
options[:customer_id] = "1"

OptionParser.new do |opts|
  opts.banner = "Usage: ruby analyze.rb [options] document_path OR document_dir_path"

  opts.on("-b", "--base_url URL", "Base url of the service") do |base_url|
    options[:host_url] = base_url
  end
  opts.on("-k", "--key KEY", "API key") do |api_key|
    options[:api_key] = api_key
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

  options[:language_tag] = nil
  opts.on("-l", "--language language_tag", "Language tag for all documents,  overrides language detection") do |lt|
    options[:language_tag] = lt
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

puts "Looking for sentiment..."

client = Client.new(options[:host_url], options[:api_key])
analyzed = client.analyze_documents(texts.take(1000), options[:customer_id], options[:enrichments])

res = analyzed["documents"].map do |doc|
  doc["sentiment"]
end.compact.map do |sentiment|
  sentiment["name"]
end

sentiment_counts = res.group_by { |sentiment| sentiment }

p ["positive", sentiment_counts["positive"].size]
p ["neutral", sentiment_counts["neutral"].size]
p ["negative", sentiment_counts["negative"].size]

# puts JSON.pretty_generate(analyzed)
