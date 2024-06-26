;;; vulpea-note-test.el --- Test note API -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2021 Boris Buliga
;;
;; Author: Boris Buliga <d12frosted@d12frosted>
;; Maintainer: Boris Buliga <d12frosted@d12frosted>
;;
;; Created: 18 Aug 2021
;;
;; URL: https://github.com/d12frosted/
;;
;; License: GPLv3
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see
;; <http://www.gnu.org/licenses/>.
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Test `vulpea-note' module.
;;
;;; Code:

(require 'vulpea-test-utils)

(describe "vulpea-note-meta-get"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "extracts string value by default"
    (let ((a (vulpea-note-meta-get (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "name" 'string))
          (b (vulpea-note-meta-get (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "name")))
      (expect a :to-equal b)))

  (it "extracts string value"
    (expect (vulpea-note-meta-get (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "name" 'string)
            :to-equal "some name"))

  (it "extracts number value"
    (expect (vulpea-note-meta-get (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "answer" 'number)
            :to-equal 42))

  (it "extracts link value"
    (expect (vulpea-note-meta-get (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "link" 'link)
            :to-equal "444f94d7-61e0-4b7c-bb7e-100814c6b4bb"))

  (it "extracts URL value"
    (expect (vulpea-note-meta-get (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "url" 'link)
            :to-equal "https://en.wikipedia.org/wiki/Frappato"))

  (it "extracts note value"
    (expect (vulpea-note-meta-get (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "link" 'note)
            :to-equal (vulpea-db-get-by-id "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")))

  (it "extracts note value respecting alias"
    (expect (vulpea-note-title
             (vulpea-note-meta-get
              (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd")
              "link with alias" 'note))
            :to-equal "Alias of the note without meta"))

  (it "extracts note value ignoring unknown title"
    (expect (vulpea-note-title
             (vulpea-note-meta-get
              (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd")
              "link with arbitrary desc" 'note))
            :to-equal "Note without META"))

  (it "extracts symbol value"
    (expect (vulpea-note-meta-get (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "symbol" 'symbol)
            :to-equal 'red))

  (it "extracts first element of the list"
    (expect (vulpea-note-meta-get (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "tags" 'string)
            :to-equal "tag 1")))

(describe "vulpea-note-meta-get-list"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "extracts string value by default"
    (let ((a (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "name" 'string))
          (b (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "name")))
      (expect a :to-equal b)))

  (it "extracts string value"
    (expect (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "name" 'string)
            :to-equal '("some name")))

  (it "extracts number value"
    (expect (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "answer" 'number)
            :to-equal '(42)))

  (it "extracts link value"
    (expect (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "link" 'link)
            :to-equal '("444f94d7-61e0-4b7c-bb7e-100814c6b4bb")))

  (it "extracts URL value"
    (expect (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "url" 'link)
            :to-equal '("https://en.wikipedia.org/wiki/Frappato")))

  (it "extracts note value"
    (expect (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "link" 'note)
            :to-equal (list (vulpea-db-get-by-id "444f94d7-61e0-4b7c-bb7e-100814c6b4bb"))))

  (it "extracts symbol value"
    (expect (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "symbol" 'symbol)
            :to-equal '(red)))

  (it "extracts list of strings"
    (expect (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "tags" 'string)
            :to-equal '("tag 1"
                        "tag 2"
                        "tag 3")))

  (it "extracts list of numbers"
    (expect (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "numbers" 'number)
            :to-equal '(12 18 24)))

  (it "extracts list of links"
    (expect (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "references" 'link)
            :to-equal '("444f94d7-61e0-4b7c-bb7e-100814c6b4bb"
                        "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")))

  (it "extracts list of notes and maintains order and used aliases"
    (expect (vulpea-note-meta-get-list (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd") "many links" 'note)
            :to-equal
            (list
             (vulpea-db-get-by-id "1cc15044-aedb-442e-b727-9e3f7346be95")
             (let ((note (vulpea-db-get-by-id "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")))
               (setf (vulpea-note-primary-title note) (vulpea-note-title note))
               (setf (vulpea-note-title note) "Alias of the note without meta")
               note)
             (vulpea-db-get-by-id "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
             (vulpea-db-get-by-id "68f11246-91e1-4d48-b3c6-801a2ef0160b")
             (vulpea-db-get-by-id "6fccd4ff-d1af-43b0-840e-66f636280acb")
             (vulpea-db-get-by-id "72522ed2-9991-482e-a365-01155c172aa5")
             (vulpea-db-get-by-id "7de1afc6-4aef-4ed3-9939-0f2e00971705")
             (vulpea-db-get-by-id "eeec8f05-927f-4c61-b39e-2fb8228cf484")
             (vulpea-db-get-by-id "ff01962f-47c2-4a32-9bf4-990e41090a9b")))))

(provide 'vulpea-note-test)
;;; vulpea-note-test.el ends here
