require 'bundler/setup'
require 'fileutils'
require 'mail'
require 'pathname'

input_root  = Pathname.new('enron_mail_20110402/maildir')
output_root = Pathname.new('sample_emails')

people = ['kaminski-v', 'lay-k', 'skilling-j', 'whalley-g']
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

