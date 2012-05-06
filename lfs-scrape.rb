#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'awesome_print'

@lfs_branch = 'stable'
@smp_mflags = '-j24'




@output_dir = '/tmp/lfs/' + @lfs_branch + '/' + Time.now.strftime("%F")

@lfs_base_url = "http://www.linuxfromscratch.org/lfs/view/"
@lfs_index_url = @lfs_base_url + @lfs_branch

# likely to be further abstracted, but let's keep it KISS for now

def extract_chapter5(chapter)
  script = Array.new
#   puts "one more entry to chapter 5:"
  chapter_url = @lfs_base_url + "/#{@lfs_branch}/" + chapter
  puts "fetching : #{chapter_url} .. "
  chapter = Nokogiri::HTML(open(chapter_url))
  chapter.css('pre.userinput').each {|my_match|script << my_match.content}
  script
end

def write_out_script(node_title)
  padded_cnt = sprintf '%03d', @script_cnt.to_s 
  script_name = node_title.downcase!.gsub(/\n/," ").strip
  filename = @script_dir + '/' + padded_cnt + '-' + script_name.squeeze(" ").gsub(/ /, '') + '.sh'
  pkg_name = node_title.split(" -").first.split(' ').first.strip.gsub(/[^a-zA-Z0-9]/, '*')
  puts "writing  : #{filename}"
  script_file = File.open(filename, "w") do |f|
    f.write("#!/tools/bin/bash -xe\n")
    f.write("# #{script_name}\n")

    f.write("cd /mnt/lfs/sources\n")
    f.write("tar_name=`ls #{pkg_name}*tar.*`\n")
    f.write("if [ -n \"$tar_name\" ]\n")
    f.write("then\n")
    f.write("  cd /mnt/lfs/builds\n")
    f.write("  tar -xf /mnt/lfs/sources/$tar_name\n")
    f.write("  dir_name=`tar -tf /mnt/lfs/sources/$tar_name | head -n 1|awk -F'/' '{print $1}'`\n")
    f.write("  cd $dir_name\n")
    f.write("fi\n")
    
    @script_code.each {|line|
                       line = "make #{@smp_mflags}" if line == "make"
                       line = line.gsub(/patch -Np1 -i ../, 'patch -Np1 -i /mnt/lfs/sources')
                       line = line.gsub(/tar -[a-zA-Z]* ../, 'tar -xf /mnt/lfs/sources')
                       line.strip!
                       f.write("#{line}\n")
                      }
  end
  @script_cnt = @script_cnt + 1

end

doc = Nokogiri::HTML(open(@lfs_index_url))

@script_cnt = 1

doc.xpath('//li/a').each do |node|
  
  if node.key?('href') && node.values.first.match('chapter0')
#     puts "Shall we extract #{node.text} ? ..."
    if node.values.first.match('chapter05')
      @script_dir = @output_dir + '/chapter05'
      FileUtils.mkdir_p(@script_dir) unless Dir.exists?(@script_dir)
      @script_code = extract_chapter5 node.values.first 
      write_out_script node.text if @script_code
    end
  end
  
end

    