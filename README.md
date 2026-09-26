# Intro

Config is based on kickstart, the original readme is down below.
https://github.com/MiniApollo/kickstart.emacs

The readme below is mostly a Emacs quick reference with more information in the following files:
* [./emacs.md](./emacs.md) - more information about emacs
* [./demo.org](./demo.org) - org mode demo and basic information
* [./README.KICKSTART.md](./README.KICKSTART.md) - the original kickstart project readme.

The entry point is the [.emacs](.emacs) config where there is non-kickstart stuff.
It includes the [init.el](init.el) with modified kickstart config.

Kickstart also has an org mode config, [init.org](init.org) - I don't use it, but it is a good source of information about the initial setup provided by kickstart.

# Emacs: Various information

See [./emacs.org](./emacs.org) for various Emacs information: terminology, getting help, keyboard shortcuts, dired, magit, etc.

# The most important command

I think the most important command is `M-x` that opens a command minbuffer with completion ("M-x" is "Alt+x" or "Option+x" or "Esc, x").

You can often guess which command you need based on its name.

# Evil mode vs Emacs mode

Use `C-z` to switch between Evil and Emacs.

Emacs keybindings can also be entered Evli in the insert mode. So, for example, if you want `C-u M-x ghostel`, go to the intert mode and then type `C-u`, `M-x` and `ghostel` in the command buffer (this opens a new terminal vs trying to re-open already existing one when you call it without `C-u`).

# Help

* `M-x info` to open manuals, `q` to quit, `l` to go back.
* `M-x describe-key`, `M-x describe-mode`, and other `describe-` commands to get quick information about things.
   * Or `~M-x helpful-key`, ... ("helpful" alternatives usually have nicer format)
* Quick help, show a reference card - M-x help-quick

Searching help:
- M-x apropos, C-h a - search for commands/variables by regex.
  - M-x apropos RET evil.*jump finds everything matching that pattern.
- M-x apropos-command - like apropos but for interactive commands (with M-x).
- M-x consult-apropos - fuzzy searchable apropos (with consult)

Searching help with consult and deadgrep:
- Use consult-ripgrep or deadgrep to search /usr/share/info/ (info manuals)
  - check where info files are, check with M-: Info-directory-list
  - M-x deadgrep RET a.b*c RET
    - then change the directory at the top to /usr/share/info/
  - C-u M-x consult-ripgrep RET /usr/share/info/ RET a.b*c

# Config: Problems to solve

Some problems with evil mode and my setup:
- jumplist does not work as well as in Vim (also plain Emacs does not have a jumplist)
  - Ctrl-I Ctrl-O does not work everywhere
  - In vim, it is a universal system similar to the browser back and forward navigation. It also works uniformly within the file (jumping between places in the file I visited, for example, with search) and across multiple files and buffers.
  - In emacs, Evil mode supports this, but it does not always work within the file and breaks in special buffers (such as help, magit, etc).
  - Emacs also has global mark history (`M-x pop-global-mark` and `M-x consult-global-mark`) that keeps the history of navigation across files (but not within the file) and some local marks system. Maybe these can be combined into vim-like behavior or maybe the evil mode can be tuned to work more reliably.
  - check https://github.com/gilbertw1/better-jumper
  - also: https://github.com/ganmacs/jumplist/tree/master
  - related: https://help-gnu-emacs.gnu.narkive.com/G4oeM1kY/vim-s-jumplist-equivalent-in-emacs
  - also: https://www.reddit.com/r/emacs/comments/3srwz6/idelike_go_back/
