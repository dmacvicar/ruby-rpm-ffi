
# RPM bindings for ruby

![maintained](https://img.shields.io/maintenance/yes/2016.svg) [![Build Status](https://travis-ci.org/dmacvicar/ruby-rpm-ffi.svg?branch=master)](https://travis-ci.org/dmacvicar/ruby-rpm-ffi)
[![CI](https://github.com/dmacvicar/ruby-rpm-ffi/actions/workflows/ci.yaml/badge.svg)](https://github.com/dmacvicar/ruby-rpm-ffi/actions/workflows/ci.yaml)

* http://github.com/dmacvicar/ruby-rpm-ffi


# WARNING

This is an alpha release! There is still work to be done

# Quickstart

## Working with RPM package files

```ruby
require 'rpm'

pkg = RPM::Package.open("file.rpm")
pkg.arch => "x86_64"

pkg.files.each do |file|
  puts file.path
end

pkg.changelog.each do |entry|
  puts "#{entry.name} #{entry.time} #{entry.text}"
end
```

## Querying the rpm database

```ruby
require 'rpm'

RPM.transaction do |ts|
  ts.each do |pkg|
    puts pkg
  end
end
```

## Install a package

```ruby
require 'rpm'

pkg = RPM::Package.open('foo.rpm')

RPM.transaction(rootdir) do |t|
  t.install(pkg, 'foo.rpm')
  t.commit
end
```

## Introduction

This library is a replacement for the ruby-rpm gem, originally
writen by Kenta Murata around 2002 for the Kondara distribution. Later
mantained by David Lutterkort and myself.

Why?

* The original gem supports ancient rpm versions not in use anymore
* The original gem was written in C using MRI API
* The #ifdef'ing required to support multiple rpm versions made the code
  hard to maintain

This gem:

* Is pure ruby
* Is documented
* Has as a goal to support only the latest rpm version plus the ones in 
  use some releases back in popular rpm based distros
* Uses FFI, so it should work with other interpreters
  (Because https://github.com/rubinius/rubinius/issues/682 it currently does
  not work on Rubinius)
* Does not target rpm5, but it may support it someday

As an example the code that implements RPM::Package was reduced
from 1130 lines of code to 320.

# Architecture

The gem is divided in two modules:

* RPM::C:: which contains the 1:1 mapping to the librpm API
  Not all functions are attached, only the ones we actually use.
* RPM:: contains the actual higher level API

# Status, Compatibility and Differences with ruby-rpm

* Only rpm 4.11.x or later will be supported
* You can use symbols: instead of RPM::TAG_DESCRIPTION you
  can use just :description. 'rpm/compat' is by default loaded
  and provides compatibility with the RPM::TAG_* style constants
* RPM::DB is not supported. Use RPM::Transaction
* Spec and Source classes are not implemented yet

## TESTING

Unit tests can be run using the `rake test` command.

### Docker tests

In order to not damage your system, you can run the testsuite under docker:

* Build the docker images:

```console
rake docker_images
```

* Run the testsuite under Docker

```console
rake docker_test
```

## TODO

* Check Package#signature should return String?
    => ruby-rpm seems to return symbol
* Food for thought: Package dependencies and changelog
  methods could just use []. Calling headerGet directly saves
  us from doing one iteration per attribute
* Not sure if Spec can be implemented as it was before with
  newer rpms.

## API Checklist and TODO

### Low level 1:1 RPM::C API

* http://rpm.org/wiki/Releases/4.14.0
  - [ ] Add rpmfiVerify() and rpmfilesVerify()
  - [ ] Add pmsqPoll(), rpmsqActivate(), rpmsqSetAction(), rpmsqBlock()
  - [ ] Add rpmDigestBundleAddID()
  - [ ] Add RPMTRANS_FLAG_NOCAPS flag to disable file capabilities
  - [ ] Add RPMVSF_NOPAYLOAD flag to disable payload digest verification
  - [ ] Add pgpPubkeyKeyID()
  - [X] Add rpmPushMacro() and rpmPopMacro() (to replace addMacro() and delMacro())
  - [ ] Remove headerNVR(), headerNEVRA(), headerGetNEVR(), headerGetNEVRA(), headerGetEVR(), headerGetColor(), rpmfiMD5(), expandMacros(), addMacro(), delMacro()

* http://rpm.org/wiki/Releases/4.13.0
  - [ ] Add rpmsqSetInterruptSafety()
  - [ ] Add/Change rpmPkgSign()
  - [ ] Add RPMCALLBACK_ELEM_PROGRESS callback type
  - [ ] Add rpmExpandMacros()

* http://rpm.org/wiki/Releases/4.12.0
  - [ ] Add rpmtxnBegin() and rpmtxnEnd()
  - [ ] Add rpmtsImportHeader()
  - [ ] Add rpmtsAddReinstallElement()
  - [ ] Add rpmdbIndexIteratorNextTd()
  - [ ] Add file info set iterator functions: rpmfiFLinks(), rpmfiFindFN(), rpmfiStat()
  - [ ] Add rpmfiOFN(), rpmfiOBN(), rpmfiODN(), rpmfiFindOFN()
  - [ ] Add rpmteFiles()
  - [ ] Add rpmdsTagF(), rpmdsTagEVR(), rpmdsD(), rpmdsPutToHeader(), rpmdsTi(), rpmdsTagTi() and rpmdsSinglePoolTix()

* http://rpm.org/wiki/Releases/4.11.0
  - [ ] Add rpmstrPool object + associated functions
  - [ ] Add rpmIsGlob()
  - [ ] Add rpmtdToPool()
  - [ ] Add rpmGetArchColor()

### RPM

- [ ] RPM#expand
- [X] RPM#[]
- [X] RPM#[]=
- [ ] RPM#readrc
- [ ] RPM#init_macros
- [ ] RPM#verbosity
- [ ] RPM#verbosity=

### RPM::Package

- [X] Package#open
- [X] Package#new
- [X] Package#create
- [ ] Package#load
- [ ] Package#clear_cache
- [ ] Package#use_cache
- [X] Package#[]
- [ ] Package#delete_tag
- [X] Package#sprintf
    [?] Package#signature
- [X] Package#arch
- [X] Package#name
- [X] Package#version
- [X] Package#files
- [X] Package#provides
- [X] Package#requires
- [X] Package#conflicts
- [X] Package#obsoletes
- [X] Package#changelog
- [ ] Package#add_dependency
- [ ] Package#add_string
- [ ] Package#add_string_array
- [ ] Package#add_int32
- [ ] Package#dump
- [X] Package#to_s
- [ ] Package#inspect
- [ ] Package#copy_to

### RPM::Dependency

- [X] Dependency#initialize
- [X] Dependency#name
- [X] Dependency#version
- [X] Dependency#flags
- [X] Dependency#owner
- [X] Dependency#lt?
- [X] Dependency#gt?
- [X] Dependency#eq?
- [X] Dependency#le?
- [X] Dependency#ge?
- [X] Dependency#satisfy?
- [X] Dependency#nametag
- [X] Dependency#versiontag
- [X] Dependency#flagstag

### RPM::Provide

- [X] Provide#initialize

### RPM::Require

- [X] Require#initialize
- [ ] Require#pre?

### RPM::Conflict

- [X] Conflict#initialize

### RPM::Obsolete

- [X] Obsolete#initialize

### RPM::ChangeLog

- [X] ChangeLog#time
- [X] ChangeLog#name
- [X] ChangeLog#text

### RPM::Version

- [X] Version (Comparable)
- [X] Version#initialize
- [X] Version#<=>
- [X] Version#newer?
- [X] Version#older?
- [X] Version#v
- [X] Version#r
- [X] Version#e
- [X] Version#to_s
- [X] Version#to_vre
- [X] Version#inspect
- [X] Version#hash

### RPM::File

- [X] File#initialize
- [X] File#path
- [ ] File#to_s (alias path)
- [X] File#md5sum
- [X] File#link_to
- [X] File#size
- [X] File#mtime
- [X] File#owner
- [X] File#group
- [X] File#rdev
- [X] File#mode
- [X] File#attr
- [X] File#state
- [X] File#symlink?
- [X] File#config?
- [X] File#doc?
- [X] File#donotuse?
- [X] File#missingok?
- [X] File#specfile?
- [X] File#ghost?
- [X] File#license?
- [X] File#readme?
- [X] File#exclude?
- [X] File#replaced?
- [X] File#notinstalled?
- [X] File#netshared?

### RPM::DB

- [ ] DB (Enumerable)
- [ ] DB#new
- [ ] DB#open
- [ ] DB#init
- [ ] DB#rebuild
- [ ] DB#close
- [ ] DB#closed?
- [ ] DB#root
- [ ] DB#home
- [ ] DB#writable?
- [ ] DB#each_match
- [ ] DB#each
- [ ] DB#transaction
- [ ] DB#init_iterator
- [ ] DB#dup
- [ ] DB#clone

### RPM::MatchIterator

- [X] MatchIterator (Enumerable)
- [X] MatchIterator#each
- [X] MatchIterator#next_iterator
- [X] MatchIterator#offset
- [X] MatchIterator#set_iterator_re
- [X] MatchIterator#regexp
- [X] MatchIterator#set_iterator_version
- [X] MatchIterator#version
- [X] MatchIterator#get_iterator_count
- [X] MatchIterator#length

### RPM::Transaction

- [ ] Transaction#db
- [ ] Transaction#script_file
- [ ] Transaction#script_file=
- [ ] Transaction#install
- [ ] Transaction#upgrade
- [ ] Transaction#available
- [ ] Transaction#delete
- [ ] Transaction#check
- [ ] Transaction#order
- [ ] Transaction#keys
- [ ] Transaction#commit
- [ ] Transaction#abort
- [ ] Transaction#dup
- [ ] Transaction#clone

### RPM::Source

- [ ] Source#initialize
- [ ] Source#fullname
- [ ] Source#to_s (alias fullname)
- [ ] Source#num
- [ ] Source#no?

### RPM::Patch

### RPM::Icon

### RPM::Spec

- [ ] Spec#open
- [ ] Spec#new
- [ ] Spec#buildroot
- [ ] Spec#buildsubdir
- [ ] Spec#buildarchs
- [ ] Spec#buildrequires
- [ ] Spec#build_restrictions
- [ ] Spec#sources
- [ ] Spec#packages
- [ ] Spec#build
- [ ] Spec#expand_macros
- [ ] Spec#dup
- [ ] Spec#clone

# LICENSE

* Copyright © 2011 Duncan Mac-Vicar Prett <dmacvicar@suse.de>
* Copyright © 2011 SUSE Linux Products GmbH

* This gem is a pure-ruby rewrite of ruby-rpm:
  Copyright © 2002 Kenta Murata. Relicensed with his permission.

Licensed under the MIT license. See MIT-LICENSE for details.

