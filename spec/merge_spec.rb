#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

describe "Merging Configs" do
  
  it 'build base (all)' do
    expect(File.exists?("spec/testdata/merge/main/testL1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testL2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testL3/libmain.a")).to be == false

    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL1", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/merge/main/testL1/libmain.a")).to be == true
    expect(File.exists?("spec/testdata/merge/main/testL2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testL3/libmain.a")).to be == false
  end  

  it 'build child (all)' do
    expect(File.exists?("spec/testdata/merge/main/testL1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testL2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testL3/libmain.a")).to be == false

    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL2", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/merge/main/testL1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testL2/libmain.a")).to be == true
    expect(File.exists?("spec/testdata/merge/main/testL3/libmain.a")).to be == false
  end  
    
  it 'build grandchild (all)' do
    expect(File.exists?("spec/testdata/merge/main/testL1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testL2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testL3/libmain.a")).to be == false

    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL3", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/merge/main/testL1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testL2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testL3/libmain.a")).to be == true
  end  
  
  it 'file and exclude file (all)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL3", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    expect($mystring.include?("stestL1.cpp")).to be == true
    expect($mystring.include?("stestL2.cpp")).to be == true
    expect($mystring.include?("stestL3.cpp")).to be == true
    expect($mystring.include?("ex.cpp")).to be == false
  end    
  
  it 'file and exclude file (child)' do
    expect(File.exists?("spec/testdata/merge/main/testL5/libmain.a")).to be == false
        
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL5", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    expect($mystring.include?("stestL5.cpp")).to be == true
    expect(File.exists?("spec/testdata/merge/main/testL5/libmain.a")).to be == true    
  end    

  it 'file and exclude file (parent)' do
    expect(File.exists?("spec/testdata/merge/main/testL6/libmain.a")).to be == false
        
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL6", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    expect($mystring.include?("stestL1.cpp")).to be == true
    expect(File.exists?("spec/testdata/merge/main/testL6/libmain.a")).to be == true    
  end    
  
  
  it 'deps (all)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL3", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
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
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL5", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    posdep51 = $mystring.index("depL5_1")
    posdep52 = $mystring.index("depL5_2")
    
    expect((posdep51 < posdep52)).to be == true
  end    

  it 'deps (parent)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL6", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    posdep11 = $mystring.index("depL1_1")
    posdep12 = $mystring.index("depL1_2")
    
    expect((posdep11 < posdep12)).to be == true
  end    
  
  it 'libs (all)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL3E", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
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
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL5E", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
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
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL6E", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
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
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL3", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
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
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL5", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
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
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL6", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
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
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL3E", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == false
    expect($mystring.include?("def2")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end    
  
  it 'defaulttoolchain (child)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL5E", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == false
    expect($mystring.include?("def5")).to be == true
    expect($mystring.include?("-O3")).to be == false
  end    
  
  it 'defaulttoolchain (parent)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testL6E", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end    
  
  # Valid for custom config
  
  it 'step (all)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testC3", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("C1")).to be == false
    expect($mystring.include?("C2")).to be == false
    expect($mystring.include?("C3")).to be == true
  end    

  it 'step (child)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testC5", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("C5")).to be == true
  end      

  it 'step (parent)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testC6", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("C1")).to be == true
  end      

  it 'step (exe extends custom)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testC5E", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("C5")).to be == true
  end      
  
  it 'step (custom extends exe)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testC7", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("C7")).to be == true
  end      
    
            
  # Valid for library and exe config
        
  it 'includedir (all)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testE3", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
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
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testE5", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    posinc51 = $mystring.index("Inc5_1")
    posinc52 = $mystring.index("Inc5_2")
    
    expect((posinc51 < posinc52)).to be == true

  end    
  
  it 'includedir (parent)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testE6", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    posinc11 = $mystring.index("Inc1_1")
    posinc12 = $mystring.index("Inc1_2")
    
    expect((posinc11 < posinc12)).to be == true
  end   

  it 'toolchain (all)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testE3", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == false
    expect($mystring.include?("def2")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end    
  
  it 'toolchain (child)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testE5", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == false
    expect($mystring.include?("def5")).to be == true
    expect($mystring.include?("-O3")).to be == false
  end    
  
  it 'toolchain (parent)' do
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testE6", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("def1")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end   
          
  # Valid for exe config
  
  it 'linkerscript, artifact, map (all)' do
    expect(File.exists?("spec/testdata/merge/main/testE3/testE3.map")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testE3/testE3.exe")).to be == false
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testE3", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("linkerscript3")).to be == true
    expect(File.exists?("spec/testdata/merge/main/testE3/testE3.exe")).to be == true
    expect(File.exists?("spec/testdata/merge/main/testE3/testE3.map")).to be == true
  end    
  
  it 'linkerscript, artifact, map (child)' do
    expect(File.exists?("spec/testdata/merge/main/testE5/testE5.map")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testE5/testE5.exe")).to be == false
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testE5", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("linkerscript5")).to be == true
    expect(File.exists?("spec/testdata/merge/main/testE5/testE5.exe")).to be == true
    expect(File.exists?("spec/testdata/merge/main/testE5/testE5.map")).to be == true
  end    
  
  it 'linkerscript, artifact, map (parent)' do
    expect(File.exists?("spec/testdata/merge/main/testE6/testE1.exe")).to be == false
    expect(File.exists?("spec/testdata/merge/main/testE6/testE1.map")).to be == false
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testE6", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("linkerscript1")).to be == true
    expect(File.exists?("spec/testdata/merge/main/testE6/testE1.exe")).to be == true
    expect(File.exists?("spec/testdata/merge/main/testE6/testE1.map")).to be == true
  end   
    
  it 'parent broken' do
    
    expect(File.exists?("spec/testdata/merge/main/testE6/testE6.exe")).to be == false
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "ParentKaputt", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    
    expect { tocxx.doit() }.to raise_error(ExitHelperException)
    
    expect($mystring.include?("Error: Config 'dasGibtsDochGarNicht' not found")).to be == true
  end   

  it 'var subst' do
    expect(File.exists?("spec/testdata/merge/main/testE6/testE1.map")).to be == false
    Bake.options = Options.new(["-m", "spec/testdata/merge/main", "-b", "testE6", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("**testE1.exe**")).to be == true # subst
    expect(File.exists?("spec/testdata/merge/main/testE6/testE1.map")).to be == true # subst
  end   
  
end

end