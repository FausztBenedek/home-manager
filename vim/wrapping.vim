
function! WrapIn(start, end, singleLine)
  if has('ide')
    execute "normal! `>o" . a:end . "\<esc>kV`<>\<esc>O" . a:start . "\<esc>"
    return
  endif
  if !a:singleLine
    "Insert above one line and below one line
    execute "normal! `<O" . a:start . "\<esc>`>o" . a:end . "\<esc>`'jV`>>\<esc>k"
  else
    "Insert in front of and after (no new lines)
    execute "normal `>a" . a:end . "\<esc>`<i" . a:start . "\<esc>"
  endif
endfunction

function! WrapInTags(singleLine, tagName)
  call WrapIn('<' . a:tagName . '>', '</' . a:tagName . '>', a:singleLine)
endfunction

function! AppendTags(tagName)
  execute "normal! a<" . a:tagName . "></" . a:tagName . ">\<esc>`[f>"
endfunction
function! InsertTags(tagName)
  execute "normal! i<" . a:tagName . "></" . a:tagName . ">\<esc>`[f>"
endfunction

function! AppendTagsAndInsert(tagName)
  call AppendTags(a:tagName)
  execute "normal! l"
  startinsert
endfunction

function! GotoAttributeValue(attributeName)
  execute "normal! />\r:nohl\r?\\s" . a:attributeName . "[^\"']*=\\zs[\"']\\ze\r"
endfunction

function! ViewInAttributeValue(attributeName)
  call GotoAttributeValue(a:attributeName)
  execute "normal! vi\""
endfunction

if has('ide')
  vnoremap <c-w><c-t> :<c-u>call WrapInTags(0, "")<Left><Left>
else
  vnoremap <c-w><c-t> :<c-u>call WrapInTags(visualmode() ==# 'v' ? 1 : 0, "")<Left><Left>
endif
nnoremap <c-w><c-t><c-i> :call InsertTags("")<Left><Left>
nnoremap <c-w><c-t><c-a> :call AppendTags("")<Left><Left>
inoremap <c-w><c-t> <esc>:call AppendTagsAndInsert("")<Left><Left>
  "Unwrapping
vnoremap <c-w><c-r> <esc>`>hda<`</\w<cr>:nohl<cr>da<`<v`>
nnoremap viaa :call ViewInAttributeValue("")<Left><Left>
nnoremap viac :call ViewInAttributeValue("class")<cr>
nnoremap viai :call ViewInAttributeValue("id")<cr>
nnoremap viad :call ViewInAttributeValue("data-testid")<cr>
nnoremap gaa :call GotoAttributeValue("")<Left><Left>
nnoremap gac :call GotoAttributeValue("class")<cr>
nnoremap gai :call GotoAttributeValue("id")<cr>
nnoremap gad :call GotoAttributeValue("data-testid")<cr>

