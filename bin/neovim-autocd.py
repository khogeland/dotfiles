#!/usr/bin/env python
# neovim-autocd.py
import neovim
import os
import sys
import random

this = int(random.random()*1000)

nvim = neovim.attach('socket', path=os.environ['NVIM_LISTEN_ADDRESS'])
nvim.vars['__autocd_cwd%s'%this] = os.getcwd()
# nvim.vars['__autocd_ppid%s'%this] = sys.argv[1]
# if len(sys.argv) >= 3:
    # nvim.vars['__autocd_process%s'%this] = sys.argv[2]
# else:
    # nvim.vars['__autocd_process%s'%this] = ""
nvim.command('execute "lcd" fnameescape(g:__autocd_cwd%s)'%this)
# nvim.command('execute "0f"')
# nvim.command('execute "file" "term://.//" . g:__autocd_ppid%s . ":" . g:__autocd_process%s . ":" . fnameescape(g:__autocd_cwd%s)'%(this,this,this))

del nvim.vars['__autocd_cwd%s'%this]
# del nvim.vars['__autocd_ppid%s'%this]
# del nvim.vars['__autocd_process%s'%this]
