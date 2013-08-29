
;; add load path ~/.emacs.lisp
(setq load-path
	  (append
	   (list
		(expand-file-name "~/.emacs.lisp")
		)
	   load-path))


;; テキストエンコーディングとしてUTF-8を優先使用
(prefer-coding-system 'utf-8)

;; 全角半角スペース色付け
(defface my-face-r-1 '((t (:background "gray15"))) nil)
(defface my-face-b-1 '((t (:background "gray"))) nil)
(defface my-face-b-2 '((t (:background "gray26"))) nil)
(defface my-face-u-1 '((t (:background "SteelBlue"))) nil)
(defvar my-face-r-1 'my-face-r-1)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)

(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(("\t" 0 my-face-b-2 append)
	 ("　" 0 my-face-b-1 append)
	 ("[ \t]+$" 0 my-face-u-1 append)
	 ("[\r]*\n" 0 my-face-r-1 append)
	 )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate-all 'font-lock-mode)


 ;; mini buffer color
 (set-face-foreground 'minibuffer-prompt "LightSeaGreen")
 (defun describe-face-at-point ()
   (interactive)
   (message "%s" (get-char-property (point) 'face)))

 ;;; *.~ とかのバックアップファイルを作らない
 (setq make-backup-files nil)

 ;;; .#* とかのバックアップファイルを作らない
 (setq auto-save-default nil)

 ;; バックアップファイルを消す
 (setq delete-auto-save-files t)

 ;; tab space
 ;(setq-default tab-width 2 indent-tabs-mode nil)
 (setq-default tab-width 4 indent-tabs-mode nil)
 (setq default-tab-width 4 )
 (setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60
						 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120))

 ;;十字キー効かなくする
 (global-set-key [up] nil)
 (global-set-key [right] nil)
 (global-set-key [down] nil)
 (global-set-key [left] nil)


 ;; cursor keybind change
 (global-set-key "\C-j" 'backward-char)
 (global-set-key "\C-f" 'forward-char)
 ;(global-set-key "\C-i" 'previous-line)
 (global-set-key "\C-n" 'next-line)

 (global-set-key "\C-m" 'newline-and-indent)
 (global-set-key "\C-t" 'indent-according-to-mode)

 (global-set-key "\C-g" 'forward-word)
 (global-set-key "\C-h" 'backward-word)

 ;; line nimber
 (require 'wb-line-number)
 (wb-line-number-toggle)

 ;;(require 'dvorak)
 ;;(global-set-key "\e1" 'dvorak-off)
 ;;(global-set-key "\e2" 'dvorak-on)

 (require 'anything)

 ;;(require 'qwerty)

 ;; color
 (if window-system (progn
	(setq initial-frame-alist '((width . 80) (height . 30)))
	(set-background-color "RoyalBlue4")
	(set-foreground-color "LightGray")
	(set-cursor-color "Gray")
 ))


 ;;moving window
 (defun select-next-window ()
	 "Switch to the next window"
	   (interactive)
		 (select-window (next-window)))

 (defun select-previous-window ()
	 "Switch to the previous window"
	   (interactive)
		 (select-window (previous-window)))

 (global-set-key (kbd "ESC <up>") 'select-next-window)
 (global-set-key (kbd "ESC <down>")  'select-previous-window)


 ;;
 ;;self add
 ;;

 ;;php-mode
 (load-library "php-mode")
 (require 'php-mode)
 (add-to-list 'auto-mode-alist '("\\.ctp$" . php-mode))

 ;; as
 (autoload 'actionscript-mode "actionscript-mode" "actionscript" t)
 (setq auto-mode-alist
			 (append '(("\\.as$" . actionscript-mode))
								   auto-mode-alist))

 ;; js
 (autoload 'js2-mode "js2" nil t)
 (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

 (autoload 'espresso-mode "espresso")

 (defun my-js2-indent-function ()
   (interactive)
   (save-restriction
	 (widen)
	 (let* ((inhibit-point-motion-hooks t)
			(parse-status (save-excursion (syntax-ppss (point-at-bol))))
			(offset (- (current-column) (current-indentation)))
			(indentation (espresso--proper-indentation parse-status))
			node)

	   (save-excursion

		 ;; I like to indent case and labels to half of the tab width
		 (back-to-indentation)
		 (if (looking-at "case\\s-")
			 (setq indentation (+ indentation (/ espresso-indent-level 2))))

		 ;; consecutive declarations in a var statement are nice if
		 ;; properly aligned, i.e:
		 ;;
		 ;; var foo = "bar",
		 ;;     bar = "foo";
		 (setq node (js2-node-at-point))
		 (when (and node
					(= js2-NAME (js2-node-type node))
					(= js2-VAR (js2-node-type (js2-node-parent node))))
		   (setq indentation (+ 4 indentation))))
	   (indent-line-to indentation)
	   (when (> offset 0) (forward-char offset)))))

 (defun my-indent-sexp ()
   (interactive)
   (save-restriction
	 (save-excursion
	   (widen)
	   (let* ((inhibit-point-motion-hooks t)
			  (parse-status (syntax-ppss (point)))
			  (beg (nth 1 parse-status))
			  (end-marker (make-marker))
			  (end (progn (goto-char beg) (forward-list) (point)))
			  (ovl (make-overlay beg end)))
		 (set-marker end-marker end)
		 (overlay-put ovl 'face 'highlight)
		 (goto-char beg)
		 (while (< (point) (marker-position end-marker))
		   ;; don't reindent blank lines so we don't set the "buffer
		   ;; modified" property for nothing
		   (beginning-of-line)
		   (unless (looking-at "\\s-*$")
			 (indent-according-to-mode))
		   (forward-line))
		 (run-with-timer 0.5 nil '(lambda(ovl)
									(delete-overlay ovl)) ovl)))))

 (defun my-js2-mode-hook ()
   (require 'espresso)
   (setq espresso-indent-level 4
		 indent-tabs-mode nil
		 c-basic-offset 4)
   (c-toggle-auto-state 0)
   (c-toggle-hungry-state 1)
   (set (make-local-variable 'indent-line-function) 'my-js2-indent-function)
										 ; (define-key js2-mode-map [(meta control |)] 'cperl-lineup)
   (define-key js2-mode-map "\C-\M-\\"
	 '(lambda()
		(interactive)
		(insert "/* -----[ ")
		(save-excursion
		  (insert " ]----- */"))
		))
   (define-key js2-mode-map "\C-m" 'newline-and-indent)
										 ; (define-key js2-mode-map [(backspace)] 'c-electric-backspace)
										 ; (define-key js2-mode-map [(control d)] 'c-electric-delete-forward)
   (define-key js2-mode-map "\C-\M-q" 'my-indent-sexp)
   (if (featurep 'js2-highlight-vars)
	   (js2-highlight-vars-mode))
   (message "My JS2 hook"))
(add-hook 'js2-mode-hook 'my-js2-mode-hook)


(require 'coffee-mode)
(add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))
(add-to-list 'auto-mode-alist '("Cakefile" . coffee-mode))


(add-hook 'php-mode-hook
          (lambda ()
            (c-set-offset 'case-label' 2)
            (c-set-offset 'arglist-intro' 2)
            (c-set-offset 'arglist-cont-nonempty' 2)
            (c-set-offset 'arglist-close' 0)))