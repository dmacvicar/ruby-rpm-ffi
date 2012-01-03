
module RPM

  class DB

    # @visibility private
    # @param ts [Transaction] transaction object
    def initialize(ts)
      @ts = ts
      RPM::FFI.rpmtsOpenDB(@ts.ptr, 0)
    end

    # @visibility private
    def ptr
      RPM::FFI.rpmtsGetRdb(@ts.ptr)
    end

    def close
      RPM::FFI.rpmtsCloseDB(@ts.ptr)
    end

    def closed?
      ptr.null?
    end

    def self.open
      open_for_transaction(Transaction.new)
    end

    # @visibility private
    def self.open_for_transaction(ts)
      db = new(ts)
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
      RPM::FFI.rpmtsRootDir(@ts.ptr)
    end

    # @deprecated Use RPM::Transaction#each
    def self.each
      DB.open do |db|
        it = MatchIterator.from_ptr(RPM::FFI.rpmdbInitIterator(db.ptr, 0, nil, 0))
        if block_given?
          it.each do |pkg|
            yield pkg
          end
        end
      end
    end

    # @return number of instances of +name+ in the
    # database
    def count_packages(name)
    end

    

  end

end