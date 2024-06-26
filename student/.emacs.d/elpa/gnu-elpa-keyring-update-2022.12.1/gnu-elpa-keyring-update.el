;;; gnu-elpa-keyring-update.el --- Update Emacs's GPG keyring for GNU ELPA  -*- lexical-binding: t; -*-

;; Copyright (C) 2019-2024  Free Software Foundation, Inc.

;; Author: Stefan Monnier <monnier@iro.umontreal.ca>
;; Keywords: maint, tools
;; Package-Type: multi
;; Version: 2022.12.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package updates the GPG keys used by the ELPA package manager
;; (a.k.a `package.el') to verify authenticity of packages downloaded
;; from the GNU ELPA archive.
;;
;; Those keys have a limited validity in time (for example, the first key was
;; valid until Sep 2019 only), so you need to install and keep this package up
;; to date to make sure signature verification does not spuriously fail when
;; installing packages.
;; 
;; If your keys are already too old, causing signature verification errors when
;; installing packages, then in order to install this package you have to
;; temporarily disable signature verification (see variable
;;   `package-check-signature') :-(

;;; News:

;; Since 2022.12:
;; - Fix a bug where the new keys could end up remaining non-installed.
;;
;; Since 2019.3:
;; - New GPG keys

;;; Code:

;;;###autoload
(defvar gnu-elpa-keyring-update--keyring
  ;; FIXME: We avoid using a `.gpg' extension, because it triggers a bug in
  ;; tar-untar-buffer (which is used internally by `package.el' when installing
  ;; the package).
  (expand-file-name "etc/gnu-elpa.gpg-keyring"
                    (file-name-directory
                     (or (if (fboundp 'macroexp-file-name)
                             (macroexp-file-name)
                           load-file-name)
                         ""))))

(defun gnu-elpa-keyring-update--keyring (&optional noerror)
  (if (and (file-name-absolute-p gnu-elpa-keyring-update--keyring)
           (file-readable-p gnu-elpa-keyring-update--keyring))
      gnu-elpa-keyring-update--keyring
    (let ((kr (expand-file-name
               gnu-elpa-keyring-update--keyring
               (file-name-directory
                (or (locate-library "gnu-elpa-keyring-update")
                    (error
                     "Can't find the gnu-elpa-keyring-update package"))))))
      (if (file-readable-p kr)
          (setq gnu-elpa-keyring-update--keyring kr)
        (unless noerror
          (error "Can't find the gpg-keyring file with the new keys"))))))

;;;###autoload
(defun gnu-elpa-keyring-update ()
  "Import new GNU ELPA keys (if any) into package.el's keyring."
  (let ((gnupghome-dir (or (bound-and-true-p package-gnupghome-dir)
                           (expand-file-name "gnupg"
                                             package-user-dir))))
    (package-import-keyring (gnu-elpa-keyring-update--keyring))
    (write-region "" nil (expand-file-name "gnu-elpa.timestamp" gnupghome-dir)
                  nil 'silent)))

;; FIXME: Maybe we should use an advice on `package--check-signature'
;; so as to avoid this startup cost?
;;;###autoload (eval-after-load 'package
;;;###autoload   `(and (bound-and-true-p package-user-dir)
;;;###autoload         (file-directory-p package-user-dir)
;;;###autoload         (let ((ts (expand-file-name
;;;###autoload                    "gnu-elpa.timestamp"
;;;###autoload                    (or (bound-and-true-p package-gnupghome-dir)
;;;###autoload                        (expand-file-name "gnupg"
;;;###autoload                                          package-user-dir))))
;;;###autoload               (kr gnu-elpa-keyring-update--keyring))
;;;###autoload           (and (file-writable-p ts)
;;;###autoload                (file-readable-p kr)
;;;###autoload                (file-newer-than-file-p kr ts)
;;;###autoload                (gnu-elpa-keyring-update)))))

(eval-when-compile
  (condition-case err
      (gnu-elpa-keyring-update)
    (error (message "Skipping update: %s" (error-message-string err)))))

(provide 'gnu-elpa-keyring-update)
;;; gnu-elpa-keyring-update.el ends here
