begin
  puts "\n\n=========================================================="
  puts "Installing views for S_Tings plugin..."

  require 'fileutils'

  @views_path = 'app/views/settings'
  unless File.exists?("#{File.dirname(__FILE__)}/../../../#{@views_path}")
    FileUtils.mkdir("#{File.dirname(__FILE__)}/../../../#{@views_path}")
    %w{_settings_list.html.erb index.html.erb}.each do |file|
      FileUtils.cp "#{File.dirname(__FILE__)}/lib/defaults/#{file}", "#{File.dirname(__FILE__)}/../../../#{@views_path}"
    end

    %w{settings_defaults.rb}.each do |file|
      FileUtils.cp "#{File.dirname(__FILE__)}/lib/defaults/#{file}", "#{File.dirname(__FILE__)}/../../../config"
    end

  else
    puts "Already in place!"
  end

  puts "Success!"
  puts "=========================================================="
rescue Exception => ex
  raise ex
end

begin
  puts "\n\n=========================================================="
  puts "Attempting to install s_tings's routes in your application..."

  def gsub_file(relative_destination, regexp, *args, &block)
    path =  "#{File.dirname(__FILE__)}/../../../config/routes.rb"
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) } unless File.read(path) =~ /map.s_tings/
  end

  #FIXME Check if route has been installed indeed
  sentinel = 'ActionController::Routing::Routes.draw do |map|'
  gsub_file('routes.rb', /(#{Regexp.escape(sentinel)})/mi) do |match|
    "#{match}\n map.s_tings \n"
  end

  puts "Success!"
  puts "=========================================================="
rescue Exception => ex
  puts "FAILED TO INSTALL REQUIRED STINGS's ROUTES."
  puts "EXCEPTION: #{ex}"
end
