
module RPM

  class File

    def initialize(path, md5sum, link_to, size, mtime, owner, group, rdev, mode, attr, state)
      @path = path
      @md5sum = md5sum
      @link_to = link_to
      @size = size
      @mtime = mtime
      @owner = owner
      @group = group
      @rdev = rdev
      @mode = mode
      @attr = attr
      @state = state
    end

    
  
end
end
