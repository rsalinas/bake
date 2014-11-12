#!/usr/bin/env ruby



require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

ExitHelper.enable_exit_test

def self.cleanMergeOutput()
  SpecHelper.clean_testdata_build("merge","main","L1")
  SpecHelper.clean_testdata_build("merge","main","L2")
  SpecHelper.clean_testdata_build("merge","main","L3")
  SpecHelper.clean_testdata_build("merge","main","L4")
  SpecHelper.clean_testdata_build("merge","main","L5")
  SpecHelper.clean_testdata_build("merge","main","L6")
  SpecHelper.clean_testdata_build("merge","main","E1")
  SpecHelper.clean_testdata_build("merge","main","E2")
  SpecHelper.clean_testdata_build("merge","main","E3")
  SpecHelper.clean_testdata_build("merge","main","E4")
  SpecHelper.clean_testdata_build("merge","main","E5")
  SpecHelper.clean_testdata_build("merge","main","E6")
  SpecHelper.clean_testdata_build("merge","main","C1")
  SpecHelper.clean_testdata_build("merge","main","C2")
  SpecHelper.clean_testdata_build("merge","main","C3")
  SpecHelper.clean_testdata_build("merge","main","C4")
  SpecHelper.clean_testdata_build("merge","main","C5")
  SpecHelper.clean_testdata_build("merge","main","C6")
  SpecHelper.clean_testdata_build("merge","main","C5E")
  SpecHelper.clean_testdata_build("merge","main","L3E")
  SpecHelper.clean_testdata_build("merge","main","L5E")
  SpecHelper.clean_testdata_build("merge","main","L6E")  
end

