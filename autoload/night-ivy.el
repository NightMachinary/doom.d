;;; B
;;; ~
;;; /doom.d/autoload/night-ivy.el -*- lexical-binding: t; -*-

(with-eval-after-load 'ivy
  (comment ;; someone else is already doing this!!
   (when (not (boundp 'h-ivy-set-builders))
     (push (cons #'swiper (cdr (assq t ivy-re-builders-alist)))
           ivy-re-builders-alist)
     (push (cons t #'ivy--regex-fuzzy) ivy-re-builders-alist)
     (defvar h-ivy-set-builders t "A flag that shows that ivy-re-builders-alist has been set by us.")))
  (add-to-list 'ivy-re-builders-alist '(swiper-all . ivy--regex-plus))
  )

(after! (ivy  counsel ivy-rich)
  (setq counsel-find-file-ignore-regexp nil) ;; @tradeoff @config

  (defun night/ivy--directory-out ()
    (interactive)
    (let (dir)
      (when (and
             ;; instead of ivy--directory: (not as good) (ivy-state-current ivy-last)
             (setq dir (ivy-expand-file-if-directory (concat ivy--directory "/../"))))
        (ivy--cd dir)
        (ivy--exhibit))))

  (defun night/ivy--directory-enter ()
    (interactive)
    (ivy--directory-enter)
    )

  (define-key counsel-find-file-map (kbd "<left>")
    #'night/ivy--directory-out)
  (define-key counsel-find-file-map (kbd "<right>")
    #'night/ivy--directory-enter)
;;;
  ;; @ideal it's better to add these to the specific maps that need them, but I can't find what other map is used by, e.g., `read-file-name`
  (define-key ivy-minibuffer-map (kbd "<left>")
    #'night/ivy--directory-out)
  (define-key ivy-minibuffer-map (kbd "<right>")
    #'night/ivy--directory-enter)

  (define-key ivy-minibuffer-map (kbd "S-<right>") 'forward-char)
  (define-key ivy-minibuffer-map (kbd "S-<left>") 'backward-char)
;;;
  (defun night/ivy-halfpage-up ()
    (interactive)
    (ivy-previous-line 10)
    (minibuffer-recenter-top-bottom nil))

  (defun night/ivy-halfpage-down ()
    (interactive)
    (ivy-next-line 10)
    (minibuffer-recenter-top-bottom nil))

  (define-key ivy-minibuffer-map (kbd "M-<up>") #'night/ivy-halfpage-up)
  (define-key ivy-minibuffer-map (kbd "M-<down>") #'night/ivy-halfpage-down)
;;;
  (defun night/ivy-mark-toggle ()
    "Mark/unmark the selected candidate."
    (interactive)
    (let
        ((s (ivy-state-current ivy-last)))
      (when s (if (ivy--marked-p)
                  (ivy--unmark s)
                (ivy--mark s)))))

  (defun night/ivy-mark-toggle-up ()
    (interactive)
    (night/ivy-mark-toggle)
    (ivy-previous-line))
  (defun night/ivy-mark-toggle-down ()
    (interactive)
    (night/ivy-mark-toggle)
    (ivy-next-line))
  ;; @rememberMe
  (define-key ivy-minibuffer-map (kbd "TAB") #'night/ivy-mark-toggle)
  (define-key ivy-minibuffer-map (kbd "S-<up>") 'night/ivy-mark-toggle-up)
  (define-key ivy-minibuffer-map (kbd "S-<down>") 'night/ivy-mark-toggle-down)
  ;; (define-key ivy-minibuffer-map (kbd "S-TAB") 'ivy-unmark)
  ;; (define-key ivy-minibuffer-map (kbd "<backtab>") 'ivy-unmark)

  (defun night/ivy-set-to-sel ()
    (interactive)
    (save-excursion (when (not (eq ?/ (char-before)))
                      (zap-up-to-char -1 ?/)
                      ;; needs (require 'misc)
                      ))
    (insert (ivy-state-current ivy-last))
    )
  (define-key ivy-minibuffer-map (kbd "M-<right>") 'night/ivy-set-to-sel)
;;;
  (defun night/ivy-show-doc-buffer ()
    "Temporarily show the documentation buffer for the selection."
    (interactive)
;;;
    ;; does not work
    ;; (info-lookup 'symbol (ivy-state-current ivy-last) 'lisp-mode)
;;;
    ;; @todo doesn't work because the major mode is wrong in the counsel buffer (I think)
    (let ((cb (current-buffer))) ;; @idk how to get the main buffer
      (with-current-buffer cb
        (+lookup/documentation (ivy-state-current ivy-last))))
;;;
    ;; @todo doesn't work because of https://github.com/abo-abo/swiper/issues/2072#issuecomment-841639391
    ;; (let ((other-window-scroll-buffer))
    ;;   (progn
    ;;     (let* ((selected (ivy-state-current ivy-last))
    ;;            (doc-buffer (or (company-call-backend 'doc-buffer selected)
    ;;                            (user-error "No documentation available")))
    ;;            start)
    ;;       (when (consp doc-buffer)
    ;;         (setq start (cdr doc-buffer)
    ;;               doc-buffer (car doc-buffer)))
    ;;       (setq other-window-scroll-buffer (get-buffer doc-buffer))
    ;;       (let ((win (display-buffer doc-buffer t)))
    ;;         (set-window-start win (if start start (point-min)))))))
    )

  (defun night/ivy-sly-doc-popup ()
    (interactive)
    (let ((s (ivy-state-current ivy-last)))
      (message "ivy-doc s: %s" s)
      ;; (popup-tip "This is a tooltip.")
      (popup-tip (sly-eval `(slynk:describe-symbol ,s)))
      ;; (night/popup-sly-describe-symbol
      ;;  (i s))
      ))

  (define-key counsel-company-map (kbd "C-k") #'night/ivy-sly-doc-popup) ;; it might be worth it to activate this for commonlisp. It's not like the keybindings realestate in counsel-company-map is being used at all.

  ;; (define-key counsel-company-map (kbd "C-k") #'night/ivy-show-doc-buffer)

;;;
  (defun night/popup-sly-describe-symbol (symbol-name)
    "Popup function- or symbol-documentation for SYMBOL-NAME."
    ;; @todo0 make this work with counsel-company?
    (interactive (list (sly-read-symbol-name "Documentation for symbol: ")))
    (when (not symbol-name)
      (error "No symbol given"))
    (sly-eval-async `(slynk:describe-symbol ,symbol-name) 'popup-tip))

;;;

  (ignore-errors (memoize-restore #'night/ivy-docstring))
  (defun night/ivy-docstring (candidate)
    ;; (z bello)
    (let* (
           (candidate-sym (intern-soft candidate))
           (doc (cond
                 ((equalp major-mode 'emacs-lisp-mode)
                  (or
                   (ignore-errors
                     (helpful--docstring candidate-sym (fboundp candidate-sym))
                     ;; (helpful-symbol candidate-sym)
                     )
                   "")
                  )
                 ((equalp major-mode 'lisp-mode)
                  ;; (sly-eval `(slynk:describe-function ,candidate))
                  (let* ((doc
                          (sly-eval `(slynk:describe-symbol ,candidate))))
                    (night/brishz "sly-doc-oneline" (i doc)) ;; @futureCron @todo1 @perf works but very slow
                    ;; doc
                    ))
                 ((equalp major-mode 'sh-mode)
                  (night/brishz "wh-docstring" (i candidate))
                  ;; @futureCron is the slowdown worth it?
                  ;; I think it should be possible to speed this up, but I don't really know what's the bottleneck. Perhaps if ivy-rich did this async ...
                  )
                 (t "Not implemented yet")
                 ))
           (doc (s-lines doc))
           (doc (s-join " ; " (or doc '("")))))
      doc))

  (ignore-errors (memoize-restore #'night/ivy-docstring))
  (memoize #'night/ivy-docstring "999 hours")
;;; tests:
  (comment
   (night/ivy-docstring "printskskska8ss0")
   )
;;;

  (setq ivy-rich-display-transformers-list
        (plist-put ivy-rich-display-transformers-list 'counsel-company
                   '(:columns (
                               (ivy-rich-candidate (:width 0.4))
                               (night/ivy-docstring (:face font-lock-doc-face))))))
;;;
  )
