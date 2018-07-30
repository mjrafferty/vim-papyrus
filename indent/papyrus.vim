" Vim indent file
" Language:            Shell Script
" Maintainer:          Christian Brabandt <cb@256bit.org>
" Previous Maintainer: Peter Aronoff <telemachus@arpinum.org>
" Original Author:     Nikolai Weibull <now@bitwi.se>
" Latest Revision:     2016-02-15
" License:             Vim (see :h license)
" Repository:          https://github.com/chrisbra/vim-sh-indent

if exists("b:did_indent")
  finish
endif

let b:did_indent = 1

setlocal indentexpr=GetPapyrusIndent()
setlocal indentkeys+=0=Else,0=ElseIf,0=EndIf,0=EndWhile,0=EndEvent,0=EndGroup,0=EndFunction,0=EndState,0=EndStruct
setlocal indentkeys+=0=fin,0=fil,0=fip,0=fir,0=fix
setlocal indentkeys-=:,0#
setlocal nosmartindent

let b:undo_indent = 'setlocal indentexpr< indentkeys< smartindent<'

if exists("*GetPapyrusIndent")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim


function s:buffer_shiftwidth()
  return shiftwidth()
endfunction


let s:papyrus_indent_defaults = {
      \ 'default': function('s:buffer_shiftwidth'),
      \ 'continuation-line': function('s:buffer_shiftwidth'),
      \ 'case-labels': function('s:buffer_shiftwidth'),
      \ 'case-statements': function('s:buffer_shiftwidth'),
      \ 'case-breaks': 0 }


function! s:indent_value(option)

  let Value = exists('b:papyrus_indent_options')
        \ && has_key(b:papyrus_indent_options, a:option) ?
        \ b:papyrus_indent_options[a:option] :
        \ s:papyrus_indent_defaults[a:option]

  if type(Value) == type(function('type'))
    return Value()
  endif

  return Value

endfunction


function! GetPapyrusIndent()

  let lnum = prevnonblank(v:lnum - 1)

  if lnum == 0
    return 0
  endif

  let pnum = prevnonblank(lnum - 1)

  let ind = indent(lnum)
  let line = getline(lnum)

  if line =~ '^\s*\%(ScriptName\|Event\|EndEvent\|[^;]*\s*Function\|EndFunction\|Group\|EndGroup\|Property\|EndProperty\|State\|EndState\|Struct\|EndStruct\|If\|Else\|ElseIf\|EndIf\|While\|EndWhile\)\>'

    if line !~ '\<\%(EndEvent\|EndGroup\|EndFunction\|EndState\|EndStruct\|EndIf\|EndWhile\)\>\s*\%(#.*\)\=$'
      let ind += s:indent_value('default')
    endif

  elseif s:is_continuation_line(line)

    if pnum == 0 || !s:is_continuation_line(getline(pnum))
      let ind += s:indent_value('continuation-line')
    endif

  elseif pnum != 0 && s:is_continuation_line(getline(pnum))

    let ind = indent(s:find_continued_lnum(pnum))

  endif

  let pine = line
  let line = getline(v:lnum)

  if line =~ '^\s*\%(EndEvent\|EndGroup\|EndFunction\|EndState\|EndStruct\|Else\|ElseIf\|EndIf\|EndWhile\)\>' || line =~ '^\s*}'

    let ind -= s:indent_value('default')

  endif

  return ind

endfunction


function! s:is_continuation_line(line)

  return a:line =~ '\%(\%(^\|[^\\]\)\\\|&&\|||\)$'

endfunction


function! s:find_continued_lnum(lnum)

  let i = a:lnum

  while i > 1 && s:is_continuation_line(getline(i - 1))
    let i -= 1
  endwhile

  return i

endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
