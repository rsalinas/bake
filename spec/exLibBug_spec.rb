#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "..in ex lib" do

  it 'with search=true' do
    Bake.startBake("exLibBug/sub", ["-b", "Debug", "--rebuild"])
    expect(($mystring.split("Rebuilding done.").length)).to be == 2

    Bake.startBake("exLibBug/main", ["-b", "test1", "--rebuild"])
    expect(($mystring.split("Rebuilding done.").length)).to be == 3
  end

  it 'with search=false' do
    Bake.startBake("exLibBug/sub", ["-b", "Debug", "--rebuild"])
    expect(($mystring.split("Rebuilding done.").length)).to be == 2

    Bake.startBake("exLibBug/main", ["-b", "test2", "--rebuild"])
    expect(($mystring.split("Rebuilding done.").length)).to be == 3
  end

  it 'with searchPath' do
    Bake.startBake("exLibBug/sub", ["-b", "Debug", "--rebuild"])
    expect(($mystring.split("Rebuilding done.").length)).to be == 2

    Bake.startBake("exLibBug/main", ["-b", "test3", "--rebuild"])
    expect(($mystring.split("Rebuilding done.").length)).to be == 3
  end

end

end
