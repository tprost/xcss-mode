(require 'f)

(defvar xcss-mode-support-path
  (f-dirname load-file-name))

(defvar xcss-mode-features-path
  (f-parent xcss-mode-support-path))

(defvar xcss-mode-root-path
  (f-parent xcss-mode-features-path))

(add-to-list 'load-path xcss-mode-root-path)

(require 'xcss-mode)
(require 'espuds)
(require 'ert)

(Setup
 ;; Before anything has run
 )

(Before
 ;; Before each scenario is run
 )

(After
 ;; After each scenario is run
 )

(Teardown
 ;; After when everything has been run
 )
