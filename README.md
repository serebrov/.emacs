# Intro

Config is based on kickstart, the original reamde is down below.
https://github.com/MiniApollo/kickstart.emacs

The entry point is the [.emacs](.emacs) config where there is non-kickstart stuff.
It includes the [init.el](init.el) with modified kickstart config.

Kickstart also has an org mode config, [init.org](init.org) - I don't use it, but it is a good source of information about the initial setup provided by kickstart.

# Basic emacs keybindings

I use evil, but it is good to know basic keybindings and be able to move around without evil.

More information is in the [emacs.md](emacs.md).

Note: "M-" (Meta) in shortcuts is "Opt" or "Alt, or "Esc" followed by letter.

Open/save/quit:
- Open file: C-x C-f
- Save: C-x C-s or M-x save-buffers
- Quit emacs: `C-x C-c`

Move around:
- use arrow keys
- Page up/down: C-v / M-v or actual PgUp / PgDown keys

Cancel current operation: C-g (which is usually done with Esc in vim)
- Close minibuffer
- Close autocompletion popup

Search in the document: C-s (next C-s, prev C-r)

Cancel current operation: C-g (which is usually done with Esc in vim)

Select, copy/paste:
- Select text: C-space
- Copy/Cut/Paste: M-w, C-w, C-y

Undo and redo:
- `C-/` - Undo, also `C-x u`, also `C-_`
  - Undo also does redo, so `C-/` undoes the undo
  - Also use `C-g` to reverse the direction of undos/redos when doing multiple undos/redos, see https://stackoverflow.com/a/18383455

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

Repeating commands:
- `C-u {number} {command}` - repeat the command {number} times
  - `C-u 4 C-n` - move down 4 lines

Dired: `C-x d`

# Reading Info manuals

In the Info manual:
- scroll up/down: `spc` / `backspace` (or `DEL` or `b`).
  - `spc` at the end of a node to go to the next node.
- Show menu: `m`
- Cycle through menu items: `TAB`
- Go back/forward in history (like jump list): `l` / `r`
  - Note that `l` is a universal back command, it works in many contexts.
  - See the history: `L`
- Next/prev node, sequentially:  `[` / `]` (same as space/backspace, but without scrolling)
- Next/prev node on the same level: `n` and `p` (will skip lower level nodes)
- Table of contents: `t` (top)
- Parent node: `u` (up one level)

- All manuals (directory): `d` to go to the directory of all manuals.

- Search: `s`
  - Incremental search: `C-s` or `C-r`
  - Search in the index: `i` (`I` to create a page with results)
- Search everywhere: M-x info-apropos

Info has some hints in the top and bottom bars:
- The "Prev: ..." in the header shows where "p" would take you
  - Similarly, "Up:" shows the top level node ()
- The mode line at the bottom shows where we are now (*info* (info) NodeName)
- The mode line at the bottom also says "Top" (we see part of the text) or "All" (all text is visible)

# Getting help in Emacs

Shortcuts (in emacs state):
- Read Emacs manual: M-x info-emacs-manual, `C-h r`
- Describe current mode - M-x describe-mode
- Describe a key - M-x describe-key or M-x helpful-key, `C-h k`
  - `helpful-xxx` alternatives usually give nicer formatted output
- Show the command bound to a key - M-x describe-key-briefly, C-h c {key}
- Describe a command, M-x describe-function or M-x helpful-command
  - For example, M-x helpful-callable helpful-callable
 - Quick help, show a reference card - M-x help-quick
  - This will show emacs keybindings

Note on key shortcuts: default Emacs shortcuts such as `C-h r` to display the manual do not work in Evil mode. The unified way is to use `M-x` commands. Alternatively, press `C-g` to swich to `evil-emacs-state` then evil keys are disabled and native Emacs shortcuts are working.

Searching help:
- M-x info-apropos - search all info manuals for a string
  - this is similar to vim's :helpgrep, but does not support wildcards
- M-x consult-info - search with consult, fuzzy completion
  - C-u M-x consult-info to select manual to search
- M-x Info-search (or s in the info buffer) - search in the current manual
- Use consult-ripgrep or deadgrep to search /usr/share/info/ (info manuals)
  - check where info files are, check with M-: Info-directory-list
  - M-x deadgrep RET a.b*c RET
    - then change the directory at the top to /usr/share/info/
  - C-u M-x consult-ripgrep RET /usr/share/info/ RET a.b*c
