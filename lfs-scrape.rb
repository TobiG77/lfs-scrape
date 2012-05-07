#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'awesome_print'

# async would be nice, but that would mean we loose order, right?
# or we enumerate articles quickly and then set of async fetching

@lfs_branch = 'stable'

# set smp flags based on a conversation with Con Kolivas 
@smp_mflags = "-j`awk '/^processor/ { N++} END { print N*3 }' /proc/cpuinfo`"

@output_dir = '/tmp/lfs/' + @lfs_branch + '/' + Time.now.strftime("%F")
@lfs_base_url = "http://www.linuxfromscratch.org/lfs/view/"
@lfs_index_url = @lfs_base_url + @lfs_branch

# likely to be further abstracted, but let's keep it KISS for now

def extract_chapter(article)
  article_url = @lfs_base_url + "/#{@lfs_branch}/" + article
  puts "fetching : #{article_url} .. "
  article_content= Nokogiri::HTML(open(article_url))

  script = Array.new
  article_content.css('pre.userinput').each {|my_match|script << my_match.content}
  
  script = NIL unless script.size > 0
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

    f.write("cd #{@script_prefix}/sources\n")
    f.write("tar_name=`ls #{pkg_name}*tar.*`\n")
    f.write("if [ -n \"$tar_name\" ]\n")
    f.write("then\n")
    f.write("  cd #{@script_prefix}/builds\n")
    f.write("  tar -xf #{@script_prefix}/sources/$tar_name\n")
    f.write("  dir_name=`tar -tf #{@script_prefix}/sources/$tar_name | head -n 1|awk -F'/' '{print $1}'`\n")
    f.write("  cd $dir_name\n")
    f.write("fi\n")
    
    @script_code.each {|line|
                       line = "make #{@smp_mflags}" if line == "make"
                       line = line.gsub(/patch -Np1 -i ../, "patch -Np1 -i #{@script_prefix}/sources")
                       line = line.gsub(/tar -[a-zA-Z]* ../, "tar -xf #{@script_prefix}/sources")
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
    if node.values.first.match(/chapter0[5,6]/)
      @chapter = node.values.first.split('/').first
      if @chapter == 'chapter05'
	@script_prefix = '/mnt/lfs'
      elsif @chapter == 'chapter06'
	@script_prefix = ''
      end
      @script_dir = @output_dir + '/' + @chapter
      FileUtils.mkdir_p(@script_dir) unless Dir.exists?(@script_dir)
      @script_code = extract_chapter node.values.first
#       ap @script_code
      write_out_script node.text if @script_code
    end
  end
  
end
