;;; autoload/org/night-ui.el -*- lexical-binding: nil; -*-

(after! (org)
  (defun night/babel-ansi1 ()
    (interactive)
    (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
      (save-excursion
        (goto-char beg)
        (when (looking-at org-babel-result-regexp)
          (let ((end (org-babel-result-end))
                (ansi-color-context-region nil))
            (ansi-color-apply-on-region beg end))))))

  (defun night/babel-ansi2 ()
    (interactive)
    (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
      (save-excursion
        (goto-char beg)
        (when (looking-at org-babel-result-regexp)
          (let* (
                 (end (org-babel-result-end)))


            (comment (when (search-forward "#+begin_example" nil t)
                       (replace-match "#+begin_results" nil t))
                     (while (search-forward "#+end_example" nil t))
                     (replace-match "#+end_results" nil t)
                     ;; I am now quoting the org stuff in ntt-org itself, as this solution somehow did not quote stuff completely
                     ;; update: it seems the problem is with the ANSI codes, our own quoter also doesn't work in its naive form
                     )

            (let* ((colored (xterm-color-filter (delete-and-extract-region beg end))))
              (goto-char beg)
              (insert colored)))))))

  (defun night/babel-ansi3 ()
    (interactive)
    ;; (save-mark-and-excursion
    ;;   (xterm-color-colorize-buffer))
    (let ((p (point)))
      ;; (message "p1: %s" p)
      (xterm-color-colorize-buffer)
      ;; (message "p2: %s" p)
      (goto-char p))
    )

  (defalias 'night/babel-ansi #'night/babel-ansi2)
  (add-hook 'org-babel-after-execute-hook 'night/babel-ansi)
  ;; (remove-hook 'org-babel-after-execute-hook 'night/babel-ansi)
;;;
  ;; (set-face-attribute 'org-level-1 nil :box  `(:line-width 30 :color ,(face-background 'default)))
  (defun night/modify-org-done-face ()
    (interactive)
    (setq org-fontify-done-headline t)
    (set-face-attribute 'org-done nil :strike-through "black")
    (set-face-attribute 'org-headline-done nil
                        :strike-through "black" ; doesn't work for me
                        :foreground "light gray"))
  (night/modify-org-done-face)


  (progn
    (face-spec-set 'org-level-5 ;; originally copied from org-level-8
                   (org-compatible-face nil ;; not inheriting from outline-9 because that does not exist
                     '((((class color) (min-colors 16) (background light)) (:foreground "brightblue"))
                       (((class color) (min-colors 16) (background dark)) (:foreground "brightblue"))
                       (((class color) (min-colors 8)) (:foreground "green")))))
    (face-spec-set 'org-level-6 ;; originally copied from org-level-8
                   (org-compatible-face nil ;; not inheriting from outline-9 because that does not exist
                     '((((class color) (min-colors 16) (background light)) (:foreground "darkcyan"))
                       (((class color) (min-colors 16) (background dark)) (:foreground "darkcyan"))
                       (((class color) (min-colors 8)) (:foreground "green")))))
    (face-spec-set 'org-level-7 ;; originally copied from org-level-8
                   (org-compatible-face nil ;; not inheriting from outline-9 because that does not exist
                     '((((class color) (min-colors 16) (background light)) (:foreground "deepskyblue"))
                       (((class color) (min-colors 16) (background dark)) (:foreground "deepskyblue"))
                       (((class color) (min-colors 8)) (:foreground "green")))))
    (face-spec-set 'org-level-8 ;; originally copied from org-level-8
                   (org-compatible-face nil ;; not inheriting from outline-9 because that does not exist
                     '((((class color) (min-colors 16) (background light)) (:foreground "Purple"))
                       (((class color) (min-colors 16) (background dark)) (:foreground "Purple"))
                       (((class color) (min-colors 8)) (:foreground "green")))))
    (defface org-level-9 ;; originally copied from org-level-8
      (org-compatible-face nil ;; not inheriting from outline-9 because that does not exist
        '((((class color) (min-colors 16) (background light)) (:foreground "RosyBrown"))
          (((class color) (min-colors 16) (background dark)) (:foreground "LightSalmon"))
          (((class color) (min-colors 8)) (:foreground "green"))))
      "Face used for level 9 headlines."
      :group 'org-faces)
    (setq org-level-faces (append org-level-faces (list 'org-level-9)))
    (setq org-n-level-faces (length org-level-faces))))
