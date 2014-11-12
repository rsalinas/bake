#!/usr/bin/env ruby



require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'bake/util'
require 'imported/utils/exit_helper'
require 'socket'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

ExitHelper.enable_exit_test

describe "Makefile" do

  before(:each) do
    Utils.cleanup_rake
    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  
  after(:each) do
    $stdout=$stdoutbackup
    ExitHelper.reset_exit_code
    Utils.cleanup_rake
  end

  it 'builds' do
    options = Options.new(["-m", "spec/testdata/make/main", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect($mystring.include?("make all -j")).to be == true
    expect($mystring.include?("Build done.")).to be == true
  end
  
  it 'cleans' do
    options = Options.new(["-m", "spec/testdata/make/main", "test", "-c"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect($mystring.include?("Clean done.")).to be == true
  end
  
end

end
