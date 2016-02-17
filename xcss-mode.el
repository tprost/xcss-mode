(require 'smie)

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
	(setq-local comment-start "/*")
	(setq-local comment-start-skip "/\\*+[ \t]*")
	(setq-local comment-end "*/")
	(setq-local comment-end-skip "[ \t]*\\*+/")
 (smie-setup xcss-smie-grammar #'xcss-smie-rules
	:forward-token #'xcss-smie--forward-token
	:backward-token #'xcss-smie--backward-token))


(provide 'xcss-mode)
