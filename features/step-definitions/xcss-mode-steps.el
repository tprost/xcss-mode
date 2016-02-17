;; This file contains your project specific step definitions. All
;; files in this directory whose names end with "-steps.el" will be
;; loaded automatically by Ecukes.

(Given "^I should be in major mode \"\\(.+\\)\"$"
       (lambda (arg)
         (should
          (equal (symbol-name (with-current-buffer (current-buffer) major-mode)) arg))))

(Then "^The buffer should contain:"
      (lambda (expected)
        (let ((actual (buffer-string))
              (message "Expected the buffer to contain:\n%s\nbut it contained:\n%s"))
          (cl-assert (equal actual expected) t message expected actual))))
