;;; autoload/night-tabs.el -*- lexical-binding: t; -*-

(defun night/close-other-tabs ()
  (interactive)
  (tab-close-other)
  (tab-bar-mode -1))
;;;
(setq display-buffer-base-action '(nil))
;; (setq display-buffer-base-action '(display-buffer-in-tab)) ; https://emacs.stackexchange.com/questions/61677/make-display-buffer-open-buffer-in-new-tab
;; seems useless?
;;;
