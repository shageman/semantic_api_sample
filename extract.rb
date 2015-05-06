require 'bundler/setup'
require 'fileutils'
require 'mail'
require 'pathname'

input_root  = Pathname.new('enron_mail_20110402/maildir')
output_root = Pathname.new('extracted')

# emails are available for only 4 of the 10 key players involved in the Enron scandal
# http://www.nytimes.com/2006/01/29/business/businessspecial3/29profiles.html?pagewanted=all&_r=0
people = ['kaminski-v', 'lay-k', 'skilling-j', 'whalley-g', 'kaminski-v']
mail_folder = 'sent'

people.each do |person|
  input_folder  = input_root.join(person).join(mail_folder)
  output_folder = output_root.join(person).join(mail_folder)
  FileUtils.mkdir_p output_folder

  input_folder.each_child do |input_path|
    puts "extracting email at path: #{input_path}"
    mail = Mail.read(input_path)
    output_path = output_folder.join(input_path.basename)
    File.open(output_path, "w") do |file|
      file.write(mail.body.decoded)
    end
  end
end

