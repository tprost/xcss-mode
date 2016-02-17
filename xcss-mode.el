(require 'css-mode)
(require 'smie)

(defface css-selector '((t :inherit font-lock-keyword-face))
	"Face to use for selectors."
	:group 'css)

(defface css-property '((t :inherit font-lock-variable-name-face))
	"Face to use for properties."
	:group 'css)

(defun xcss--font-lock-keywords (&optional sassy)
	`((,(concat "!\\s-*"
							(regexp-opt (append (if sassy '("global"))
																	'("important"))))
		 (0 font-lock-builtin-face))
		;; Atrules keywords.	IDs not in css-at-ids are valid (ignored).
		;; In fact the regexp should probably be
		;; (,(concat "\\(@" css-ident-re "\\)\\([ \t\n][^;{]*\\)[;{]")
		;;	(1 font-lock-builtin-face))
		;; Since "An at-rule consists of everything up to and including the next
		;; semicolon (;) or the next block, whichever comes first."
		(,(concat "@" css-ident-re) (0 font-lock-builtin-face))
		;; Selectors.
		;; FIXME: attribute selectors don't work well because they may contain
		;; strings which have already been highlighted as f-l-string-face and
		;; thus prevent this highlighting from being applied (actually now that
		;; I use `keep' this should work better).	 But really the part of the
		;; selector between [...] should simply not be highlighted.
		(,(concat
			 "^[ \t]*\\("
			 (if (not sassy)
					 ;; We don't allow / as first char, so as not to
					 ;; take a comment as the beginning of a selector.
					 "[^@/:{} \t\n][^:{}]+"
				 ;; Same as for non-sassy except we do want to allow { and }
				 ;; chars in selectors in the case of #{$foo}
				 ;; variable interpolation!
				 (concat "\\(?:" scss--hash-re
v								 "\\|[^@/:{} \t\n#]\\)"
								 "[^:{}#]*\\(?:" scss--hash-re "[^:{}#]*\\)*"))
			 ;; Even though pseudo-elements should be prefixed by ::, a
			 ;; single colon is accepted for backward compatibility.
			 "\\(?:\\(:" (regexp-opt (append css-pseudo-class-ids
																			 css-pseudo-element-ids) t)
			 "\\|\\::" (regexp-opt css-pseudo-element-ids t) "\\)"
			 "\\(?:([^)]+)\\)?"
			 (if (not sassy)
					 "[^:{}]*"
					 "[^:{}]*"
;				 (concat "[^:{}\n#]*\\(?:" scss--hash-re "[^:{}\n#]*\\)*")

				 )
			 "[ \t\n]*"
			 "\\)*"
			 "\\)\\(?:\n[ \t]*\\)*{")
		 (1 'css-selector keep))
		;; In the above rule, we allow the open-brace to be on some subsequent
		;; line.	This will only work if we properly mark the intervening text
		;; as being part of a multiline element (and even then, this only
		;; ensures proper refontification, but not proper discovery).
		("^[ \t]*{" (0 (save-excursion
										 (goto-char (match-beginning 0))
										 (skip-chars-backward " \n\t")
										 (put-text-property (point) (match-end 0)
																				'font-lock-multiline t)
										 ;; No face.
										 nil)))
		;; Properties.	Again, we don't limit ourselves to css-property-ids.
		(,(concat "\\(?:[{;]\\|^\\)[ \t]*\\("
							"\\(?:\\(" css-proprietary-nmstart-re "\\)\\|"
							css-nmstart-re "\\)" css-nmchar-re "*"
							"\\)\\s-*:")
		 (1 (if (match-end 2) 'css-proprietary-property 'css-property)))
		;; Make sure the parens in a url(...) expression receive the
		;; default face. This is done because the parens may sometimes
		;; receive generic string delimiter syntax (see
		;; `css-syntax-propertize-function').
		(,css--uri-re
		 (1 'default t) (2 'default t))))

(defvar xcss-font-lock-keywords (xcss--font-lock-keywords))
(setq xcss-font-lock-keywords (xcss--font-lock-keywords))

(defvar xcss-font-lock-defaults
	'(xcss-font-lock-keywords nil t))

(defcustom xcss-indent-offset 4
	"Basic size of one indentation step."
	:version "22.2"
	:type 'integer)

(defconst xcss-smie-grammar
	(smie-prec2->grammar
	 (smie-precs->prec2 '((assoc ";") (assoc ",") (left ":")))))

(defun xcss-smie--forward-token ()
	(cond
	 ((and (eq (char-before) ?\})
				 nil ;; (scss-smie--not-interpolation-p)
				 ;; FIXME: If the next char is not whitespace, what should we do?
				 (or (memq (char-after) '(?\s ?\t ?\n))
						 (looking-at comment-start-skip)))
		(if (memq (char-after) '(?\s ?\t ?\n))
				(forward-char 1) (forward-comment 1))
		";")
	 ((progn (forward-comment (point-max))
					 (looking-at "[;,:]"))
		(forward-char 1) (match-string 0))
	 (t (smie-default-forward-token))))

(defun xcss-smie--backward-token ()
	(let ((pos (point)))
		(forward-comment (- (point)))
		(cond
		 ;; FIXME: If the next char is not whitespace, what should we do?
		 ((and (eq (char-before) ?\}) nil ;; (scss-smie--not-interpolation-p)
					 (> pos (point))) ";")
		 ((memq (char-before) '(?\; ?\, ?\:))
			(forward-char -1) (string (char-after)))
		 (t (smie-default-backward-token)))))

(defun xcss-smie-rules (kind token)
	(pcase (cons kind token)
		(`(:elem . basic) xcss-indent-offset)
		(`(:elem . arg) 0)
		(`(:list-intro . ,(or `";" `"")) t) ;"" stands for BOB (bug#15467).
		(`(:before . "{")
		 (when (or (smie-rule-hanging-p) (smie-rule-bolp))
			 (smie-backward-sexp ";")
			 (smie-indent-virtual)))
		(`(:before . ,(or "{" "("))
		 (if (smie-rule-hanging-p) (smie-rule-parent 0)))))

(define-derived-mode xcss-mode prog-mode "XCSS"
 "Major mode to edit Cascading Style Sheets and related languages." 
	(setq-local font-lock-defaults css-font-lock-defaults)
	(setq-local comment-start "/*")
	(setq-local comment-start-skip "/\\*+[ \t]*")
	(setq-local comment-end "*/")
	(setq-local comment-end-skip "[ \t]*\\*+/")
 (smie-setup xcss-smie-grammar #'xcss-smie-rules
	:forward-token #'xcss-smie--forward-token
	:backward-token #'xcss-smie--backward-token))

(provide 'xcss-mode)
