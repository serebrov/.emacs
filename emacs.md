## Terminology

Minibuffer is the line at the bottom of the screen where you can enter commands. Similar to the Vim command line.

Window is the Emacs term for a Vim split or a tmux pane.

Buffer is similar to the Vim buffer (file loaded in memory, can be displayed in a window or hidden).

Frame opens a new GUI window in GUI Emacs (and something similar to a tab in terminal Emacs).

The `M-` in keyboard shortcuts is "Meta" ("Option" key or "Alt" key). Alternatively, "Esc" can be used as meta, for example, press "Esc" and then "v" to move up one screen.

# Lisp Code Style

Lisp code is usually formatted like this:

```
(use-package embark
  :bind
  (("C-." . embark-act)         ;; Context actions on target at point
   ("C-;" . embark-dwim)        ;; "Do what I mean" on target
   :map minibuffer-local-map
   ("C-c C-e" . embark-export)  ;; Export results to a buffer
   ("C-c C-c" . embark-collect))) ;; Collect results in a buffer
```

Practically it seems to be inconvenient as it is not easy to add new code after end line and before closing parenthesis:

```
(use-package embark
  :bind
  (("C-." . embark-act)         ;; Context actions on target at point
   ("C-;" . embark-dwim)        ;; "Do what I mean" on target
   :map minibuffer-local-map
   ("C-c C-e" . embark-export)  ;; Export results to a buffer
   ("C-c C-c" . embark-collect) ;; Collect results in a buffer
   (i-can-add_more-stuff-here_easily)  ;; <--- add more code here
 )
 (and-here-to-if-i-want)               ;; <--- and more here
)
```

The Lisp style seems to be to put parenthesis on the same line. Practically it means:
* Pay attention to the identation, not at the parens
* Structural editing: use extra tools to work with code

