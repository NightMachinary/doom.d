;;; autoload/night-vlf.el -*- lexical-binding: t; -*-

(require 'vlf-setup)
;;;
(defun night/so-long ()
  "Activate font lock only for strings and comments. See also `night/so-long-strong`."
  (interactive)
  (font-lock-mode -1)
  (setq-local font-lock-keywords nil)
  (flycheck-mode -1)
  ;; (linum-mode -1)
  )

(defun night/so-long-strong ()
  "A wrapper for `so-long`"
  (interactive)
  (so-long)
  (hl-line-mode)
)
;;;