- M-x apropos, C-h a - search for commands/variables by regex.
  - M-x apropos RET evil.*jump finds everything matching that pattern.
- M-x apropos-command - like apropos but for interactive commands (with M-x).
- M-x consult-apropos - fuzzy searchable apropos (with consult)

Describing things:
- M-x describe-function - documentation for a function/command, C-h f
  - M-x helpful-callable gives nicer output
- M-x describe-variable - variable value and documentation, C-h v
  - M-x helpful-variable gives nicer output
  - for example, M-x helpful-variable RET evil-normal-state-map
  - for example, M-x helpful-variable RET evil-want-C-u-scroll
- M-x describe-symbol - describes any symbol (function, variable, face, etc.), a catch-all, C-h o

# Emacs interacitve commands and prefix system

Interactive commands are special functions that can be executed with `M-x`. These special functions are able to take extra arguments passed via Emacs prefix system.

The prefix is a key combination that you use before executing the actual command, for example, to repeat the "move down" command we do `C-u 4 C-n`. This moves down 4 lines.

In this example the `C-u 4` is the prefix that passes `4` as an argument to the next command (`C-n` that is bound to the `next-line` command).

One more example: the `forward-char` command moves the cursor forward. We can do the following with prefixes:
- C-f or M-x forward-char → moves forward 1 character
- M-5 C-f → moves forward 5 characters
- C-u 10 C-f → moves forward 10 characters
- C-u C-f → moves forward 4 characters (C-u alone defaults to 4)

Note that the prefix can be passed either with `C-u {n}` or with `M-{n}`.

The `C-u` on its own passes the "default" argument which usually tells the command "do what you usually do, but differently". For example, `M-x run-lisp` starts the default lisp REPL and `C-u M-x run-lisp` will ask which REPL to run before starting it.

The run-lisp function's code basically does this:

```emacs-lisp
(defun run-lisp (arg)
  (interactive "P")  ;; "P" means "accept a prefix argument"
  (if arg
      ;; If ANY argument was passed, prompt user
      (read-string "Run lisp: " inferior-lisp-program)
    ;; Otherwise use default
    inferior-lisp-program))
 ```

It does not care what agrument we pass as long as we pass something.

In the case we want to distingish arguments, we can do it like this:

```emacs-lisp
(defun my-command (arg)
  (interactive "P")
  (cond
   ((null arg) (message "No argument"))
   ((= arg 1) (message "You passed 1!"))
   ((= arg 2) (message "You passed 2!"))
   ((= arg 4) (message "You pressed C-u"))
   (t (message "You passed: %d" arg))))
```

Functions can also have multiple agruments. The prefix argument (M-6, C-u, etc.) is special - it's captured before the command runs and is separate from other arguments. All other arguments are gathered by prompting the user through the minibuffer.

So when we do:

```emacs-lisp
M-5 M-x replace-string RET foo RET bar RET
```

We have the following sequence of actions:
- M-5 sets a prefix argument (which replace-string might use to limit replacements, depending on the command)
- Then it prompts for "foo"
- Then it prompts for "bar"

To pass a negative argument use `C--5 ...` or `M--5 ...`.  The `C-- ...` works as `-1` (same for `M-- ...`). Also we can use `C-u -5 ...` and `C-u - ...`.

# Problems to solve

Some problems with evil and my setup:
- SQL mode, something similar to vim's db-ext
  - have some configuration for available databases
  - select the database to use
  - run SQL statements from the buffer
  - get output in another buffer
- learn more about projectile and session save/restore
  - currently I have `(desktop-save-mode 1)`, see also related notes in [.emacs](.emacs)
- learn more about org mode
- can I switch to emacs state for one command? Like one-time `C-g`
  - Would be nice to have a prefix like SMTH C-h C-i
- autosave: make it save on going from insert to normal and on focus lost
  - this is similar to my vim config and it is very reliable, basically
    it reliably saves when expected, each time I finished typing
