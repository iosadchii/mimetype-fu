require 'tempfile'
require 'extensions_const'

class File

  def self.mime_type(file)
    case file
    when File, Tempfile
      mime = `file --mime-type -br "#{file.path}"`.strip unless RUBY_PLATFORM.include? 'mswin32'
      mime = EXTENSIONS[File.extname(file.path).gsub('.','').downcase.tap{|str| str.empty? ? str : str.to_sym}] if mime == 'application/octet-stream' || mime.nil?
    when String
      mime = EXTENSIONS[(file[file.rindex('.')+1, file.size]).downcase] unless file.rindex('.').nil?
    when StringIO
      temp = File.open(Dir.tmpdir + '/upload_file.' + Process.pid.to_s, 'wb')
      temp << file.string
      temp.close
      mime = `file --mime-type -br "#{temp.path}"`
      mime = mime.gsub(/^.*: */,"")
      mime = mime.gsub(/;.*$/,"")
      mime = mime.gsub(/,.*$/,"")
      File.delete(temp.path)
    when ActionDispatch::Http::UploadedFile
      mime = `file --mime-type -br "#{file.tempfile.path}"`.strip unless RUBY_PLATFORM.include? 'mswin32'
      mime = EXTENSIONS[File.extname(file.original_filename).gsub('.','').downcase.to_sym] if mime == 'application/octet-stream' || mime.nil?
    end
    
    return mime || 'unknown/unknown'
   end

  def self.extensions
    EXTENSIONS
  end

end
