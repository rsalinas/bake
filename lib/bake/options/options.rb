require 'bake/toolchain/colorizing_formatter'
require 'common/options/parser'
require 'bake/options/showToolchains'
require 'bake/options/showLicense'
require 'bake/options/showDoc'
require 'bake/options/usage'
require 'bake/options/create'
require 'common/options/finder'

module Bake

  def self.options
    @@options
  end
  def self.options=(options)
    @@options = options
  end

  class Options < Parser
    attr_accessor :build_config, :nocache, :analyze, :eclipseOrder, :envToolchain, :showConfigs
    attr_reader :main_dir, :project, :filename, :main_project_name, :buildDirDelimiter, :dot, :cc2j_filename # String
    attr_reader :roots, :include_filter, :exclude_filter, :adapt # String List
    attr_reader :conversion_info, :stopOnFirstError, :clean, :rebuild, :show_includes, :show_includes_and_defines, :projectPaths, :qac, :dry, :syncedOutput # Boolean
    attr_reader :linkOnly, :compileOnly, :no_autodir, :clobber, :docu, :debug, :prepro, :oldLinkOrder, :prebuild, :printTime, :json, :wparse # Boolean
    attr_reader :threads, :socket # Fixnum
    attr_reader :vars # map
    attr_reader :verbose
    attr_reader :filelist # set
    attr_reader :consoleOutput_fullnames, :consoleOutput_visualStudio


    def initialize(argv)
      super(argv)

      @dry = false
      @filelist = nil
      @qac = false
      @projectPaths = false
      @wparse = false
      @dot = nil
      @prebuild = false
      @printTime = false
      @buildDirDelimiter = "/"
      @oldLinkOrder = false
      @conversion_info = false
      @envToolchain = false
      @analyze = false
      @eclipseOrder = false
      @showConfigs = false
      @consoleOutput_fullnames = false
      @consoleOutput_visualStudio = false
      @prepro = false
      @stopOnFirstError = false
      @verbose = 1
      @vars = {}
      @build_config = ""
      @main_dir = nil
      @project = nil
      @filename = nil
      @cc2j_filename = nil
      @json = false
      @clean = false
      @clobber = false
      @docu = false
      @debug = false
      @rebuild = false
      @nocache = false
      @show_includes = false
      @show_includes_and_defines = false
      @linkOnly = false
      @compileOnly = false
      @no_autodir = false
      @threads = 8
      @roots = []
      @socket = 0
      @include_filter = []
      @exclude_filter = []
      @def_roots = []
      @main_project_name = ""
      @adapt = []
      @syncedOutput = false

      add_option(["-b",                   ""                     ], lambda { |x| set_build_config(x)                     })
      add_option(["-m"                                           ], lambda { |x| set_main_dir(x)                         })
      add_option(["-p"                                           ], lambda { |x| @project = x                            })
      add_option(["-f"                                           ], lambda { |x| @filename = x.gsub(/[\\]/,'/')          })
      add_option(["-c"                                           ], lambda {     @clean = true                           })
      add_option(["-a"                                           ], lambda { |x| Bake.formatter.setColorScheme(x.to_sym) })
      add_option(["-w"                                           ], lambda { |x| set_root(x)                             })
      add_option(["-r"                                           ], lambda {     @stopOnFirstError = true                })
      add_option(["-O"                                           ], lambda {     @syncedOutput = true                    })
      add_option(["--rebuild"                                    ], lambda {     @rebuild = true                         })
      add_option(["--prepro"                                     ], lambda {     @prepro = true                          })
      add_option(["--link-only",          "--link_only"          ], lambda {     @linkOnly = true;                       })
      add_option(["--compile-only",       "--compile_only"       ], lambda {     @compileOnly = true;                    })
      add_option(["--no-autodir",         "--no_autodir"         ], lambda {     @no_autodir = true                      })

      add_option(["--create"                                     ], lambda { |x| Bake::Create.proj(x)                    })
      add_option(["--conversion-info",    "--conversion_info"    ], lambda {     @conversion_info = true                 })
      add_option(["--file-list",          "--file_list"          ], lambda {     @filelist = Set.new                     })
      add_option(["--filter-paths"                               ], lambda {     @projectPaths = true                    })
      add_option(["--qac"                                        ], lambda {     @qac = true                             })

      add_option(["--generate-doc",       "--docu"               ], lambda {     @docu = true                            })

      add_option(["--adapt"                                      ], lambda { |x| set_adapt(x)                            })

      add_option(["-v0"                                          ], lambda {     @verbose = 0                            })
      add_option(["-v1"                                          ], lambda {     @verbose = 1                            })
      add_option(["-v2"                                          ], lambda {     @verbose = 2                            })
      add_option(["-v3"                                          ], lambda {     @verbose = 3                            })

      add_option(["--debug"                                      ], lambda {     @debug = true                           })
      add_option(["--set"                                        ], lambda { |x| set_set(x)                              })

      add_option(["--clobber"                                    ], lambda {     @clobber = true; @clean = true          })
      add_option(["--ignore-cache",       "--ignore_cache"       ], lambda {     @nocache = true                         })
      add_option(["-j",                   "--threads"            ], lambda { |x| set_threads(x)                          })
      add_option(["--socket"                                     ], lambda { |x| @socket = String === x ? x.to_i : x     })
      add_option(["--toolchain-info",     "--toolchain_info"     ], lambda { |x| ToolchainInfo.showToolchain(x)          })
      add_option(["--toolchain-names",    "--toolchain_names"    ], lambda {     ToolchainInfo.showToolchainList         })
      add_option(["--dot",                                       ], lambda { |x| @dot = x                                })
      add_option(["--do",                 "--include_filter"     ], lambda { |x| @include_filter << x                    })
      add_option(["--omit",               "--exclude_filter"     ], lambda { |x| @exclude_filter << x                    })
      add_option(["--abs-paths",          "--show_abs_paths"     ], lambda {     @consoleOutput_fullnames = true         })
      add_option(["--prebuild"                                   ], lambda {     @prebuild = true                        })
      add_option(["--Wparse"                                     ], lambda {     @wparse = true                          })

      add_option(["-h",                   "--help"               ], lambda {     Bake::Usage.show                        })
      add_option(["--time",                                      ], lambda {     @printTime = true                       })

      add_option(["--incs-and-defs",      "--show_incs_and_defs" ], lambda {     @show_includes_and_defines = true       })
      add_option(["--incs-and-defs=bake",                        ], lambda {     @show_includes_and_defines = true       })
      add_option(["--incs-and-defs=json"                         ], lambda { @show_includes_and_defines=true; @json=true })
      add_option(["--license",            "--show_license"       ], lambda {     License.show                            })
      add_option(["--doc",                "--show_doc"           ], lambda {     Doc.show                                })
      add_option(["--install-doc",        "--install_doc"        ], lambda {     Doc.install                             })

      add_option(["--dry"                                        ], lambda {     @dry = true                             })

      add_option(["--version"                                    ], lambda {     Bake::Usage.version                     })
      add_option(["--list",               "--show_configs"       ], lambda {     @showConfigs = true                     })
      add_option(["--compilation-db"                             ], lambda { |x,dummy| @cc2j_filename = (x ? x : "compilation-db.json" )})
      add_option(["--link-2-17",          "--link_2_17"          ], lambda {     @oldLinkOrder = true                    })
      add_option(["--build_",                                    ], lambda {     @buildDirDelimiter = "_"                })


      # hidden
      add_option(["--visualStudio"                               ], lambda {     @consoleOutput_visualStudio = true      })

      # deprecated and not replaced by new command
      add_option(["--show_include_paths"                         ], lambda {     @show_includes = true                   })

    end

    def parse_options()
      parse_internal(false)

      searchDir = @main_dir.nil? ? Dir.pwd : @main_dir
      dir = Bake.findDirOfFileToRoot(searchDir,"Project.meta")
      if dir
        set_main_dir(dir)
      else
        Bake.formatter.printError("Error: Project.meta not found in #{searchDir} or upwards")
        ExitHelper.exit(1)
      end

      @roots += @def_roots
      @roots.uniq!
      @adapt.uniq!

      if @project
        if @project.split(',').length > 2
          Bake.formatter.printError("Error: only one comma allowed for -p")
          ExitHelper.exit(1)
        end
      end

      if @conversion_info
        if @rebuild
          Bake.formatter.printError("Error: --conversion-info and --rebuild not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @clean
          Bake.formatter.printError("Error: --conversion-info and -c not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @prepro
          Bake.formatter.printError("Error: --conversion-info and --prepro not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @linkOnly
          Bake.formatter.printError("Error: --conversion-info and --linkOnly not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @compileOnly
          Bake.formatter.printError("Error: --conversion-info and --compileOnly not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @docu
          Bake.formatter.printError("Error: --conversion-info and --docu not allowed at the same time")
          ExitHelper.exit(1)
        end
      end

      if @linkOnly
        if @rebuild
          Bake.formatter.printError("Error: --link-only and --rebuild not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @clean
          Bake.formatter.printError("Error: --link-only and -c not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @prepro
          Bake.formatter.printError("Error: --link-only and --prepro not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @filename
          Bake.formatter.printError("Error: --link-only and --filename not allowed at the same time")
          ExitHelper.exit(1)
        end
      end

      if @compileOnly
        if @linkOnly
          Bake.formatter.printError("Error: --compile-only and --link-only not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @filename
          Bake.formatter.printError("Error: --compile-only and --filename not allowed at the same time")
          ExitHelper.exit(1)
        end
      end

      if @prepro
        if @rebuild
          Bake.formatter.printError("Error: --prepro and --rebuild not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @clean
          Bake.formatter.printError("Error: --prepro and -c not allowed at the same time")
          ExitHelper.exit(1)
        end
      end

      @filename = "." if @compileOnly

    end

    def check_valid_dir(dir)
     if not File.exists?(dir)
        Bake.formatter.printError("Error: Directory #{dir} does not exist")
        ExitHelper.exit(1)
      end
      if not File.directory?(dir)
        Bake.formatter.printError("Error: #{dir} is not a directory")
        ExitHelper.exit(1)
      end
    end

    def set_build_config(config)
      if not @build_config.empty?
        Bake.formatter.printError("Error: Cannot set build config '#{config}', because build config is already set to '#{@build_config}'")
        ExitHelper.exit(1)
      end
      @build_config = config
    end

    def set_main_dir(dir)
      check_valid_dir(dir)
      @main_dir = File.expand_path(dir.gsub(/[\\]/,'/'))
      @main_project_name = File::basename(@main_dir)
      @def_roots = calc_def_roots(@main_dir)
    end

    def set_root(dir)
      check_valid_dir(dir)
      r = File.expand_path(dir.gsub(/[\\]/,'/'))
      @roots << r if not @roots.include?r
    end

    def set_adapt(name)
      @adapt << name if not @adapt.include?name
    end

    def set_threads(num)
      @threads = String === num ? num.to_i : num
      if @threads <= 0
        Bake.formatter.printError("Error: number of threads must be > 0")
        ExitHelper.exit(1)
      end
    end

    def set_set(str)
      ar = str.split("=")
      if not str.include?"=" or ar[0].length == 0
        Bake.formatter.printError("Error: --set must be followed by key=value")
        ExitHelper.exit(1)
      end
      @vars[ar[0]] = ar[1..-1].join("=")
    end

  end

end