- what is a good way to search help? Like :helpgrep in vim?
- emacs hijacks windows (testing popper as a solution)
  - Example: Ctrl-h i to open help then h to get help for help - replaces all windows
  - Example: Ctrl-h i to open help then M-n to duplicate it - replaces one of the existing windows
  - Workaround: M-x winner-mode adds `M-x winner-mode-undo' (and redo) to undo these changes
- Autocompletion uses Enter, so I cannot create a new line without selecting an option
  - reconfigure to TAB? or Ctrl-n?
- vim surround bingings?
- which text objects are available?
- System C-SPC conflict with emacs C-SPC (like C-SPC to start selection and
  C-x C-SPC to go back to previous mark)
- jumplist does not work as well as in Vim (also plain Emacs does not have a jumplist)
  - check https://github.com/gilbertw1/better-jumper
  - also: https://github.com/ganmacs/jumplist/tree/master
  - related: https://help-gnu-emacs.gnu.narkive.com/G4oeM1kY/vim-s-jumplist-equivalent-in-emacs
  - also: https://www.reddit.com/r/emacs/comments/3srwz6/idelike_go_back/
- Some useful Emacs bindings are overwritten
  - For example, I use C-hjkl to move between windows, but C-j executes Lisp
- LSP does not work in python code
- persistent undo history (to be able to undo or g; after you restart emacs)

# Tips for solving problems

For debugging errors in the config it may be useful to enable stacktrace:

```
M-x toggle-debug-on-error
```

Useful for figuring out "what did I just accidentally press?":
- M-x view-lossage, C-h l - last 300 keystrokes you typed.

Checking the `*Messages*` buffer:
- M-x view-echo-area-messages, C-h e
- helpful for seeing errors or output you missed

# Solved problems

- shortcuts to move windows with SPC + Ctrl + hjkl
  - done, using `evil-window-move-far-right` and similar commands
- how to do `:set nowrap`?
  - use `M-x toggle-truncate-lines`
- need some fzf-like file finder
  - there is SPC-. but it does not search for files recursively
  - solved: SPC p f calls projectile-find-file and it does fuzzy recursive search
- C-R commands do not work (for example, C-R C-W in command mode should insert word under cursor)
  - solved in this setup probably by evil-collection
  - solved before with https://github.com/tarao/evil-plugins
- vinegar behavior (- opens dired in the same window)
  - solved with `dired-jump' mapping
    Vinegar-style: "-" opens dired in current file's directory
    (define-key evil-normal-state-map (kbd "-") 'dired-jump)
- comment/uncomment with gc?
  (define-key evil-normal-state-map (kbd "g c") 'comment-line)
  (define-key evil-visual-state-map (kbd "g c") 'comment-line)
- How to save sessions?
  This seems to work:
  - M-x desktop-write, M-x desktop-read
  - M-x desktop-clear
  But maybe also projectile- and project- have something similar.
- C-F in command line mode / search mode to show command buffer (same as shown with q: and q/)
  - works in this setup, maybe evil-collection or evil itself
- There is a problem with editing, I am suddently getting into the
  "Buffer is read-only" state.
   After doing M-x read-only-mode to switch it off, I am also getting
   the "Text is read-only" state and then need to also do
   M-: (let ((inhibit-read-only t)) (set-text-properties (point-min) (point-max) ()))
  Not sure what cases it, maybe I'am triggering some keybinding accidentally.
  - did not see this recently, maybe emacs upgrade (29 to 30) helped

# Evil notes

Evil and evil-collection rebind Emacs commands to vim-like keys.

Use `C-g` to pause/unpause evil mode. It switches to the `evil-emacs-state` to have original Emacs keys reenabled. This is useful in some contexts, such as reading info pages (Emacs has convenient shortcusts for the info mode).

The `evil-collection` is a package that has many more or less independent sub-plugins to provide keybindings in popular contexts (such as dired, ibuffer, etc).
There is no explicit documentation on what keybindings are set by `evil-collection`, see [Inspecting-keymaps below](#inspecting-keymaps) for some hings on how to understand which keys do what.

## Inspeciting evil keymaps

- how to find out current mode keybindings, when they are rebinded by evil or evil collection?
  - something similar to what I see with `:nnoremap` in vim
  - an obvious way is to find and look in the evil-collection source, but this is not convenient

Here are some options:
- The M-x describe-keybindings seems to work in a similar way to vim :map
- The M-x describe-mode lists all binidings, including evil
  - need to scroll down through standard bindings.
  - For example, for dired, there are mappings like
    <normal-state> RET dired-find-file
- Check evil keybinding maps:
  - M-x helpful-variable RET evil-normal-state-map
  - M-x helpful-variable RET evil-motion-state-map
  - note that `M-x describe-variables` also works, but will show key codes
    not actual keys while `M-x helpful-variable` displays it as a keymap
  - Lookup key in the map:
    - M-: (lookup-key evil-normal-state-map (kbd "your-key"))
- Which key can show top-level mappinngs:
  - M-x which-key-show-top-level or M-x which-key-show-major-mode
- the M-x which-key-dump-bindings insers all bingings

- how to find out if the command is bound to something?
  - M-x where-is RET command-name (or use C-h w)

- see which C-h commands are available:
  - in emacs state: C-h and wait for which key popup
  - in evil state:
  - M-x which-key-show-keypmap RET help-command

Evil information:
- https://evil.readthedocs.io/en/latest/keymaps.html
- https://www.emacswiki.org/emacs/Evil

# deadgrep vs CtrlSF

I mostly use `CtrlSF` in vim to find things in the project.

`deadgrep` seems to be a close Emacs alternative.

- how to limit the search to a subfolder when searching with deadgrep?
  - in the search results window I can enter new directory at the top
  - is there a way to limit the search to subdirectory initally? (not critical,
    but would be nice)
- CtrlSF edit mode works like dired: does not save anything right about
  (deadgrep edits files live)
- deadgrep edit mode needs to be explicitely enabled with M-x deadgrep-edit-mode
  while CtrlSF naturally starts in vim normal mode and "i" starts editing
- CtrlSF opens files by default in a split, deadgrep opens the file by default
  (not a problem, deadgrep has the deadgrep-vist-result-other-window command)

Related: https://www.reddit.com/r/emacs/comments/1pglgou/finally_i_have_my_beloved_quickfix_list_in_emacs/
In Emacs, **wgrep** (Writable Grep) brings this experience
* Run a search with `M-x grep-find` or something like this
* Results appear in a grep buffer — similar to Vim’s quickfix window
* Press `i` (in Evil’s Normal mode) to enter wgrep edit mode — the buffer becomes writable
* Edit the results directly. You can even run commands like `:%s/old/new/g` across all matches
* Save with `ZZ` or `:w`, and wgrep applies all changes back to the original source files automatically

# Emacs terminal emulators

## Problems and solutions

- how do I start the new `term` terminal instance?
  - `C-u M-x term`
  - or use `ansi-term` or `vterm`

- how to run second instance of the "eat"?
  - C-u M-x eat

- "eat" produced some garbage output when entering and then deleting text
  - M-x eat-compile-terminfo helped

- how do I pass Ctrl-R to the terminal? With ansi-term it seems to be insercepted by emacs
 - use C-c C-k to switch to char mode (keys send directly)
   the C-c C-j switches back to line mode (Emacs intercepts keys)
   use C-q C-r to send the key to the terminal once
   the advantage of the line mode is that we can use emacs
   keybindings for editing; copy/paste is easier, and we
   can also use emacs keybindings to move around, scroll,
   copy, etc.
   note: vterm should handle this more seamless

## Emulators overview

What is the difference between terminal emulators? I have
term, ansi-term, shell, eshell, also there is eat in my setup
and I see recommendations of vterm.

shell (M-x shell)
- Not a terminal emulator, runs a shell subprocess with input/output through a regular buffer
- No curses/TUI support (can't run htop, vim, etc.)
- Good for simple command-line work where you want Emacs keybindings

eshell (M-x eshell)
- A shell written entirely in Emacs Lisp, not a terminal
- Can mix shell commands with Lisp expressions
- Emacs buffer integration (redirect output to buffers, pipe through Emacs functions)
- No TUI support

term (M-x term)
- Terminal emulator using term.el
- Supports TUI applications
- Single buffer name by default (opens same instance if I do M-x term again)

ansi-term (M-x ansi-term)
- Wrapper around term with better ANSI color handling
- Creates uniquely-named buffers automatically

vterm
- External package
- Uses libvterm, a C library — should be faster than term/ansi-term
- Handles TUI apps, colors
- Requires compilation (needs cmake and libvterm)

eat (Emulate A Terminal)
- Wirtten in Emacs Lisp
- No compilation required (unlike vterm)
- Good terminal compatibility
- Integrates with eshell (eat-eshell-mode)

# Original Kickstart Readme

See: https://github.com/MiniApollo/kickstart.emacs

https://github.com/MiniApollo/kickstart.emacs/assets/72389030/5c66130d-66b9-459b-a26d-210f3f937459

# Table of Contents

1.  [Introduction](#orgb229cbd)
    -  [Packages](#orgb05d649)
    -  [Helpful resources](#orgfaf0570)
2.  [Installation](#orgb633c86)
    -  [1. Requirements](#orgb7bc22f)
    -  [2. Backup your previous configuration](#org6189661)
    -  [3. Clone the repository to the configuration location](#org820a205)
    -  [4. Start Emacs](#orgd77a070)
3.  [Post Installation](#org60302a9)
    -  [1. Install fonts](#org87d8fc9)
    -  [2. Open the configuration file](#org94fe140)
    -  [3. Fork the repository](#org23b14b0)
4.  [Uninstallation](#org14852f4)
5.  [Gallery](#orgc18728a)

<a id="orgb229cbd"></a>

# Introduction
This repository gives you a starting point for Gnu Emacs with good defaults, optional vim keybindings and packages that most people may want to use.

Kickstart.emacs is **not** a distribution. <br>
It's a template for your own configuration.

This config is:
-   A single file **org document** (with examples of moving to multi-file)
-   Modular and easily configurable
-   Documented describing its purpuse

Inspired by [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)

Special thanks to:
-   [DistroTube](https://www.youtube.com/watch?v=d1fgypEiQkE&list=PL5--8gKSku15e8lXf7aLICFmAHQVo0KXX)
-   [System Crafters](https://www.youtube.com/watch?v=74zOY-vgkyw&list=PLEoMzSkcN8oPH1au7H6B7bBJ4ZO7BXjSZ)

Their content helped me to create this configuration.

<a id="orgb05d649"></a>

## Packages

### Included Package list

-   Package Manager: Package.el with Use-package (built in)
-   Optin [Evil mode](https://github.com/emacs-evil/evil): An extensible vi/vim layer
-   [General](https://github.com/noctuid/general.el): Keybindings
-   [Gruvbox-theme](https://github.com/greduan/emacs-theme-gruvbox): Color scheme
-   [Doom-modeline](https://github.com/seagle0128/doom-modeline): Prettier, more useful modeline
-   [Nerd Icons](https://github.com/rainstormstudio/nerd-icons.el): For icons and more helpful ui (Supports both GUI and TUI)
-   [Projectile](https://github.com/bbatsov/projectile): Project interaction library
-   [Eglot](https://www.gnu.org/software/emacs/manual/html_mono/eglot.html): Language Server Protocol Support
-   [Sideline-Flymake](https://github.com/emacs-sideline/sideline-flymake): Show flymake errors with sideline 
-   [Yasnippet](https://github.com/joaotavora/yasnippet): Template system and snippet collection package
-   Optin [Tree-Sitter](https://tree-sitter.github.io/tree-sitter): A parser generator tool and an incremental parsing library.
-   Some [Org mode](https://orgmode.org/) packages (toc-org, org-superstar)
-   [Eat](https://codeberg.org/akib/emacs-eat): Fast terminal emulator within Emacs
-   [Magit](https://github.com/magit/magit): Complete text-based user interface to Git
-   [Diff-hl](https://github.com/dgutov/diff-hl): Highlights uncommitted changes
-   [Corfu](https://github.com/minad/corfu): Enhances in-buffer completion
-   [Cape](https://github.com/minad/cape): Provides Completion At Point Extensions
-   [Orderless](https://github.com/oantolin/orderless): Completion style that matches candidates in any order
-   [Vertico](https://github.com/minad/vertico): Provides a performant and minimalistic vertical completion UI.
-   [Marginalia](https://github.com/minad/marginalia): Adds extra metadata for completions in the margins (like descriptions).
-   [Consult](https://github.com/minad/consult): Provides search and navigation commands.
-   [Helpful](https://github.com/Wilfred/helpful): A better Emacs *help* buffer 
-   [Diminish](https://github.com/myrjola/diminish.el): Hiding or abbreviation of the modeline displays
-   [Rainbow Delimiters](https://github.com/Fanael/rainbow-delimiters): Adds colors to brackets.
-   [Which key](https://github.com/justbur/emacs-which-key): Helper utility for keychords
-   [Ws-butler](https://github.com/lewang/ws-butler): Removes whitespace from the ends of lines.

### Recommended Packages

If you want to see how to configure these, look up their git repositories or check out my [config](https://github.com/MiniApollo/config/blob/main/emacs/config.org).

-   **[DashBoard](https://github.com/emacs-dashboard/emacs-dashboard):** Extensible startup screen.
-   **[Drag Stuff](https://github.com/rejeep/drag-stuff.el):** Makes it possible to move selected text, regions and lines.
-   **[Rainbow Mode](https://github.com/emacsmirror/rainbow-mode):** Displays the actual color as a background for any hex color value (ex. #ffffff).
-   **[UndoTree](https://www.emacswiki.org/emacs/UndoTree):** Visualizes the undo history (alternative: [Vundo](https://github.com/casouri/vundo) with [undo-fu-session](https://github.com/emacsmirror/undo-fu-session)).
-   **[Vterm](https://github.com/akermu/emacs-libvterm):** Fast, Fully-fledged terminal emulator inside GNU Emacs.
-   **[Multi-vterm](https://github.com/suonlight/multi-vterm):** Managing multiple vterm buffers in Emacs 
-   **[Sudo-edit](https://github.com/nflath/sudo-edit):** Utilities for opening files with root privileges (also works with doas).

<a id="orgfaf0570"></a>

## Helpful resources

Videos and configurations to get started.

-   **[Emacs From Scratch by System Crafters](https://www.youtube.com/watch?v=74zOY-vgkyw&list=PLEoMzSkcN8oPH1au7H6B7bBJ4ZO7BXjSZ):** Very detailed video series about building Gnu Emacs from the ground up.
-   **[Configuring Emacs by DistroTube](https://www.youtube.com/watch?v=d1fgypEiQkE&list=PL5--8gKSku15e8lXf7aLICFmAHQVo0KXX):** Shorter but also very detailed video series about configuring Emacs from scratch.
-   **[Mastering Emacs](https://www.masteringemacs.org/):** An awesome blog covering interesting topics and practical tips about Emacs.
-   **[Purcell's emacs configuration](https://github.com/purcell/emacs.d):** Emacs configuration bundle with batteries included.
-   **[Spacemacs](https://www.spacemacs.org/) and [Doom Emacs](https://github.com/doomemacs/doomemacs):** For an out of box experience and their wiki pages are really helpful.
-   **[More starter kits](https://www.emacswiki.org/emacs/StarterKits ):** List of starter kits for Emacs.
-   **[Emacs manual](https://www.gnu.org/software/emacs/manual/html_node/emacs/index.html):** For learning the fundamentals of Emacs.


<a id="orgb633c86"></a>

# Installation


<a id="orgb7bc22f"></a>

## 1. Requirements

-   Gnu Emacs 30.1 or later (Latest stable release)
-   Git (To clone/download this repository)


### Optional:

-   ripgrep
-   fd (improves file indexing performance for some commands)
-   Gnu Emacs with [native-compilation](https://www.emacswiki.org/emacs/GccEmacs) (provides noticeable performance improvements)


<a id="org6189661"></a>

## 2. Backup your previous configuration

If any exists.

<a id="org820a205"></a>

## 3. Clone the repository to the configuration location

### Linux and Mac
```sh
git clone https://github.com/MiniApollo/kickstart.emacs.git "${XDG_CONFIG_HOME:-$HOME/.config}"/emacs
```

### Windows

-   **CMD:**
```sh
git clone https://github.com/MiniApollo/kickstart.emacs.git %userprofile%\AppData\Local\emacs\
```
-   **Powershell:**
```sh
git clone https://github.com/MiniApollo/kickstart.emacs.git $env:USERPROFILE\AppData\Local\emacs\
```

<a id="orgd77a070"></a>

## 4. Start Emacs

Emacs will install all the requested packages (it can take a minute).

> **Note:**
> If you see errors, warnings when package installation is finished just restart Emacs.

<a id="org60302a9"></a>

# Post Installation

<a id="org87d8fc9"></a>

## 1. Install fonts

Run the following command with M-x (alt-x) C-y to paste

```sh
nerd-icons-install-fonts
```

Change or install JetBrains Mono font

<a id="org94fe140"></a>

## 2. Open the configuration file

1.  Hit Ctrl-Space-s-c to open the config file at $HOME/.config/emacs

> **Note**
> If you use Windows you need to change the path (hit C-x C-f, find the config file and in general region replace the path)

2.  Now you can Edit and add more configuration.

<a id="org23b14b0"></a>

## 3. Fork the repository

Recommended so that you have your own copy to modify.

<a id="org14852f4"></a>

# Uninstallation

To uninstall kickstart.emacs, you need to remove the following directory:

-   Delete the emacs folder/directory for your OS (E.g. $HOME/.config/emacs/).

<a id="orgc18728a"></a>

# Gallery

![Emacs_KickStarter](https://github.com/MiniApollo/kickstart.emacs/assets/72389030/b82bb86b-ce49-4b0a-8fe7-2ca8b8c422fb)
![Kickstart_coding](https://github.com/MiniApollo/kickstart.emacs/assets/72389030/8e560d2b-78f5-4306-8f6a-c70ad189f181)