describe "Merging Configs" do
  
  before(:all) do
  end

  after(:all) do
  end

  before(:each) do
    Utils.cleanup_rake
    Bake::cleanMergeOutput()

    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  
  after(:each) do
    $stdout=$stdoutbackup

    Bake::cleanMergeOutput()
    ExitHelper.reset_exit_code
  end

  it 'build base (all)' do
    expect(File.exists?("spec/testdata/merge/main/L1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/L2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/L3/libmain.a")).to be == false

    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L1", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/merge/main/L1/libmain.a")).to be == true
    expect(File.exists?("spec/testdata/merge/main/L2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/L3/libmain.a")).to be == false
  end  

  it 'build child (all)' do
    expect(File.exists?("spec/testdata/merge/main/L1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/L2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/L3/libmain.a")).to be == false

    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L2", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/merge/main/L1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/L2/libmain.a")).to be == true
    expect(File.exists?("spec/testdata/merge/main/L3/libmain.a")).to be == false
  end  
    
  it 'build grandchild (all)' do
    expect(File.exists?("spec/testdata/merge/main/L1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/L2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/L3/libmain.a")).to be == false

    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L3", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/merge/main/L1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/L2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/L3/libmain.a")).to be == true
  end  
  
  it 'file and exclude file (all)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L3", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect($mystring.include?("testL1.cpp")).to be == true
    expect($mystring.include?("testL2.cpp")).to be == true
    expect($mystring.include?("testL3.cpp")).to be == true
    expect($mystring.include?("ex.cpp")).to be == false
  end    
  
  it 'file and exclude file (child)' do
    expect(File.exists?("spec/testdata/merge/main/L5/libmain.a")).to be == false
        
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L5", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect($mystring.include?("testL5.cpp")).to be == true
    expect(File.exists?("spec/testdata/merge/main/L5/libmain.a")).to be == true    
  end    

  it 'file and exclude file (parent)' do
    expect(File.exists?("spec/testdata/merge/main/L6/libmain.a")).to be == false
        
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L6", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect($mystring.include?("testL1.cpp")).to be == true
    expect(File.exists?("spec/testdata/merge/main/L6/libmain.a")).to be == true    
  end    
  
  
  it 'deps (all)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L3", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    posdep11 = $mystring.index("depL1_1 (lib)")
    posdep12 = $mystring.index("depL1_2 (lib)")
    posdep21 = $mystring.index("depL2_1 (lib)")
    posdep22 = $mystring.index("depL2_2 (new)")
    posdep31 = $mystring.index("depL3_1 (lib)")
    posdep32 = $mystring.index("depL3_2 (lib)")
    
    expect((posdep11 < posdep12)).to be == true
    expect((posdep12 < posdep21)).to be == true
    expect((posdep21 < posdep22)).to be == true
    expect((posdep22 < posdep31)).to be == true
    expect((posdep31 < posdep32)).to be == true
    
    expect($mystring.include?("depL2_2 (lib)")).to be == false
  end    

  it 'deps (child)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L5", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    posdep51 = $mystring.index("depL5_1")
    posdep52 = $mystring.index("depL5_2")
    
    expect((posdep51 < posdep52)).to be == true
  end    

  it 'deps (parent)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L6", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    posdep11 = $mystring.index("depL1_1")
    posdep12 = $mystring.index("depL1_2")
    
    expect((posdep11 < posdep12)).to be == true
  end    
  
  it 'libs (all)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L3E", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    posExe  = $mystring.index("main.exe")
    pos1  = $mystring.index("-Llib",posExe)
    pos2  = $mystring.index("L1_1",posExe)
    pos3  = $mystring.index("blah1",posExe)
    pos4  = $mystring.index("L1_2",posExe)
    pos5  = $mystring.index("L2_1",posExe)
    pos6  = $mystring.index("blah2",posExe)
    pos7  = $mystring.index("L2_2",posExe)
    pos8  = $mystring.index("L3_1",posExe)
    pos9  = $mystring.index("blah3",posExe)
    pos10 = $mystring.index("L3_2",posExe)
    
    expect((pos1 < pos2)).to be == true
    expect((pos2 < pos3)).to be == true
    expect((pos3 < pos4)).to be == true
    expect((pos4 < pos5)).to be == true
    expect((pos5 < pos6)).to be == true
    expect((pos6 < pos7)).to be == true
    expect((pos7 < pos8)).to be == true
    expect((pos8 < pos9)).to be == true
    expect((pos9 < pos10)).to be == true

  end     
  
  it 'libs (child)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L5E", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    posExe  = $mystring.index("main.exe")
    pos1  = $mystring.index("-Llib",posExe)
    pos2  = $mystring.index("L5_1",posExe)
    pos3  = $mystring.index("blah5",posExe)
    pos4  = $mystring.index("L5_2",posExe)
    
    expect((pos1 < pos2)).to be == true
    expect((pos2 < pos3)).to be == true
    expect((pos3 < pos4)).to be == true
  end   

  it 'libs (parent)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L6E", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    posExe  = $mystring.index("main.exe")
    pos1  = $mystring.index("-Llib",posExe)
    pos2  = $mystring.index("L1_1",posExe)
    pos3  = $mystring.index("blah1",posExe)
    pos4  = $mystring.index("L1_2",posExe)
    
    expect((pos1 < pos2)).to be == true
    expect((pos2 < pos3)).to be == true
    expect((pos3 < pos4)).to be == true
  end 
  
  
  it 'steps (all)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L3", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    posPre1_1  = $mystring.index( "Pre1_1")
    posPre1_2  = $mystring.index( "Pre1_2")
    posPre2_1  = $mystring.index( "Pre2_1")
    posPre2_2  = $mystring.index( "Pre2_2")
    posPre3_1  = $mystring.index( "Pre3_1")
    posPre3_2  = $mystring.index( "Pre3_2")
    posPst1_1  = $mystring.index("Post1_1")
    posPst1_2  = $mystring.index("Post1_2")
    posPst2_1  = $mystring.index("Post2_1")
    posPst2_2  = $mystring.index("Post2_2")
    posPst3_1  = $mystring.index("Post3_1")
    posPst3_2  = $mystring.index("Post3_2")
    
    expect((posPre1_1 < posPre1_2)).to be == true
    expect((posPre1_2 < posPre2_1)).to be == true
    expect((posPre2_1 < posPre2_2)).to be == true
    expect((posPre2_2 < posPre3_1)).to be == true
    expect((posPre3_1 < posPre3_2)).to be == true
    expect((posPre3_2 < posPst1_1)).to be == true
    expect((posPst1_1 < posPst1_2)).to be == true
    expect((posPst1_2 < posPst2_1)).to be == true
    expect((posPst2_1 < posPst2_2)).to be == true
    expect((posPst2_2 < posPst3_1)).to be == true
    expect((posPst3_1 < posPst3_2)).to be == true
  end  
  
  
  it 'steps (child)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L5", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    posPre5_1  = $mystring.index( "Pre5_1")
    posPre5_2  = $mystring.index( "Pre5_2")
    posPst5_1  = $mystring.index("Post5_1")
    posPst5_2  = $mystring.index("Post5_2")
    
    expect((posPre5_1 < posPre5_2)).to be == true
    expect((posPre5_2 < posPst5_1)).to be == true
    expect((posPst5_1 < posPst5_2)).to be == true
  end  
  
  it 'steps (parent)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L6", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    posPre1_1  = $mystring.index( "Pre1_1")
    posPre1_2  = $mystring.index( "Pre1_2")
    posPst1_1  = $mystring.index("Post1_1")
    posPst1_2  = $mystring.index("Post1_2")
    
    expect((posPre1_1 < posPre1_2)).to be == true
    expect((posPre1_2 < posPst1_1)).to be == true
    expect((posPst1_1 < posPst1_2)).to be == true
  end    
  
  
  it 'defaulttoolchain (all)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L3E", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == false
    expect($mystring.include?("def2")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end    
  
  it 'defaulttoolchain (child)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L5E", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == false
    expect($mystring.include?("def5")).to be == true
    expect($mystring.include?("-O3")).to be == false
  end    
  
  it 'defaulttoolchain (parent)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "L6E", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end    
  
  # Valid for custom config
  
  it 'step (all)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "C3", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("C1")).to be == false
    expect($mystring.include?("C2")).to be == false
    expect($mystring.include?("C3")).to be == true
  end    

  it 'step (child)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "C5", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("C5")).to be == true
  end      

  it 'step (parent)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "C6", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("C1")).to be == true
  end      

  it 'step (exe extends custom)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "C5E", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("C5")).to be == true
  end      
  
  it 'step (custom extends exe)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "C7", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("C7")).to be == true
  end      
    
            
  # Valid for library and exe config
        
  it 'includedir (all)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "E3", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    posinc11 = $mystring.index("Inc1_1")
    posinc12 = $mystring.index("Inc1_2")
    posinc21 = $mystring.index("Inc2_1")
    posinc22 = $mystring.index("Inc2_2")
    posinc31 = $mystring.index("Inc3_1")
    posinc32 = $mystring.index("Inc3_2")
    
    expect((posinc11 < posinc12)).to be == true
    expect((posinc12 < posinc21)).to be == true
    expect((posinc21 < posinc22)).to be == true
    expect((posinc22 < posinc31)).to be == true
    expect((posinc31 < posinc32)).to be == true
  end    
  
  it 'includedir (child)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "E5", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    posinc51 = $mystring.index("Inc5_1")
    posinc52 = $mystring.index("Inc5_2")
    
    expect((posinc51 < posinc52)).to be == true

  end    
  
  it 'includedir (parent)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "E6", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    posinc11 = $mystring.index("Inc1_1")
    posinc12 = $mystring.index("Inc1_2")
    
    expect((posinc11 < posinc12)).to be == true
  end   

  it 'toolchain (all)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "E3", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == false
    expect($mystring.include?("def2")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end    
  
  it 'toolchain (child)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "E5", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == false
    expect($mystring.include?("def5")).to be == true
    expect($mystring.include?("-O3")).to be == false
  end    
  
  it 'toolchain (parent)' do
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "E6", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end   
          
  # Valid for exe config
  
  it 'linkerscript, artifact, map (all)' do
    expect(File.exists?("spec/testdata/merge/main/E3/E3.map")).to be == false
    expect(File.exists?("spec/testdata/merge/main/E3/E3.exe")).to be == false
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "E3", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("linkerscript3")).to be == true
    expect(File.exists?("spec/testdata/merge/main/E3/E3.exe")).to be == true
    expect(File.exists?("spec/testdata/merge/main/E3/E3.map")).to be == true
  end    
  
  it 'linkerscript, artifact, map (child)' do
    expect(File.exists?("spec/testdata/merge/main/E5/E5.map")).to be == false
    expect(File.exists?("spec/testdata/merge/main/E5/E5.exe")).to be == false
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "E5", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("linkerscript5")).to be == true
    expect(File.exists?("spec/testdata/merge/main/E5/E5.exe")).to be == true
    expect(File.exists?("spec/testdata/merge/main/E5/E5.map")).to be == true
  end    
  
  it 'linkerscript, artifact, map (parent)' do
    expect(File.exists?("spec/testdata/merge/main/E6/E1.exe")).to be == false
    expect(File.exists?("spec/testdata/merge/main/E6/E1.map")).to be == false
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "E6", "--rebuild", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("linkerscript1")).to be == true
    expect(File.exists?("spec/testdata/merge/main/E6/E1.exe")).to be == true
    expect(File.exists?("spec/testdata/merge/main/E6/E1.map")).to be == true
  end   
    
  it 'parent broken' do
    
    expect(File.exists?("spec/testdata/merge/main/E6/E6.exe")).to be == false
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "ParentKaputt", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    
    expect { tocxx.doit() }.to raise_error(ExitHelperException)
    
    expect($mystring.include?("Error: Config 'dasGibtsDochGarNicht' not found")).to be == true
  end   

  it 'var subst' do
    expect(File.exists?("spec/testdata/merge/main/E6/E1.map")).to be == false
    options = Options.new(["-m", "spec/testdata/merge/main", "-b", "E6", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("**E1.exe**")).to be == true # subst
    expect(File.exists?("spec/testdata/merge/main/E6/E1.map")).to be == true # subst
  end   
  
end

end