Tools: [paredit](https://paredit.org/), [smartparens](https://smartparens.readthedocs.io/en/latest/), [show-paren](https://www.gnu.org/software/emacs/manual/html_node/emacs/Matching.html), [rainbow-delimiters](https://github.com/Fanael/rainbow-delimiters).

# Running emacs in a terminal

```
emacs -nw ./file-name
```

If there is the GUI Emacs running at the same time, `--no-desktop` is helpful to avoid confict with the running emacs:

```
emacs -nw --no-deskop ./file-name
```

# Basic emacs keybindings

Open/save/quit:
- Open file: C-x C-f
- Save: C-x C-s or M-x save-buffer
  - M-x save-some-buffers to save multiple buffers
- Quit emacs: `C-x C-c`

Move around:
- use arrow keys
- Page up/down: C-v / M-v or actual PgUp / PgDown keys
  - Other window (useful when reading help): C-M-v
- Start of file / end of file: `M-<` and `M->`
- Center and redraw the screen: C-l
- Go to line:`M-g g`

Char/line movements, arrow keys also work:
- Char forward/backward: `C-f` / `C-b`
- Word forward/backward: `M-f` / `M-b`
- Start / end of line: `C-a` and `C-e`
- Start / end of sentence: `M-a` and `M-e`
- Next / prev line: `C-n` / `C-p`

Cancel current operation: C-g (which is usually done with Esc in vim)
- Close minibuffer
- Close autocompletion popup

Search in the document:
- `C-s` (next C-s, prev C-r) - search forward
- `C-r` - Search backward
- `M-%` - Query replace
- `C-M-%` - Regex replace
- `M-x replace-string` - Replace a string

Select, copy/paste:
- Select text: C-space
- Copy/Cut/Paste: M-w, C-w, C-y

Undo and redo:
- `C-/` - undo, also `C-x u`, also `C-_`
- `C-?` - redo
- Note: originally Emacs did not have redo, related:
  - Undo also does redo, so `C-/` undoes the undo
  - Use `C-g` to reverse the direction of undos/redos when doing multiple undos/redos
  - From https://stackoverflow.com/a/18383455:
    - To redo once, immediately after undoing: C-g C-/
    - To redo twice, immediately after undoing: C-g C-/ C-/.
      - Note that C-g is not repeated.
  - Read M-x Info-goto-emacs-command-node RET undo RET to get confused more

Editing:
- Delete char/word - `C-d` / `M-d`
- Delete until the end of line / sentence - `C-k` / `M-k`
- Delete selection - `C-w`
- Swap chars - `C-t`
- Uppercase / lowercase / capitalize the word - `M-u` / `M-l` / `M-c`
- Comment/uncomment the current line or selection - `M-;`
- Format the paragraph - `M-q`

Rectangular selection:
- `C-x SPC` - Start selecting text in a rectangle
- `C-x r k` - Kill the rectangle
- `C-x r y` - Yank the rectangle

Mark ring:
- `C-SPC` - Set the mark
- `C-u C-SPC` - Jump to the mark
- `C-x C-x` - Swap the cursor and the mark

Navigating:
- Jump to the function definition - `M-.` (calls `xref-find-definitions`)

Running commands and code:
- Run emacs function ("interactive command"): M-x {function name}
- Eval (execute) emacs code in the buffer: C-x C-e
- Eval buffer: M-x eval-buffer

Splits:
- Make a split: C-x 2 (horizontal), C-x 3 (vertical)
- Move to other split: C-x o
- Close current split: C-x 0

Buffers:
- Close: C-x k (kill-buffer)
- Switch to buffer: C-x b
- List buffers: C-x C-b, nicer UI: M-x ibuffer

Set mode (usually set automatically):
- `M-x {mode-name}` set the mode (text-mode, org-mode, etc.)

Repeating commands:
- `C-u {number} {command}` - repeat the command {number} times
  - `C-u 4 C-n` - move down 4 lines

## Dired and files

Open dired: `C-x d`

- `C-x d` - Open Dired (directory editor)
- `C-x C-f {dir name}` - The find-file command opens dired when given a dir.
- `C-x C-j` - Open Dired and jump to the current file
- `C-x C-d` - Open a directory
- `C-x C-q` - switch to edit mode (like vidir) - wdired
  - `C-c C-c` to save changes
  - `C-c ESC` to undo

Navigation:
- In evil mode: j, k to go up/down, `-` to go dir up
- Next/prev dir: `g j` and `g k`

Mark files:
- `d` - mark for deletion
- `m` - mark for command that we will decide on later, `t` - toggle marks
- `u` - unmark, `U` to umark all
- `DEL` to back up one line and unmark or unflag.
Commands:
- Delete: `x` to delete (eXpunge) the files flagged ‘D’.
- Open: `RET` to open file
  - `shift-RET` or `g O` (`o` in emacs mode) to open file or directory in Other window
- New dir: `i` to Insert a subdirectory in this buffer.
- Move / Rename: `R` to Rename a file or move the marked files to another directory.
- Copy: `C` to Copy files.
- Open URL: `W`
- Execute shell command: `!` or `X`
- Compress: `Z`, `c` is "compress to" (will ask for the archive name)
- Redisplay: `r` (`l` in emacs mode)

Helpers:
  - View: `g o` (`v` in emacs mode), use `Ctrl-o` to get back
  - Show file type: `g y` (`y` in emacs mode)
- View:
  - `TAB` or `(` to show/hide details
  - Sorting: `o` (`s` in emacs mode) to toggle Sorting by name/date or change the ‘ls’ switches.
  - Redisplay: `r` (`l` in emacs mode), `:e!` also works
  This retains all marks and hides subdirs again that were hidden before.
- Use SPC and DEL to move down and up by lines.

Most of the `evil` mode bindings are the same, but there are some differences because of the keys used for Vim naviagtion (h,j,k,l,-, etc), for example
- `-` in evil goes to the parent dir (this is "negative argument" by default)
- `I` is "dired-maybe-insert-subdir" in `evil` (and Info by default)
- Go to file: "J" in evil and "j" in emacs
- ...

Marking tools:
- * C-n			dired-next-marked-file
- * C-p			dired-prev-marked-file
- * !				dired-unmark-all-marks
- * %				dired-mark-files-regexp
- * (				dired-mark-sexp
- * *				dired-mark-executables
- * .				dired-mark-extension
- * /				dired-mark-directories
- * ?				dired-unmark-all-files
- * @				dired-mark-symlinks
- * O				dired-mark-omitted
- * c				dired-change-marks
- * m				dired-mark
- * s				dired-mark-subdir-files
- * t				dired-toggle-marks
- * u				dired-unmark
- * <delete>		dired-unmark-backward

Regex tools:
- % C		dired-do-copy-regexp
- % H		dired-do-hardlink-regexp
- % R		dired-do-rename-regexp
- % S		dired-do-symlink-regexp
- % d		dired-flag-files-regexp
- % g		dired-mark-files-containing-regexp
- % l		dired-downcase
- % m		dired-mark-files-regexp
- % r		dired-do-rename-regexp
- % u		dired-upcase

# Wdired, editing mode (similar to vidir)

Edit mode (wdired): `i` in evil switches to editing mode (or `M-x wdired-change-to-wdired-mode`)
- Apply changes: `C-c C-c` or `M-x wdired-finish-edit`
- Exit: `C-x C-q`

## Dired: interactive replacemend mode

`Q` in direcd starts the regexp replace in marked files (on in current directory under cursor).

It opens two buffers: search results and current buffer with replacements. Key mappings are:
- Type SPC or y to replace one match, Delete or n to skip to next,
- RET or q to exit, Period to replace one match and exit,
- , to replace but not move point immediately,
- ! to replace all remaining matches in this buffer with no more questions,
- C-r to enter recursive edit (C-M-c to get out again),
- C-w to delete match and then enter recursive edit,
- ^ to move point back to previous match,
- u to undo previous replacement,
- U to undo all replacements,
- e to edit the replacement string.
- E to edit the replacement string with exact case.
- C-l to clear the screen, redisplay, and offer same replacement again,
- Y to replace all remaining matches in all remaining buffers (in
- multi-buffer replacements) with no more questions,
- N (in multi-buffer replacements) to skip to the next buffer without
replacing remaining matches in the current buffer.

Any other character exits the interactive replacement loop, and is then
re-executed as a normal key sequence.
* Question: how to re-enable the ineractive mode?

## Getting help

Select a manual and search in it: `M-x info-lookup-symbol`, C-h S

Help prefix: C-h [will prompt for other help commands]

Emacs manual:
* Quick reference card: `M-x help-quick`
* Info reader: `M-x info`, `C-h i`
* Emacs manual: `M-x info-emacs-manual`, `C-h r`
  * `RET` go to link; `l` to go back; `s` search
  * `m` [item] - pick a menu item; `i` jump to index entry
  * see more in the "Reading Help" section
* `M-x info-lookup-symbol` [symbol] - search for symbol in manuals
* `M-x info-display-manual` [topic] - manual on the `topic`
* `M-x view-emacs-news` - history of Emacs changes

Help on a topic:
* `M-x Info-goto-emacs-command-node` [command] - emacs Info topic for `command`
* `M-x shortdoc-display-group` [topic] - gropped information for commands related to `topic`
* `M-x finder-by-keyword` [topic] - see which packages exist for the selected [topic]

Describe:
* Package: `M-x describe-package`, C-h P
  * provided by package.el, does not cover standard packages like dired
  * for dired, see the emacs manual, C-h r
* Current mode: `M-x describe-mode`, C-h m
* Function under cursor: `M-x describe-function`
* Command: `M-x describe-command` [command]
* Key: `M-x describe-key`, `C-h k` (`C-h k C-h k` to get help on `C-h k` itself)
  * Related: `M-x where-is` [command] - which key this command is bound to?
  * `M-x helpful-key` [key] - show help for the command bound to the `key`
  * `M-x describe-key-briefly`, `C-h c {key}` - show the command bound to a key
* Key bindings: `M-x describe-bindings`, `C-h b`
* Keymap: `M-x describe-keymap` [mode] - describe keys for selected mode

Understanding what's happening:
* history of keystrokes: `M-x view-lossage`, `C-h l` (what did I just press??)
* last command as lisp: `M-x repeat-complex-command`, `C-x ESC ESC`
  * use "up" and "down" arrows to scroll through the history of commands
  * the `M-x consult-complex-command` shows the history (and C-c C-c in consult exports it to a buffer)
* view messages: `M-x view-echo-area-messages`, `C-h e`
  * or `M-x ibuffer` and select `*Messages*`
* enable debug mode to see stack tracke for errors: `M-x toggle-debug-on-error`

Navigating Elisp code:
* Jump to definition at point (point=cursor): `M-.`, `M-x xref-find-definitions`
* Jump back: `M-,`, `M-x xref-go-back`
* Go to function source: `M-x find-function`
* Go to variable definition: `M-x find-variable`
* Go to library source: `M-x find-library`

Search:
* `M-x apropos` [keyword] - search for symbols (functions, commands, variables, etc) with `keyword`
* `M-x apropos-documentation` [keyword] - search docstrings
* `M-x apropos-command` [keyword], `C-h a` - search for commands with `keyword`
* `M-x apropos-variable` [keyword] - search variables
* `M-x apropos-value` [val] - which variables have `val` value?

Related links:
* https://www.chiply.dev/post-june-emacs-carnival

# Reading Help

Note: you can see the current mode in the bottom bar, it says `*Help*` for help buffers and `*Info*` for Info manuals. Keybindings are somewhat different.

In the Help file:
- scroll up/down: `spc` / `backspace` (or `DEL`).
- Go to the top: `<`
- Go to the bottom: `>`
- Go back: `l`
- Next / prev page: `n` and `p`
- Open info page for current topic: `i`
- View source code: `s`
- Quit: `q`

# Reading Info manuals

Note: you can see the current mode in the bottom bar, it says `*Help*` for help buffers and `*Info*` for Info manuals. Keybindings are somewhat different.

In the Info manual:
- get quick help: `?`
  - quit: scroll to the bottom or C-g (or anything that is not bound like `j`)
- scroll up/down: `spc` / `backspace` (or `DEL`).
  - `spc` at the end of a node to go to the next node.
- Go to the top (beginning of the node): `b`
- Go to the bottom (end of the node): `e`
- Quit: `q`

Moving between nodes:
- Go back/forward in history (like jump list): `l` / `r`
  - Note that `l` is a universal back command, it works in many contexts.
  - See the history: `L`
- Go to nearest node: RET
- Next/prev node, sequentially:  `[` / `]` (same as space/backspace, but without scrolling)
- Next/prev node on the same level: `n` and `p` (will skip lower level nodes)
- First (top) node / last node: `t` and `<` / `>`
- Table of contents: `T`
- Parent node: `u` (up one level)

Quick jumps:
- Show menu: `m`, `Ctrl-g` - in new window
  - Cycle through menu items: `TAB`
- Show references: `f`
- Go to node: `g`, in new window - `Ctrl-g`

Search:
- Search in the document: `s`
  - Incremental search: `C-s` or `C-r`
  - Search in the index `i`
- Search everywhere: M-x info-apropos

Other:
- All manuals (directory): `d` to go to the directory of all manuals.
- Open current manual in the browser: `G`
- `M-x visible-mode` to toggle visible mode (show hidden markup).
- `M-n` creates a new Info window with the same node (duplicate the current window)

Info has some hints in the top and bottom bars:
- The mode line at the bottom shows where we are now (*info* (info) NodeName)
- The mode line at the bottom also says "Top" (we see part of the text) or "All" (all text is visible)

 Note: there is no easy way to scroll down or up half a page (like `C-d` or
  `C-u` in Vim), but it is possible to do `M-r C-l C-l` to down half a page
  and `M-r M-r C-l` to up half a page
  See: https://www.reddit.com/r/emacs/comments/r7l3ar/comment/hn0ywbu/

Info help: ? or `H` in a standalone reader
- Note: the ? does not work for me, H works.
- Note: the manual says when I go to help from the Info, I can scroll all the way down with SPC and then press SPC one or more times to get back to Info - this does not happen (I am going back through the list of buffers)
- Maybe both problems are related

Evil bindings:
- scroll up/down: `spc` / `backspace` (or `DEL` or `b`).
- Quit: `q`
- Go to nearest node: RET
- Parent node: `u`
- Search: `s`
- Directory: `d`
- Go back/forward in history: `C-o` / `TAB`
- Next/prev node, sequentially:  `C-j` / `C-k`
- Next/prev node on the same level: `g j` and `g k`
- First (top) node / last node: `g t` and ?
- Table of contents: `g T`

Quick jumps (evil):
- Show menu: `J`
  - Cycle through menu items: `g ]` and `g [`
- Show references: `g f`
- Go to node: `g G`
- Virtual index: `I`

## Managing Windows

Window is the Emacs term for a Vim split or a tmux pane.

- `C-x 2` - Split the window horizontally
- `C-x 3` - Split the window vertically
- `C-x 0` - Close the current window
- `C-x 1` - Close all windows except the current one
  - Note: can go back with `M-x winner-undo`.
- `C-x o` - Move to the next window
- `C-M-v` - Scroll other window (useful for reading help)

## Managing Buffers

Buffer is similar to the Vim buffer.

- `C-x b` - Switch to another buffer
- `C-x k` - Kill a buffer
- `:ls` or `C-x C-b` - List all buffers
  - m to mark several buffers for opening
  - D to mark the buffer for deletion
  - s to mark the buffer for saving
  - u to unmark the buffer
  - U to unmark all
  - x to execute deletions
  - v to open marked with `m` buffers

See
* `M-x describe-function buffer-menu`
* `M-x describe-mode buffer-menu-mode`
* M-x Info-goto-emacs-command-node RET buffer-men2 RET

## Managing Frames

Frame opens a new GUI window in GUI Emacs (and something similar to a tab in terminal Emacs).

- `C-x 5 2` - Create a new frame
- `C-x 5 0` - Close the current frame
- `C-x 5 o` - Move to the next frame

## Save and restore sessions

- `M-x desktop-save` - Save the current session
- `M-x desktop-read` - Restore the last session
- `M-x desktop-clear` - Clear the session
- `M-x desktop-change-dir` - Change the session directory
- Get help about sessions: `C-h i` to open the manual, `m desktop` to open the desktop manual.

## Other

- `M-x calendar` - Open the calendar
- `M-x calc` - Open the calculator
- `M-x tetris` - Play Tetris
- `M-x doctor` - Talk to the Emacs doctor
- `M-x butterfly` - Show a butterfly

TRAMP (Transparent Remote Access, Multiple Protocols) is a package that allows you to open files on remote servers. Use `/ssh:user@host:/path/to/file` to open a file on a remote server.

Org-mode.org - Org mode is a major mode for keeping notes, maintaining TODO lists, planning projects, and authoring documents with a fast and effective plain-text system.

Shell mode - `M-x shell` to open a shell in a buffer.
Eshell - Emacs shell, a shell implemented in Emacs Lisp, `M-x eshell`.

## Themes and packages

- `M-x load-theme` - Load a theme
- `M-x customize-group` - Customize a group of options
- `M-x customize-face` - Customize a face (font, color, etc.)
- `M-x list-packages` - List all packages

Upgrade packages:
- `M-x package-upgrade` [package]
- `M-x package-upgrade-all`
- `M-x package-vc-upgrade` [package]
- `M-x package-vc-upgrade-all`

Configuration file is `~/.emacs.d/init.el`.
Use `M-x eval-buffer` to reload the configuration file.
Start Emacs with `emacs -q` to ignore the configuration file (if something is broken).

## Emacs Lisp

Lisp intro: `C-h i` to open manual, `m lisp intro` to open Lisp intro or `m elisp` to open Lisp manual.

- `C-x C-e` - Evaluate (execute) the expression before the cursor
- `C-j` - Evaluate the expression before the cursor and insert the result

- `M-x` - Run a command
- `M-:` - Evaluate an Emacs Lisp expression

Base syntax:
- (function arg1 arg2) - Call a function with arguments
- something - variable, for example, fill-column
- "something" - string
- 'something - symbol, when we want something to be treated as a symbol, not as code

For example, `'(fun arg1 arg2)` is a list with the symbol fun and two arguments, while `(fun arg1 arg2)` is a function call.

Similarly, `(fun1 'fun2)` is a `fun1` function call with a symbol `'fun2` as an argument, while `(fun2 (fun1))` is a function call with the result of fun1 as an argument.

```elisp
(defun fun1 (text)
  (message "message: %s" text))

(defun fun2 ()
  "done2")

(fun1 'fun2)
--> message: fun2

(fun1 (fun2))
--> message: done2
```

All function calls look like above and, basically, this is the syntax of the language.

This way, for example, `2 + 2` in Emacs Lisp would be `(+ 2 2)`. This has an advantage of having the same syntax for multiple arguments, like `(+ 2 2 2 2)`.

Whitespace does not matter, we can format code for readability:

```elisp
(defun my-function (arg1 arg2)
  "Documentation"
  (if (> arg1 arg2)
      (message "arg1 is greater")
    (message "arg2 is greater")))
```

Note: Something like `number-or-marker-p` in the error message means that the function can accept either a number or a marker. The `p` at the end of the function name is a common convention in Emacs Lisp to indicate that the function returns a boolean value ("p" means "predicate").
Marker is the Emacs marker, position in a buffer and `+` in Emacs Lisp can add numbers or markers.

Show message (also demonstrates the string interpolation):

```elisp
(message "Hello, %s! %d times" "world" (+ 5 5))
```

Useful string functions:
- `(concat str1 str2)` - Concatenate strings
- `(substring str start end)` - Get a substring

The variable can be set with `setq` or `let`:

```elisp
(setq my-var "value")

(let ((my-var "value"))
  (message "my-var: %s" my-var))
```

Evaluating the variable:

```elisp
(setq flowers '(rose tulip daisy))
flowers
--> (rose tulip daisy)

'flowers
--> flowers

(setq trees '(oak maple pine)
      animals '(cat dog bird))
```

We can see above that we may set `flowers`, and we can quote it to get the symbol "flowers".

We can also set multiple variables at once as in last example above.

We can modify variables like this:

```elisp
(setq counter 0)
counter
--> 0

(setq counter (+ counter 1))
counter
--> 1
```

Useful Emacs functions for buffers:
- (buffer-name) - Get the buffer name
- (buffer-file-name) - Get the file name of the buffer
- (switch-to-buffer "buffer-name") - Switch to a buffer by name
- (switch-to-buffer-other-window "buffer-name") - Switch to a buffer in another window
- (switch-to-buffer (other-buffer)) - Switch to the previous buffer
- (buffer-size) - Get the size of the buffer
- (point) - Get the cursor position

Full function definition:

```elisp
     (defun FUNCTION-NAME (ARGUMENTS...)
       "OPTIONAL-DOCUMENTATION..."
       (interactive ARGUMENT-PASSING-INFO)     ; optional
       BODY...)
```

Comments start with a semicolon.

Functions with (interactive ..) right after the documentation can be executed with `M-x fn-name`.

Interactive function example:

```elisp
     (defun multiply-by-seven (number)       ; Interactive version.
       "Multiply NUMBER by seven."
       (interactive "p")
       (message "The result is %d" (* 7 number)))
```

The `"p"` in `interactive` means that the function will prompt the user for a prefix
argument (a number). Other options are: `"f"` - file, `"b"` - buffer, `"r"` - region.

The `(message "string")` function is used to show a message in the minibuffer.

A `let` is used to define a local variable or a set of variables for the body  of the let:

```elisp
     (let ((VARIABLE VALUE)
           (VARIABLE VALUE)
           ...)
       BODY...)

     (let ((zebra "stripes")
           (tiger "fierce"))
       (message "One kind of animal has %s and another is %s."
                zebra tiger))
```

A `let` returns the value of the last expression in the body.

By default `let` sets the variable to `nil`, for example, `(let ((a)) a)` returns `nil`. We can skip parentheses for `nil` values, so `(let (a) a)` is the same.

The `let*` is used to define variables that depend on the previous ones:

```elisp
     (let* ((VAR1 VALUE)
            (VAR2 (some-function VAR1))
            (VAR3 (some-function VAR2)))
       BODY...)
```

A `if` expression:

```elisp
     (if CONDITION
         THEN-EXPRESSION
       ELSE-EXPRESSION)

     (if (> 4 5)                               ; if-part
         (message "4 falsely greater than 5!") ; then-part
       (message "4 is not greater than 5!"))   ; else-part
```

Note: `nil` is false, everything else is true. In turn, `nil` is an empty list, same as `()`.

## Point, Mark and save-excursion

Point is the cursor position in the buffer.
Mark is some position in the buffer, `C-SPC` sets the mark, `C-u C-SPC` jumps to the mark.
Region is the text between point and mark.

`save-excursion` saves the cursor position ("point") and restores it after the code is executed:

```elisp
     (save-excursion
       BODY...)
```

Also, `save-excursion` saves the current buffer, window, and frame and restores them after
(so if the inner code jumps to another buffer, the current one will be reopened after `save-excursion`).

Alternatively, when we need to temporarily switch to another buffer, the `with-current-buffer` can be used
to execute code and then return to the original buffer:

```elisp
     (with-current-buffer ANOTHER-BUFFER-OR-NAME
       BODY...)
```

# TODO: continue

Manual:
- 4.3.1 Body of 'mark-whole-buffer'

Consult:
- M-x consult-history (disabled now)
- M-x consult-recent-file (disabled now)

Update readme:
- Add general information about consult, marginalia, vertico, orderless, corfu, cape, embark
  - https://github.com/minad/cape

## Debugging

Show stacktrace on errors: `M-x  toggle-debug-on-error`.

edebug - Emacs Lisp debugger, `M-x edebug-defun` to start debugging a function.

TODO: recheck

```
;; Emacs lisp
;; ;; https://learnxinyminutes.com/docs/elisp/
;;
;;
;; ;; combine sexps with progn
;; (progn
;;   (switch-to-buffer-other-window "*test*")
;;   (erase-buffer)
;;   (hello "you"))
;;
;; ;; `let` defines the local variable and it also works as `progn`
;; (let ((my-name "bugs"))
;;   (switch-to-buffer-other-window "*test*")
;;   (erase-buffer)
;;   (hello my-name)
;;   (other-window 1))
;;
;; (format "Hello %s!\n" "John")
;;
;; (defun greeting (name)
;;   (let ((your-name "Jack"))
;;     (insert (format "Hello %s! I am %s."
;;                     name
;;                     your-name)
;;             )))
;; (greeting "John")
;;
;; (read-from-minibuffer "Enter your name: ")
;;
;; (defun greeting (name)
;;   (let ((your-name (read-from-minibuffer "Enter your name: ")))
;;     (switch-to-buffer-other-window "*test*")
;;     (erase-buffer)
;;     (insert (format "Hello %s! I am %s."
;;                     name
;;                     your-name)
;;             )))
;; (greeting "John")
;;
;; (setq list-of-names '("Sarah" "Chloe" "Mathilde"))
;; ;; first elem
;; (car list-of-names)
;; ;; tail of the list after first elem
;; (cdr list-of-names)
;; ;; add elem at the beginning - it modifies the list
;; (push "Moo" list-of-names)
;; ;; call 'hello' for each element
;; (mapcar 'hello list-of-names)
;;
;; (defun greeting ()
;;   (switch-to-buffer-other-window "*test*")
;;   (erase-buffer)
;;   (mapcar 'hello list-of-names)
;;   (other-window 1))
;;
;; (greeting)
;;
;; (defun boldify-names ()
;;   (switch-to-buffer-other-window "*test*")
;;   (goto-char (point-min))
;;   (while (re-search-forward "hello \\(.+\\)!" nil 't)
;;     (add-text-properties (match-beginning 1)
;;                          (match-end 1)
;;                          (list 'face 'bold)))
;;   (other-window 1))
;; (boldify-names)
```

## Files and Directories, Dired

Dired: `C-x d`

## Org Mode

Open a file with `.org` extension to use Org mode or run `M-x org-mode`.

Structure:
- `*` - Heading
- `**` - Subheading

Text formatting:
- `*bold*`
- `/italic/`
- `_underline_`
- `=verbatim=`
- `~code~`
- `+strike-through+`

Lists:
- `-` - Unordered list
- `1.` - Ordered list

Links:
- `[[link]]`
- `[[link][description]]`
- `[[file:file.org]]`
- `[[file:file.org::heading]]`

Tables:
```
| Header 1 | Header 2 |
|----------+----------|
| Cell 1   | Cell 2   |
```

Code blocks:
- `#+BEGIN_SRC` - Start a code block
- `#+END_SRC` - End a code block

TODO items:
- `TODO` - Unfinished item
- `DONE` - Finished item

Scheduling:
- `SCHEDULED: <2021-01-01>` - Schedule an item for a specific date

Clocking:
- `C-c C-x C-i` - Start the clock
- `C-c C-x C-o` - Stop the clock
- `C-c C-x C-e` - Update the clock

Capturing:
- `C-c c` - Capture a note

Agenda:
- `C-c a a` - Open the agenda
- `C-c a t` - Open the agenda for today
- `C-c a w` - Open the agenda for the week
- `C-c a m` - Open the agenda for the month