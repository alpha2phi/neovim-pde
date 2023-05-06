                                                                                         _                         
require "config.options"
require "config.lazy"

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require "config.autocmds"
    require "config.keymaps"
    require "utils.contextmenu"
  end,
})
                                                                                     ,--.\`-. __                   
                                                                                   _,.`. \:/,"  `-._               
                                                                               ,-*" _,.-;-*`-.+"*._ )              
                                                                              ( ,."* ,-" / `.  \.  `.              
                                                                             ,"   ,;"  ,"\../\  \:   \             
                                                                            (   ,"/   / \.,' :   ))  /             
                                                                             \  |/   / \.,'  /  // ,'              
                                                                              \_)\ ,' \.,'  (  / )/                
                                                                                  `  \._,'   `"                    
                                                                                     \../                          
                                                                                     \../                          
                                                                           ~        ~\../           ~~             
                                                                    ~~          ~~   \../   ~~   ~      ~~         
                                                               ~~    ~   ~~  __...---\../-...__ ~~~     ~~         
                                                                 ~~~~  ~_,--'        \../      `--.__ ~~    ~~     
                                                             ~~~  __,--'              `"             `--.__   ~~~  
                                                          ~~  ,--'                                         `--.    
                                                             '------......______             ______......------` ~~
                                                           ~~~   ~    ~~      ~ `````---"""""  ~~   ~     ~~       
                                                                  ~~~~    ~~  ~~~~       ~~~~~~  ~ ~~   ~~ ~~~  ~  
                                                               ~~   ~   ~~~     ~~~ ~         ~~       ~~   SSt    
                                                                        ~        ~~       ~~~       ~              
                                                            


                                                                Find file                                     f

                                                                New file                                      n

                                                                Recent files                                  r

                                                                Find text                                     g

                                                                Config                                        c

                                                              勒 Restore Session                               s

                                                              鈴 Lazy                                          l

                                                                Quit                                          q

                                                             	   v0.9.0	⚡Neovim loaded 146 plugins in 58.95ms
                                                              
                                                              Software is hard.
                                                              
                                                                                                  - Donald Knuth