- undo after restart, persistent undo history (to be able to undo or g; after you restart emacs)
- The "Enter" in normal mode creates new line
  - In Vim it folds/unfolds the code (but I don't use it much, so NOOP is also fine)
- setup spellchecking
  - ~M-x ispell~ works to interactively spell-check the buffer, but it is nice to have mistakes automatically highlighted
- learn more about projectile and session save/restore
  - currently I have `(desktop-save-mode 1)`, see also related notes in [.emacs](.emacs)
- can I switch to emacs state for one command? Like one-time `C-z`
  - Would be nice to have a prefix like SMTH C-h C-i
- autosave: make it save on going from insert to normal and on focus lost
  - this is similar to my vim config and it is very reliable, basically
    it reliably saves when expected, each time I finished typing
- what is a good way to search throuh all help? Like :helpgrep in vim?
  - Maybe `M-x info-apropos`?
- I have `tn` to open new tab, it also opens the active buffer in it.
  - who do I make it open empty buffer instead? (I used to this in vim - is this really necessary though?)
- vim surround bindings?
- which text objects are available?
- System C-SPC conflict with emacs C-SPC (like C-SPC to start selection and
  C-x C-SPC to go back to previous mark)
- Some useful Emacs bindings are overwritten
  - For example, I use C-hjkl to move between windows, but C-j executes Lisp

Dired:
- How to have a more minimal view?
- Is dual pane-style file managment possible?

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

- How to use `C-u` in evil mode?
  - C-u in evil is "scroll up".
  - An easy way to use the universal argument is to switch to the insert mode (then `C-u M-x ...` will add the universal argument.
  - Another alternative: temporary switch to emacs mode with `Ctrl-Z` (and `Ctrl-Z` to switch back to evil).
- How to use emacs and evil commands when reading Info manuals and help?
  - Same as above: evil insert mode enables emacs keybindings. And `Ctrl-Z` can be used to switch between evil and emacs modes.
- After the upgrade to emacs 31.1, vertico throws errors
  - "The error says "Vertico detected an error: Press C-h e to see the stack trace]."
  - Fixed with `M-x package-recompile-all` and restarting emacs.
- The "*" behavoir
  - Solved: added `evil-visual-star`
  - in my vim setup in normal mode pressing `*` searches for the word under the cursor
    it also stays on the current word
    this should be a piece of custom setup, need to find and replicate it in emacs config
- Autocompletion uses Enter, so I cannot create a new line without selecting an option
  - Solve: see the note in init.el around `defun my-corfu-ret ()`
  - reconfigure to TAB? or Ctrl-n?
  - note: popup can be cancelled with `Ctrl-g`
- emacs hijacks windows (see .emacs around "display-buffer" for more information)
  - (partially fixed, partially I get used to emacs behavior, see the
    `define-minor-mode dedicated-mode` in the init.el and related comments)
  - Example: Ctrl-h i to open help then h to get help for help - replaces all windows
  - Example: Ctrl-h i to open help then M-n to duplicate it - replaces one of the existing windows
  - Workaround: M-x winner-mode adds `M-x winner-undo' (and redo) to undo these changes
- Add of find a ":GBrowse" command
  - Added `browse-at-remote` (see .emacs), also `magit`s `forge` has a similar command.
- SQL mode, something similar to vim's dbext.vim
  - Update: added config for sql-mode in .emacs - not the same as dbext, but very close.
  - have some configuration for available databases
    -- this can be configured in .git/.emacs.local.el (similar to my vim setup with .git/.vimrc.local - this gives no chance to accidentally commit DB parameters as they are under .git)
    -- the local file is automatically loaded when we open some file from the folder with `.git` directory
  - select the database to use
    -- sql-mode does this, run M-x sql-connect
  - run SQL statements from the buffer
    -- sql-mode provides commands for that, `sql-send-xxx`
  - get output in another buffer
    -- sql-mode opens the buffer with running db client and we have output there
- When searching with `/`, up/down arrows do not work
  - Up/down should scroll through the search history, it just exists the search mode
  - Solution: add `(evil-select-search-module 'evil-search-module 'evil-search)`
  - See https://emacs.stackexchange.com/a/31337
- LSP setup
  - "gt" in python source suggests to find tags table
    - in my vim setup that triggers the "go to definition" action.
  - this now works (at least for python)
- The ">" in normal mode messes up indentation
  - Solved with (evil-shift-round nil)
- autocompletion behavior
  - When I type something in the regular buffer and the auto-complete pops up,
  Enter selects the top suggesion and inserts it. In the minibuffer, Enter
  does not select the suggestion and instead confirms whatever was typed so far.
  I want the opposite behavior: Enter in regular buffer should insert the new
  line and Enter in minibuffer should select the completion.
  - Solution 1: configure corfu-map to set RET to nil (except the evil command line)
  - Solution 2: configure vertico with `(vertico-preselect 'first)`
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
- There is a problem with editing, I am suddenly getting into the
  "Buffer is read-only" state.
   After doing M-x read-only-mode to switch it off, I am also getting
   the "Text is read-only" state and then need to also do
   M-: (let ((inhibit-read-only t)) (set-text-properties (point-min) (point-max) ()))
  Not sure what causes it, maybe I'm triggering some keybinding accidentally.
  - did not see this recently, maybe emacs upgrade (29 to 30) helped

# Evil notes

Evil and evil-collection rebind Emacs commands to vim-like keys.

Use `C-z` to pause/unpause evil mode. It switches to the `evil-emacs-state` to have original Emacs keys reenabled. This is useful in some contexts, such as reading info pages (Emacs has convenient shortcuts for the info mode).

The `evil-collection` is a package that has many more or less independent sub-plugins to provide keybindings in popular contexts (such as dired, ibuffer, etc).
There is no explicit documentation on what keybindings are set by `evil-collection`, see [Inspecting-keymaps below](#inspecting-keymaps) for some hints on how to understand which keys do what.

## Inspecting evil keymaps

- how to find out current mode keybindings, when they are rebinded by evil or evil collection?
  - something similar to what I see with `:nnoremap` in vim
  - an obvious way is to find and look in the evil-collection source, but this is not convenient

Here are some options:
- The M-x describe-keybindings seems to work in a similar way to vim :map
- The M-x describe-mode lists all bindings, including evil
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
- Which key can show top-level mappings:
  - M-x which-key-show-top-level or M-x which-key-show-major-mode
- the M-x which-key-dump-bindings inserts all bindings

- how to find out if the command is bound to something?
  - M-x where-is RET command-name (or use C-h w)

- see which C-h commands are available:
  - in emacs state: C-h and wait for which key popup
  - in evil state:
  - M-x which-key-show-keymap RET help-command

Evil information:
- https://evil.readthedocs.io/en/latest/keymaps.html
- https://www.emacswiki.org/emacs/Evil

# deadgrep vs CtrlSF

I mostly use `CtrlSF` in vim to find things in the project.

`deadgrep` seems to be a close Emacs alternative.

- how to limit the search to a subfolder when searching with deadgrep?
  - in the search results window I can enter new directory at the top
  - is there a way to limit the search to subdirectory initially? (not critical,
    but would be nice)
- CtrlSF edit mode works like dired: does not save anything right away
  and there is a separate save operation (deadgrep edits files live)
- deadgrep edit mode needs to be explicitly enabled with M-x deadgrep-edit-mode
  while CtrlSF naturally starts in vim normal mode and "i" starts editing
- CtrlSF opens files by default in a split, deadgrep opens the file by default
  (not a problem, deadgrep has the deadgrep-visit-result-other-window command)

Related: https://www.reddit.com/r/emacs/comments/1pglgou/finally_i_have_my_beloved_quickfix_list_in_emacs/
In Emacs, **wgrep** (Writable Grep) brings this experience
* Run a search with `M-x grep-find` or something like this
* Results appear in a grep buffer — similar to Vim’s quickfix window
* Press `i` (in Evil’s Normal mode) to enter wgrep edit mode — the buffer becomes writable
* Edit the results directly. You can even run commands like `:%s/old/new/g` across all matches
* Save with `ZZ` or `:w`, and wgrep applies all changes back to the original source files automatically

# Emacs terminal emulators

## Questions and answers

- how do I start the new `term` terminal instance?
  - `C-u M-x term`
  - or use `ansi-term` or `vterm`

- how to run second instance of the "eat"?
  - C-u M-x eat

- "eat" produced some garbage output when entering and then deleting text
  - M-x eat-compile-terminfo helped

- how do I pass Ctrl-R to the terminal? With ansi-term it seems to be intercepted by emacs
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
- Written in Emacs Lisp
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
