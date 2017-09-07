require 'fcntl'

module RPM
  class DB
    include Enumerable

    # @visibility private
    # @param ts [Transaction] transaction object
    def initialize(ts, opts = {})
      opts[:writable] ||= false

      @ts = ts
      RPM::C.rpmtsOpenDB(@ts.ptr, opts[:writable] ? Fcntl::O_RDWR | Fcntl::O_CREAT : Fcntl::O_RDONLY)
    end

    # @return [RPM::MatchIterator] Creates an iterator for +tag+ and +val+
    def init_iterator(tag, val)
      @ts.init_iterator(tag, val)
    end

    #
    # @yield [Package] Called for each match
    # @param [Number] key RPM tag key
    # @param [String] val Value to match
    # @example
    #   RPM.transaction do |t|
    #     t.each_match(RPM::TAG_ARCH, "x86_64") do |pkg|
    #       puts pkg.name
    #     end
    #   end
    #
    def each_match(key, val, &block)
      @ts.each_match(key, val, &block)
    end

    #
    # @yield [Package] Called for each package in the database
    # @example
    #   db.each do |pkg|
    #     puts pkg.name
    #   end
    #
    def each(&block)
      @ts.each(&block)
    end

    # @visibility private
    def ptr
      RPM::C.rpmtsGetRdb(@ts.ptr)
    end

    def close
      RPM::C.rpmtsCloseDB(@ts.ptr)
    end

    def closed?
      ptr.null?
    end

    #
    # The package database is opened, but transactional processing
    # (@see RPM::DB#transaction) cannot be done for when +writable+ is false.
    # When +writable+ is +false+ then the generated object gets freezed.
    # @param [Boolean] writable Whether the database is writable. Default is +false+.
    # @param [String] root Root path for the database, default is empty.
    # @return [RPM::DB]
    #
    # @example
    #   db = RPM::DB.open
    #   db.each do |pkg|
    #     puts pkg.name
    #   end
    #
    def self.open(_writable = false, root = '/', &block)
      open_for_transaction(Transaction.new(root: root), writable: false, &block)
    end

    # @visibility private
    def self.open_for_transaction(ts, opts = {})
      db = new(ts, opts)
      return db unless block_given?

      begin
        yield db
      ensure
        db.close unless db.closed?
      end
    end

    # @deprecated Not possible to get home value in
    #   newer RPM versions
    def home
      raise NotImplementedError
    end

    # @return [String] The root path of the database
    def root
      RPM::C.rpmtsRootDir(@ts.ptr)
    end

    # @deprecated Use RPM::Transaction#each
    def self.each
      DB.open do |db|
        it = MatchIterator.from_ptr(RPM::C.rpmdbInitIterator(db.ptr, 0, nil, 0))
        if block_given?
          it.each do |pkg|
            yield pkg
          end
        end
      end
    end

    # @return number of instances of +name+ in the
    # database
    def count_packages(name); end
  end
end
