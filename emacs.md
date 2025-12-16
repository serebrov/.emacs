## Terminology

Minibuffer is the line at the bottom of the screen where you can enter commands. Similar to the Vim command line.

Window is the Emacs term for a Vim split or a tmux pane.

Buffer is similar to the Vim buffer (file loaded in memory, can be displayed in a window or hidden).

Frame opens a new GUI window in GUI Emacs (and something similar to a tab in terminal Emacs).

The `M-` in keyboard shortcuts is "Meta" ("Option" key or "Alt" key). Alternatively, "Esc" can be used as meta, for example, press "Esc" and then "v" to move up one screen.

# Running emacs in terminal

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
- Eval emacs code in the buffer: C-x C-e
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

## Getting help

Emacs manual: C-h r, C-h i
Search on the current page: C-h s
Select a manual and search in it: C-h S

Describe package: C-h P
Describe current mode: C-h m
Describe function under cursor: M-x describe-function
Describe key: M-x describe-key

Quick reference card: M-x help-quick

Help on a topic:
- M-x Info-goto-emacs-command-node RET {topic} RET

- `C-h a {keyword}` - Search for a keyword in all commands
- `C-h b` - Show all key bindings

- `C-h k {key}` - Describe a key
  - `C-h k C-f` - Describe the `C-f` key
  - `M-x helpful-key`
- `C-h c {key}` - Show the command bound to a key
  - `C-h c C-f` - Show the command bound to the `C-f` key
- `C-h x {command}` - Describe a command
  - `C-h x forward-char` - Describe the `forward-char` command
- `C-h f {function}` - Describe a function
  - `C-h f forward-char` - Describe the `forward-char` function

- `C-h i` - Open the Info manual
  - `m Emacs` - Search for a topic

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
- `C-x o` - Move to the next window
- `C-M-v` - Scroll other window (useful for reading help)

## Managing Buffers

Buffer is similar to the Vim buffer.

- `C-x b` - Switch to another buffer
- `C-x k` - Kill a buffer
- `C-x C-b` - List all buffers

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

Configuration file is `~/.emacs.d/init.el`.
Use `M-x eval-buffer` to reload the configuration file.
Start Emacs with `emacs -q` to ignore the configuration file (if something is broken).

## Emacs Lisp

Lisp intro: `C-h i` to open manual, `m lisp intro` to open Lisp intro or `m elisp` to open Lisp manual.

- `C-x C-e` - Evaluate the expression before the cursor
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

## Debugging

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

Recheck:
- Dired: Switch to edit mode in dired with SPC b w -> writable dired
  - Can edit file names
  - Save with C-c C-c
 - Can use `SPC h SPC dired` to see dired settings in spacemacs-base layer
 - Mark files with `m`, R - rename/move, C - copy and `u` to unmark (also undelete)
 - `d` - delete, `u` - undelete, `x` - expunge, apply deletions
 - `+` - create directory
 - Change file/directory permissions with `M`
 - `(` - show / hide file details
 - `s` - change sort mode

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