;;; vulpea-db-test.el --- Test `vulpea-db' module -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2020-2021 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;;
;; Created: 29 Dec 2020
;;
;; URL: https://github.com/d12frosted/vulpea
;;
;; License: GPLv3
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Test `vulpea-db' module.
;;
;;; Code:

(require 'vulpea-test-utils)
(require 'vulpea-utils)
(require 'vulpea-db)

(describe "vulpea-db-search-by-title"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "returns empty list when searching for non existent title"
    (expect (vulpea-db-search-by-title "very unique name not existing in present")
            :to-be nil))

  (it "finds a note by original name"
    (expect (vulpea-db-search-by-title "Note with an alias")
            :to-equal
            (list
             (make-vulpea-note
              :path (expand-file-name "note-with-alias.org" org-roam-directory)
              :title "Note with an alias"
              :tags nil
              :aliases '("Alias of the note with alias")
              :level 0
              :id "72522ed2-9991-482e-a365-01155c172aa5"
              :links '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))
              :properties (list
                           (cons "CATEGORY" "note-with-alias")
                           (cons "ROAM_ALIASES" "\"Alias of the note with alias\"")
                           (cons "ID" "72522ed2-9991-482e-a365-01155c172aa5")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "note-with-alias.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/72/522ed2-9991-482e-a365-01155c172aa5" org-roam-directory)))))

  (it "finds a note by alias"
    (expect (vulpea-db-search-by-title "Alias of the note with alias")
            :to-equal
            (list
             (make-vulpea-note
              :path (expand-file-name "note-with-alias.org" org-roam-directory)
              :title "Alias of the note with alias"
              :primary-title "Note with an alias"
              :tags nil
              :aliases '("Alias of the note with alias")
              :level 0
              :id "72522ed2-9991-482e-a365-01155c172aa5"
              :links '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))
              :properties (list
                           (cons "CATEGORY" "note-with-alias")
                           (cons "ROAM_ALIASES" "\"Alias of the note with alias\"")
                           (cons "ID" "72522ed2-9991-482e-a365-01155c172aa5")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "note-with-alias.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/72/522ed2-9991-482e-a365-01155c172aa5" org-roam-directory)))))

  (it "finds multiple notes sharing the same title"
    (expect (vulpea-db-search-by-title "Duplicating Term")
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "same-name-1.org" org-roam-directory)
              :title "Duplicating Term"
              :tags '("tag1" "tag2")
              :level 0
              :id "ff01962f-47c2-4a32-9bf4-990e41090a9b"
              :properties (list
                           (cons "CATEGORY" "same-name-1")
                           (cons "ID" "ff01962f-47c2-4a32-9bf4-990e41090a9b")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag1:tag2:")
                           (cons "FILE" (expand-file-name "same-name-1.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/ff/01962f-47c2-4a32-9bf4-990e41090a9b" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "same-name-2.org" org-roam-directory)
              :title "Duplicating Term"
              :tags '("tag3")
              :level 0
              :id "68f11246-91e1-4d48-b3c6-801a2ef0160b"
              :properties (list
                           (cons "CATEGORY" "same-name-2")
                           (cons "ID" "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag3:")
                           (cons "FILE" (expand-file-name "same-name-2.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/68/f11246-91e1-4d48-b3c6-801a2ef0160b" org-roam-directory)))))

  (it "returns all information about the note"
    (expect (vulpea-db-search-by-title "Reference")
            :to-equal
            (list
             (make-vulpea-note
              :path (expand-file-name "reference.org" org-roam-directory)
              :title "Reference"
              :tags '("tag1" "tag2" "tag3")
              :level 0
              :id "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"
              :properties (list
                           (cons "CATEGORY" "reference")
                           (cons "ID" "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag1:tag2:tag3:")
                           (cons "FILE" (expand-file-name "reference.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/50/93fc4e-8c63-4e60-a1da-83fc7ecd5db7" org-roam-directory)))))

  (it "should use case sensitive search"
    (expect (vulpea-db-search-by-title "reference")
            :to-be nil)))

(describe "vulpea-db-query"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "returns all notes when filter function is not passed"
    (expect (length (vulpea-db-query))
            :to-equal
            (+ (caar (org-roam-db-query
                      [:select (funcall count *)
                       :from nodes]))
               (caar (org-roam-db-query
                      [:select (funcall count *)
                       :from aliases])))))

  (it "applies filter function when passed"
    (expect (vulpea-db-query (lambda (n)
                               (string-equal (vulpea-note-title n)
                                             "Duplicating Term")))
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "same-name-1.org" org-roam-directory)
              :title "Duplicating Term"
              :tags '("tag1" "tag2")
              :level 0
              :id "ff01962f-47c2-4a32-9bf4-990e41090a9b"
              :properties (list
                           (cons "CATEGORY" "same-name-1")
                           (cons "ID" "ff01962f-47c2-4a32-9bf4-990e41090a9b")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag1:tag2:")
                           (cons "FILE" (expand-file-name "same-name-1.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/ff/01962f-47c2-4a32-9bf4-990e41090a9b" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "same-name-2.org" org-roam-directory)
              :title "Duplicating Term"
              :tags '("tag3")
              :level 0
              :id "68f11246-91e1-4d48-b3c6-801a2ef0160b"
              :properties (list
                           (cons "CATEGORY" "same-name-2")
                           (cons "ID" "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag3:")
                           (cons "FILE" (expand-file-name "same-name-2.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/68/f11246-91e1-4d48-b3c6-801a2ef0160b" org-roam-directory)))))

  (it "includes meta and links"
    (expect (vulpea-db-query
             (lambda (n)
               (seq-contains-p
                (cdr (assoc "singleton" (vulpea-note-meta n)))
                "only value")))
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "with-meta.org" org-roam-directory)
              :title "Note with META"
              :tags nil
              :level 0
              :id "05907606-f836-45bf-bd36-a8444308eddd"
              :links '(("https" . "https://en.wikipedia.org/wiki/Frappato")
                       ("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")
                       ("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                       ("id" . "1cc15044-aedb-442e-b727-9e3f7346be95")
                       ("id" . "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                       ("id" . "6fccd4ff-d1af-43b0-840e-66f636280acb")
                       ("id" . "72522ed2-9991-482e-a365-01155c172aa5")
                       ("id" . "7de1afc6-4aef-4ed3-9939-0f2e00971705")
                       ("id" . "eeec8f05-927f-4c61-b39e-2fb8228cf484")
                       ("id" . "ff01962f-47c2-4a32-9bf4-990e41090a9b"))
              :properties (list
                           (cons "CATEGORY" "with-meta")
                           (cons "ID" "05907606-f836-45bf-bd36-a8444308eddd")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "with-meta.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :meta
              '(("name" . ("some name"))
                ("tags" . ("tag 1" "tag 2" "tag 3"))
                ("numbers" . ("12" "18" "24"))
                ("singleton" . ("only value"))
                ("symbol" . ("red"))
                ("url" . ("[[https://en.wikipedia.org/wiki/Frappato][wikipedia.org]]"))
                ("link" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"))
                ("link with alias" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"))
                ("link with arbitrary desc" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][haha]]"))
                ("references" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"))
                ("many links" . ("[[id:1cc15044-aedb-442e-b727-9e3f7346be95][Note with link]]"
                                 "[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"
                                 "[[id:68f11246-91e1-4d48-b3c6-801a2ef0160b][Duplicating Term]]"
                                 "[[id:6fccd4ff-d1af-43b0-840e-66f636280acb][Old reference]]"
                                 "[[id:72522ed2-9991-482e-a365-01155c172aa5][Note with an alias]]"
                                 "[[id:7de1afc6-4aef-4ed3-9939-0f2e00971705][meta in the first header]]"
                                 "[[id:eeec8f05-927f-4c61-b39e-2fb8228cf484][Big note]]"
                                 "[[id:ff01962f-47c2-4a32-9bf4-990e41090a9b][Duplicating Term]]"))
                ("answer" . ("42")))
              :attach-dir (expand-file-name "data/05/907606-f836-45bf-bd36-a8444308eddd" org-roam-directory))))))

(describe "vulpea-db-query-by-tags-some"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "returns empty list when no tags are provided"
    (expect (vulpea-db-query-by-tags-some nil) :to-equal nil))

  (it "returns only notes tagged by any of tags: =1 tag"
    (expect (vulpea-db-query-by-tags-some '("tag3"))
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "reference.org" org-roam-directory)
              :title "Reference"
              :tags '("tag1" "tag2" "tag3")
              :level 0
              :id "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"
              :properties (list
                           (cons "CATEGORY" "reference")
                           (cons "ID" "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag1:tag2:tag3:")
                           (cons "FILE" (expand-file-name "reference.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/50/93fc4e-8c63-4e60-a1da-83fc7ecd5db7" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "same-name-2.org" org-roam-directory)
              :title "Duplicating Term"
              :tags '("tag3")
              :level 0
              :id "68f11246-91e1-4d48-b3c6-801a2ef0160b"
              :properties (list
                           (cons "CATEGORY" "same-name-2")
                           (cons "ID" "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag3:")
                           (cons "FILE" (expand-file-name "same-name-2.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/68/f11246-91e1-4d48-b3c6-801a2ef0160b" org-roam-directory)))))

  (it "returns only notes tagged by any of tags: >1 tag"
    (expect (vulpea-db-query-by-tags-some '("tag3" "tag2"))
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "reference.org" org-roam-directory)
              :title "Reference"
              :tags '("tag1" "tag2" "tag3")
              :level 0
              :id "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"
              :properties (list
                           (cons "CATEGORY" "reference")
                           (cons "ID" "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag1:tag2:tag3:")
                           (cons "FILE" (expand-file-name "reference.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/50/93fc4e-8c63-4e60-a1da-83fc7ecd5db7" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "same-name-1.org" org-roam-directory)
              :title "Duplicating Term"
              :tags '("tag1" "tag2")
              :level 0
              :id "ff01962f-47c2-4a32-9bf4-990e41090a9b"
              :properties (list
                           (cons "CATEGORY" "same-name-1")
                           (cons "ID" "ff01962f-47c2-4a32-9bf4-990e41090a9b")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag1:tag2:")
                           (cons "FILE" (expand-file-name "same-name-1.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/ff/01962f-47c2-4a32-9bf4-990e41090a9b" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "same-name-2.org" org-roam-directory)
              :title "Duplicating Term"
              :tags '("tag3")
              :level 0
              :id "68f11246-91e1-4d48-b3c6-801a2ef0160b"
              :properties (list
                           (cons "CATEGORY" "same-name-2")
                           (cons "ID" "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag3:")
                           (cons "FILE" (expand-file-name "same-name-2.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/68/f11246-91e1-4d48-b3c6-801a2ef0160b" org-roam-directory)))))

  (it "returns the same elements as vulpea-db-query (ignoring aliases)"
    (let ((tags '("tag2" "tag3")))
      (expect
       (vulpea-db-query-by-tags-some tags)
       :to-have-same-items-as
       (seq-remove
        #'vulpea-note-primary-title
        (vulpea-db-query
         (lambda (note)
           (let ((note-tags (vulpea-note-tags note)))
             (seq-some
              (lambda (tag)
                (seq-contains-p note-tags tag))
              tags)))))))))

(describe "vulpea-db-query-by-tags-every"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  ;; this is kind of strange... but maybe that makes sense
  (it "returns empty list when no tags are provided"
    (expect (vulpea-db-query-by-tags-every nil) :to-equal nil))

  (it "returns only notes tagged by each and every of tags: =1 tag"
    (expect (vulpea-db-query-by-tags-every '("tag3"))
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "reference.org" org-roam-directory)
              :title "Reference"
              :tags '("tag1" "tag2" "tag3")
              :level 0
              :id "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"
              :properties (list
                           (cons "CATEGORY" "reference")
                           (cons "ID" "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag1:tag2:tag3:")
                           (cons "FILE" (expand-file-name "reference.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/50/93fc4e-8c63-4e60-a1da-83fc7ecd5db7" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "same-name-2.org" org-roam-directory)
              :title "Duplicating Term"
              :tags '("tag3")
              :level 0
              :id "68f11246-91e1-4d48-b3c6-801a2ef0160b"
              :properties (list
                           (cons "CATEGORY" "same-name-2")
                           (cons "ID" "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag3:")
                           (cons "FILE" (expand-file-name "same-name-2.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/68/f11246-91e1-4d48-b3c6-801a2ef0160b" org-roam-directory)))))

  (it "returns only notes tagged by each and every of tags: >1 tag"
    (expect (vulpea-db-query-by-tags-every '("tag3" "tag2"))
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "reference.org" org-roam-directory)
              :title "Reference"
              :tags '("tag1" "tag2" "tag3")
              :level 0
              :id "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"
              :properties (list
                           (cons "CATEGORY" "reference")
                           (cons "ID" "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                           (cons "BLOCKED" "")
                           (cons "ALLTAGS" ":tag1:tag2:tag3:")
                           (cons "FILE" (expand-file-name "reference.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/50/93fc4e-8c63-4e60-a1da-83fc7ecd5db7" org-roam-directory)))))

  (it "behave the same as vulpea-db-query-by-tags-some with 1 tag"
    (expect (vulpea-db-query-by-tags-every '("tag3"))
            :to-have-same-items-as
            (vulpea-db-query-by-tags-some '("tag3"))))

  (it "returns the same elements as vulpea-db-query (ignoring aliases)"
    (let ((tags '("tag2" "tag3")))
      (expect
       (vulpea-db-query-by-tags-every tags)
       :to-have-same-items-as
       (seq-remove
        #'vulpea-note-primary-title
        (vulpea-db-query
         (lambda (note)
           (let ((note-tags (vulpea-note-tags note)))
             (seq-every-p
              (lambda (tag)
                (seq-contains-p note-tags tag))
              tags)))))))))

(describe "vulpea-db-query-by-tags-none"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "acts as vulpea-db-query when no tags are provided"
    (expect (seq-length (vulpea-db-query-by-tags-none nil))
            :to-equal
            (seq-length (vulpea-db-query))))

  (it "returns the same elements as vulpea-db-query"
    (expect
     (vulpea-db-query-by-tags-none '("tag2" "tag3"))
     :to-have-same-items-as
     (vulpea-db-query
      (lambda (note)
        (not (vulpea-note-tagged-any-p note "tag2" "tag3")))))))

(describe "vulpea-db-query-by-links-some"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "returns empty list when no links are provided"
    (expect (vulpea-db-query-by-links-some nil) :to-equal nil))

  (it "returns only notes linking to any of destinations: =1 link"
    (expect (vulpea-db-query-by-links-some
             '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")))
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "with-meta.org" org-roam-directory)
              :title "Note with META"
              :tags nil
              :level 0
              :id "05907606-f836-45bf-bd36-a8444308eddd"
              :links '(("https" . "https://en.wikipedia.org/wiki/Frappato")
                       ("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")
                       ("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                       ("id" . "1cc15044-aedb-442e-b727-9e3f7346be95")
                       ("id" . "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                       ("id" . "6fccd4ff-d1af-43b0-840e-66f636280acb")
                       ("id" . "72522ed2-9991-482e-a365-01155c172aa5")
                       ("id" . "7de1afc6-4aef-4ed3-9939-0f2e00971705")
                       ("id" . "eeec8f05-927f-4c61-b39e-2fb8228cf484")
                       ("id" . "ff01962f-47c2-4a32-9bf4-990e41090a9b"))
              :properties (list
                           (cons "CATEGORY" "with-meta")
                           (cons "ID" "05907606-f836-45bf-bd36-a8444308eddd")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "with-meta.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :meta
              '(("name" . ("some name"))
                ("tags" . ("tag 1" "tag 2" "tag 3"))
                ("numbers" . ("12" "18" "24"))
                ("singleton" . ("only value"))
                ("symbol" . ("red"))
                ("url" . ("[[https://en.wikipedia.org/wiki/Frappato][wikipedia.org]]"))
                ("link" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"))
                ("link with alias" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"))
                ("link with arbitrary desc" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][haha]]"))
                ("references" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"))
                ("many links" . ("[[id:1cc15044-aedb-442e-b727-9e3f7346be95][Note with link]]"
                                 "[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"
                                 "[[id:68f11246-91e1-4d48-b3c6-801a2ef0160b][Duplicating Term]]"
                                 "[[id:6fccd4ff-d1af-43b0-840e-66f636280acb][Old reference]]"
                                 "[[id:72522ed2-9991-482e-a365-01155c172aa5][Note with an alias]]"
                                 "[[id:7de1afc6-4aef-4ed3-9939-0f2e00971705][meta in the first header]]"
                                 "[[id:eeec8f05-927f-4c61-b39e-2fb8228cf484][Big note]]"
                                 "[[id:ff01962f-47c2-4a32-9bf4-990e41090a9b][Duplicating Term]]"))
                ("answer" . ("42")))
              :attach-dir (expand-file-name "data/05/907606-f836-45bf-bd36-a8444308eddd" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "note-with-alias.org" org-roam-directory)
              :title "Note with an alias"
              :tags nil
              :aliases '("Alias of the note with alias")
              :level 0
              :id "72522ed2-9991-482e-a365-01155c172aa5"
              :links '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))
              :properties (list
                           (cons "CATEGORY" "note-with-alias")
                           (cons "ROAM_ALIASES" "\"Alias of the note with alias\"")
                           (cons "ID" "72522ed2-9991-482e-a365-01155c172aa5")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "note-with-alias.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/72/522ed2-9991-482e-a365-01155c172aa5" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "note-with-alias.org" org-roam-directory)
              :title "Alias of the note with alias"
              :primary-title "Note with an alias"
              :tags nil
              :aliases '("Alias of the note with alias")
              :level 0
              :id "72522ed2-9991-482e-a365-01155c172aa5"
              :links '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))
              :properties (list
                           (cons "CATEGORY" "note-with-alias")
                           (cons "ROAM_ALIASES" "\"Alias of the note with alias\"")
                           (cons "ID" "72522ed2-9991-482e-a365-01155c172aa5")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "note-with-alias.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/72/522ed2-9991-482e-a365-01155c172aa5" org-roam-directory)))))

  (it "returns only notes linking to any of destinations: >1 link"
    (expect (vulpea-db-query-by-links-some
             '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
               ("id" . "6fccd4ff-d1af-43b0-840e-66f636280acb")))
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "with-meta.org" org-roam-directory)
              :title "Note with META"
              :tags nil
              :level 0
              :id "05907606-f836-45bf-bd36-a8444308eddd"
              :links '(("https" . "https://en.wikipedia.org/wiki/Frappato")
                       ("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")
                       ("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                       ("id" . "1cc15044-aedb-442e-b727-9e3f7346be95")
                       ("id" . "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                       ("id" . "6fccd4ff-d1af-43b0-840e-66f636280acb")
                       ("id" . "72522ed2-9991-482e-a365-01155c172aa5")
                       ("id" . "7de1afc6-4aef-4ed3-9939-0f2e00971705")
                       ("id" . "eeec8f05-927f-4c61-b39e-2fb8228cf484")
                       ("id" . "ff01962f-47c2-4a32-9bf4-990e41090a9b"))
              :properties (list
                           (cons "CATEGORY" "with-meta")
                           (cons "ID" "05907606-f836-45bf-bd36-a8444308eddd")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "with-meta.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :meta
              '(("name" . ("some name"))
                ("tags" . ("tag 1" "tag 2" "tag 3"))
                ("numbers" . ("12" "18" "24"))
                ("singleton" . ("only value"))
                ("symbol" . ("red"))
                ("url" . ("[[https://en.wikipedia.org/wiki/Frappato][wikipedia.org]]"))
                ("link" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"))
                ("link with alias" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"))
                ("link with arbitrary desc" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][haha]]"))
                ("references" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"))
                ("many links" . ("[[id:1cc15044-aedb-442e-b727-9e3f7346be95][Note with link]]"
                                 "[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"
                                 "[[id:68f11246-91e1-4d48-b3c6-801a2ef0160b][Duplicating Term]]"
                                 "[[id:6fccd4ff-d1af-43b0-840e-66f636280acb][Old reference]]"
                                 "[[id:72522ed2-9991-482e-a365-01155c172aa5][Note with an alias]]"
                                 "[[id:7de1afc6-4aef-4ed3-9939-0f2e00971705][meta in the first header]]"
                                 "[[id:eeec8f05-927f-4c61-b39e-2fb8228cf484][Big note]]"
                                 "[[id:ff01962f-47c2-4a32-9bf4-990e41090a9b][Duplicating Term]]"))
                ("answer" . ("42")))
              :attach-dir (expand-file-name "data/05/907606-f836-45bf-bd36-a8444308eddd" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "note-with-alias.org" org-roam-directory)
              :title "Note with an alias"
              :tags nil
              :aliases '("Alias of the note with alias")
              :level 0
              :id "72522ed2-9991-482e-a365-01155c172aa5"
              :links '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))
              :properties (list
                           (cons "CATEGORY" "note-with-alias")
                           (cons "ROAM_ALIASES" "\"Alias of the note with alias\"")
                           (cons "ID" "72522ed2-9991-482e-a365-01155c172aa5")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "note-with-alias.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/72/522ed2-9991-482e-a365-01155c172aa5" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "note-with-alias.org" org-roam-directory)
              :title "Alias of the note with alias"
              :primary-title "Note with an alias"
              :tags nil
              :aliases '("Alias of the note with alias")
              :level 0
              :id "72522ed2-9991-482e-a365-01155c172aa5"
              :links '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))
              :properties (list
                           (cons "CATEGORY" "note-with-alias")
                           (cons "ROAM_ALIASES" "\"Alias of the note with alias\"")
                           (cons "ID" "72522ed2-9991-482e-a365-01155c172aa5")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "note-with-alias.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/72/522ed2-9991-482e-a365-01155c172aa5" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "note-with-link.org" org-roam-directory)
              :title "Note with link"
              :tags nil
              :level 0
              :id "1cc15044-aedb-442e-b727-9e3f7346be95"
              :links '(("id" . "6fccd4ff-d1af-43b0-840e-66f636280acb"))
              :properties (list
                           (cons "CATEGORY" "note-with-link")
                           (cons "ID" "1cc15044-aedb-442e-b727-9e3f7346be95")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "note-with-link.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/1c/c15044-aedb-442e-b727-9e3f7346be95" org-roam-directory)))))

  (it "returns the same elements as vulpea-db-query"
    (let ((links '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                   ("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb"))))
      (expect
       (vulpea-db-query-by-links-some links)
       :to-have-same-items-as
       (vulpea-db-query
        (lambda (note)
          (let ((note-links (vulpea-note-links note)))
            (seq-some
             (lambda (link)
               (seq-contains-p note-links link))
             links))))))))

(describe "vulpea-db-query-by-links-every"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  ;; this is kind of strange... but maybe that makes sense
  (it "returns empty list when no links are provided"
    (expect (vulpea-db-query-by-links-every nil) :to-equal nil))

  (it "returns only notes linking to every destination: =1 link"
    (expect (vulpea-db-query-by-links-every
             '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")))
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "with-meta.org" org-roam-directory)
              :title "Note with META"
              :tags nil
              :level 0
              :id "05907606-f836-45bf-bd36-a8444308eddd"
              :links '(("https" . "https://en.wikipedia.org/wiki/Frappato")
                       ("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")
                       ("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                       ("id" . "1cc15044-aedb-442e-b727-9e3f7346be95")
                       ("id" . "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                       ("id" . "6fccd4ff-d1af-43b0-840e-66f636280acb")
                       ("id" . "72522ed2-9991-482e-a365-01155c172aa5")
                       ("id" . "7de1afc6-4aef-4ed3-9939-0f2e00971705")
                       ("id" . "eeec8f05-927f-4c61-b39e-2fb8228cf484")
                       ("id" . "ff01962f-47c2-4a32-9bf4-990e41090a9b"))
              :properties (list
                           (cons "CATEGORY" "with-meta")
                           (cons "ID" "05907606-f836-45bf-bd36-a8444308eddd")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "with-meta.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :meta
              '(("name" . ("some name"))
                ("tags" . ("tag 1" "tag 2" "tag 3"))
                ("numbers" . ("12" "18" "24"))
                ("singleton" . ("only value"))
                ("symbol" . ("red"))
                ("url" . ("[[https://en.wikipedia.org/wiki/Frappato][wikipedia.org]]"))
                ("link" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"))
                ("link with alias" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"))
                ("link with arbitrary desc" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][haha]]"))
                ("references" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"))
                ("many links" . ("[[id:1cc15044-aedb-442e-b727-9e3f7346be95][Note with link]]"
                                 "[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"
                                 "[[id:68f11246-91e1-4d48-b3c6-801a2ef0160b][Duplicating Term]]"
                                 "[[id:6fccd4ff-d1af-43b0-840e-66f636280acb][Old reference]]"
                                 "[[id:72522ed2-9991-482e-a365-01155c172aa5][Note with an alias]]"
                                 "[[id:7de1afc6-4aef-4ed3-9939-0f2e00971705][meta in the first header]]"
                                 "[[id:eeec8f05-927f-4c61-b39e-2fb8228cf484][Big note]]"
                                 "[[id:ff01962f-47c2-4a32-9bf4-990e41090a9b][Duplicating Term]]"))
                ("answer" . ("42")))
              :attach-dir (expand-file-name "data/05/907606-f836-45bf-bd36-a8444308eddd" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "note-with-alias.org" org-roam-directory)
              :title "Note with an alias"
              :tags nil
              :aliases '("Alias of the note with alias")
              :level 0
              :id "72522ed2-9991-482e-a365-01155c172aa5"
              :links '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))
              :properties (list
                           (cons "CATEGORY" "note-with-alias")
                           (cons "ROAM_ALIASES" "\"Alias of the note with alias\"")
                           (cons "ID" "72522ed2-9991-482e-a365-01155c172aa5")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "note-with-alias.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/72/522ed2-9991-482e-a365-01155c172aa5" org-roam-directory))
             (make-vulpea-note
              :path (expand-file-name "note-with-alias.org" org-roam-directory)
              :title "Alias of the note with alias"
              :primary-title "Note with an alias"
              :tags nil
              :aliases '("Alias of the note with alias")
              :level 0
              :id "72522ed2-9991-482e-a365-01155c172aa5"
              :links '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))
              :properties (list
                           (cons "CATEGORY" "note-with-alias")
                           (cons "ROAM_ALIASES" "\"Alias of the note with alias\"")
                           (cons "ID" "72522ed2-9991-482e-a365-01155c172aa5")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "note-with-alias.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :attach-dir (expand-file-name "data/72/522ed2-9991-482e-a365-01155c172aa5" org-roam-directory)))))

  (it "returns only notes linking each and every of destinations: >1 tag"
    (expect (vulpea-db-query-by-links-every
             '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
               ("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")))
            :to-have-same-items-as
            (list
             (make-vulpea-note
              :path (expand-file-name "with-meta.org" org-roam-directory)
              :title "Note with META"
              :tags nil
              :level 0
              :id "05907606-f836-45bf-bd36-a8444308eddd"
              :links '(("https" . "https://en.wikipedia.org/wiki/Frappato")
                       ("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")
                       ("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                       ("id" . "1cc15044-aedb-442e-b727-9e3f7346be95")
                       ("id" . "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                       ("id" . "6fccd4ff-d1af-43b0-840e-66f636280acb")
                       ("id" . "72522ed2-9991-482e-a365-01155c172aa5")
                       ("id" . "7de1afc6-4aef-4ed3-9939-0f2e00971705")
                       ("id" . "eeec8f05-927f-4c61-b39e-2fb8228cf484")
                       ("id" . "ff01962f-47c2-4a32-9bf4-990e41090a9b"))
              :properties (list
                           (cons "CATEGORY" "with-meta")
                           (cons "ID" "05907606-f836-45bf-bd36-a8444308eddd")
                           (cons "BLOCKED" "")
                           (cons "FILE" (expand-file-name "with-meta.org" org-roam-directory))
                           (cons "PRIORITY" "B"))
              :meta
              '(("name" . ("some name"))
                ("tags" . ("tag 1" "tag 2" "tag 3"))
                ("numbers" . ("12" "18" "24"))
                ("singleton" . ("only value"))
                ("symbol" . ("red"))
                ("url" . ("[[https://en.wikipedia.org/wiki/Frappato][wikipedia.org]]"))
                ("link" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"))
                ("link with alias" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"))
                ("link with arbitrary desc" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][haha]]"))
                ("references" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"))
                ("many links" . ("[[id:1cc15044-aedb-442e-b727-9e3f7346be95][Note with link]]"
                                 "[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"
                                 "[[id:68f11246-91e1-4d48-b3c6-801a2ef0160b][Duplicating Term]]"
                                 "[[id:6fccd4ff-d1af-43b0-840e-66f636280acb][Old reference]]"
                                 "[[id:72522ed2-9991-482e-a365-01155c172aa5][Note with an alias]]"
                                 "[[id:7de1afc6-4aef-4ed3-9939-0f2e00971705][meta in the first header]]"
                                 "[[id:eeec8f05-927f-4c61-b39e-2fb8228cf484][Big note]]"
                                 "[[id:ff01962f-47c2-4a32-9bf4-990e41090a9b][Duplicating Term]]"))
                ("answer" . ("42")))
              :attach-dir (expand-file-name "data/05/907606-f836-45bf-bd36-a8444308eddd" org-roam-directory)))))

  (it "behave the same as vulpea-db-query-by-links-some with 1 destination"
    (expect (vulpea-db-query-by-links-every '(("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")))
            :to-have-same-items-as
            (vulpea-db-query-by-links-some '(("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")))))

  (it "returns the same elements as vulpea-db-query"
    (let ((links '(("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb"))))
      (expect
       (vulpea-db-query-by-links-every links)
       :to-have-same-items-as
       (vulpea-db-query
        (lambda (note)
          (let ((note-links (vulpea-note-links note)))
            (seq-every-p
             (lambda (tag)
               (seq-contains-p note-links tag))
             links))))))))

(describe "vulpea-db-query-by-level"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "returns the same elements as vulpea-db-query"
    (expect
     (vulpea-db-query-by-level 0)
     :to-have-same-items-as
     (vulpea-db-query
      (lambda (note)
        (= 0 (vulpea-note-level note)))))))

(describe "vulpea-db-get-by-id"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "returns nil when passed unknown id"
    (expect (vulpea-db-get-by-id "00000000-0000-0000-0000-000000000000")
            :to-be nil))

  (it "returns note by file id"
    (expect (vulpea-db-get-by-id "72522ed2-9991-482e-a365-01155c172aa5")
            :to-equal
            (make-vulpea-note
             :path (expand-file-name "note-with-alias.org" org-roam-directory)
             :title "Note with an alias"
             :tags nil
             :aliases '("Alias of the note with alias")
             :level 0
             :id "72522ed2-9991-482e-a365-01155c172aa5"
             :links '(("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))
             :properties (list
                          (cons "CATEGORY" "note-with-alias")
                          (cons "ROAM_ALIASES" "\"Alias of the note with alias\"")
                          (cons "ID" "72522ed2-9991-482e-a365-01155c172aa5")
                          (cons "BLOCKED" "")
                          (cons "FILE" (expand-file-name "note-with-alias.org" org-roam-directory))
                          (cons "PRIORITY" "B"))
             :attach-dir (expand-file-name "data/72/522ed2-9991-482e-a365-01155c172aa5" org-roam-directory))))

  (it "returns note by sub-heading id"
    (expect (vulpea-db-get-by-id "b77a4837-71d6-495e-98f1-b576464aacc1")
            :to-equal
            (make-vulpea-note
             :path (expand-file-name "big-note.org" org-roam-directory)
             :title "Big note sub-heading"
             :tags nil
             :level 1
             :id "b77a4837-71d6-495e-98f1-b576464aacc1"
             :properties (list
                          (cons "CATEGORY" "big-note")
                          (cons "ID" "b77a4837-71d6-495e-98f1-b576464aacc1")
                          (cons "BLOCKED" "")
                          (cons "FILE" (expand-file-name "big-note.org" org-roam-directory))
                          (cons "PRIORITY" "B")
                          (cons "ITEM" "Big note sub-heading"))
             :attach-dir (expand-file-name "data/b7/7a4837-71d6-495e-98f1-b576464aacc1" org-roam-directory))))

  (it "returns note by sub-sub-heading id"
    (expect (vulpea-db-get-by-id "cfc39858-351d-4f1e-8f98-10d16d71f49e")
            :to-equal
            (make-vulpea-note
             :path (expand-file-name "big-note.org" org-roam-directory)
             :title "Big note sub-sub-heading"
             :tags nil
             :level 2
             :id "cfc39858-351d-4f1e-8f98-10d16d71f49e"
             :properties (list
                          (cons "CATEGORY" "big-note")
                          (cons "ID" "cfc39858-351d-4f1e-8f98-10d16d71f49e")
                          (cons "BLOCKED" "")
                          (cons "FILE" (expand-file-name "big-note.org" org-roam-directory))
                          (cons "PRIORITY" "B")
                          (cons "ITEM" "Big note sub-sub-heading"))
             :attach-dir (expand-file-name "data/cf/c39858-351d-4f1e-8f98-10d16d71f49e" org-roam-directory)
             :outline-path '("Big note sub-heading"))))

  (it "includes meta and links in response"
    (expect (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd")
            :to-equal
            (make-vulpea-note
             :path (expand-file-name "with-meta.org" org-roam-directory)
             :title "Note with META"
             :tags nil
             :level 0
             :id "05907606-f836-45bf-bd36-a8444308eddd"
             :links '(("https" . "https://en.wikipedia.org/wiki/Frappato")
                      ("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")
                      ("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                      ("id" . "1cc15044-aedb-442e-b727-9e3f7346be95")
                      ("id" . "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                      ("id" . "6fccd4ff-d1af-43b0-840e-66f636280acb")
                      ("id" . "72522ed2-9991-482e-a365-01155c172aa5")
                      ("id" . "7de1afc6-4aef-4ed3-9939-0f2e00971705")
                      ("id" . "eeec8f05-927f-4c61-b39e-2fb8228cf484")
                      ("id" . "ff01962f-47c2-4a32-9bf4-990e41090a9b"))
             :properties (list
                          (cons "CATEGORY" "with-meta")
                          (cons "ID" "05907606-f836-45bf-bd36-a8444308eddd")
                          (cons "BLOCKED" "")
                          (cons "FILE" (expand-file-name "with-meta.org" org-roam-directory))
                          (cons "PRIORITY" "B"))
             :meta '(("name" . ("some name"))
                     ("tags" . ("tag 1" "tag 2" "tag 3"))
                     ("numbers" . ("12" "18" "24"))
                     ("singleton" . ("only value"))
                     ("symbol" . ("red"))
                     ("url" . ("[[https://en.wikipedia.org/wiki/Frappato][wikipedia.org]]"))
                     ("link" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"))
                     ("link with alias" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"))
                     ("link with arbitrary desc" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][haha]]"))
                     ("references" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"
                                      "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"))
                     ("many links" . ("[[id:1cc15044-aedb-442e-b727-9e3f7346be95][Note with link]]"
                                 "[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"
                                 "[[id:68f11246-91e1-4d48-b3c6-801a2ef0160b][Duplicating Term]]"
                                 "[[id:6fccd4ff-d1af-43b0-840e-66f636280acb][Old reference]]"
                                 "[[id:72522ed2-9991-482e-a365-01155c172aa5][Note with an alias]]"
                                 "[[id:7de1afc6-4aef-4ed3-9939-0f2e00971705][meta in the first header]]"
                                 "[[id:eeec8f05-927f-4c61-b39e-2fb8228cf484][Big note]]"
                                 "[[id:ff01962f-47c2-4a32-9bf4-990e41090a9b][Duplicating Term]]"))
                     ("answer" . ("42")))
             :attach-dir (expand-file-name "data/05/907606-f836-45bf-bd36-a8444308eddd" org-roam-directory)))))

(describe "vulpea-db-get-file-by-id"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "returns nil when passed unknown id"
    (expect (vulpea-db-get-file-by-id "00000000-0000-0000-0000-000000000000")
            :to-be nil))

  (it "returns file of a note with id"
    (expect (vulpea-db-get-file-by-id "72522ed2-9991-482e-a365-01155c172aa5")
            :to-equal
            (expand-file-name "note-with-alias.org"
                              org-roam-directory)))

  (it "returns file of sub-heading with id"
    (expect (vulpea-db-get-file-by-id "b77a4837-71d6-495e-98f1-b576464aacc1")
            :to-equal
            (expand-file-name "big-note.org"
                              org-roam-directory)))

  (it "returns file of sub-sub-heading with id"
    (expect (vulpea-db-get-file-by-id "cfc39858-351d-4f1e-8f98-10d16d71f49e")
            :to-equal
            (expand-file-name "big-note.org"
                              org-roam-directory))))

(describe "vulpea-db-get-id-by-file"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "returns nil when passed unknown file"
    (expect (vulpea-db-get-id-by-file
             (expand-file-name "0000.org"
                               org-roam-directory))
            :to-be nil))

  (it "returns id of an absolute file path"
    (expect (vulpea-db-get-id-by-file
             (expand-file-name "reference.org"
                               org-roam-directory))
            :to-equal
            "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))

  (it "returns id of a relative file path"
    (expect (vulpea-db-get-id-by-file "reference.org")
            :to-equal
            "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7"))

  (it "returns top-level id of a file with subheading"
    (expect (vulpea-db-get-id-by-file
             (expand-file-name "big-note.org"
                               org-roam-directory))
            :to-equal
            "eeec8f05-927f-4c61-b39e-2fb8228cf484")))

(describe "clear file"
  (before-all
    (vulpea-test--init))

  (after-all
    (vulpea-test--teardown))

  (it "removing a file removes it from all tables"
    (let* ((id "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
           (note (vulpea-db-get-by-id id))
           (file (vulpea-note-path note)))
      (org-roam-db-clear-file file)
      (expect (org-roam-db-query [:select *
                                  :from files
                                  :where (= file $s1)]
                                 file)
              :to-be nil)
      (expect (org-roam-db-query [:select *
                                  :from nodes
                                  :where (= id $s1)]
                                 id)
              :to-be nil)
      (expect (org-roam-db-query [:select *
                                  :from notes
                                  :where (= id $s1)]
                                 id)
              :to-be nil)
      (expect (org-roam-db-query [:select *
                                  :from meta
                                  :where (= node-id $s1)]
                                 id)
              :to-be nil))))

(describe "vulpea-db-setup"
  (before-each
    (vulpea-test--init 'no-setup))

  (after-each
    (vulpea-test--teardown))

  (it "applies cleanly on existing database"
    (org-roam-db-sync 'force)

    ;; initially there are no vulpea specific tables
    (-each vulpea-db--tables
      (-lambda ((table _ _ indices))
        (expect (org-roam-db-query
                 [:select name
                  :from sqlite_master
                  :where (and (= type 'table)
                              (= name $r1))]
                 (emacsql-escape-identifier table))
                :to-equal nil)
        (-each indices
          (-lambda ((index-name))
            (expect (org-roam-db-query
                     [:select name
                      :from sqlite_master
                      :where (and (= type 'index)
                                  (= name $r1))]
                     (emacsql-escape-identifier index-name))
                    :to-equal nil)))))

    ;; then we setup vulpea-db
    (vulpea-db-autosync-enable)

    ;; and vulpea specific tables should exist
    (-each vulpea-db--tables
      (-lambda ((table version _ indices))
        (expect (org-roam-db-query
                 [:select name
                  :from sqlite_master
                  :where (and (= type 'table)
                              (= name $r1))]
                 (emacsql-escape-identifier table))
                :to-equal (list (list (intern (emacsql-escape-identifier table)))))
        (-each indices
          (-lambda ((index-name))
            (expect (org-roam-db-query
                     [:select name
                      :from sqlite_master
                      :where (and (= type 'index)
                                  (= name $r1))]
                     (emacsql-escape-identifier index-name))
                    :to-equal (list (list (intern (emacsql-escape-identifier index-name)))))))
        (expect (caar (org-roam-db-query [:select version :from versions :where (= id $s1)] table))
                :to-equal version)))

    ;; and data is synced
    (expect (vulpea-db-get-by-id "05907606-f836-45bf-bd36-a8444308eddd")
            :to-equal
            (make-vulpea-note
             :path (expand-file-name "with-meta.org" org-roam-directory)
             :title "Note with META"
             :tags nil
             :level 0
             :id "05907606-f836-45bf-bd36-a8444308eddd"
             :links '(("https" . "https://en.wikipedia.org/wiki/Frappato")
                      ("id" . "444f94d7-61e0-4b7c-bb7e-100814c6b4bb")
                      ("id" . "5093fc4e-8c63-4e60-a1da-83fc7ecd5db7")
                      ("id" . "1cc15044-aedb-442e-b727-9e3f7346be95")
                      ("id" . "68f11246-91e1-4d48-b3c6-801a2ef0160b")
                      ("id" . "6fccd4ff-d1af-43b0-840e-66f636280acb")
                      ("id" . "72522ed2-9991-482e-a365-01155c172aa5")
                      ("id" . "7de1afc6-4aef-4ed3-9939-0f2e00971705")
                      ("id" . "eeec8f05-927f-4c61-b39e-2fb8228cf484")
                      ("id" . "ff01962f-47c2-4a32-9bf4-990e41090a9b"))
             :properties (list
                          (cons "CATEGORY" "with-meta")
                          (cons "ID" "05907606-f836-45bf-bd36-a8444308eddd")
                          (cons "BLOCKED" "")
                          (cons "FILE" (expand-file-name "with-meta.org" org-roam-directory))
                          (cons "PRIORITY" "B"))
             :meta '(("name" . ("some name"))
                     ("tags" . ("tag 1" "tag 2" "tag 3"))
                     ("numbers" . ("12" "18" "24"))
                     ("singleton" . ("only value"))
                     ("symbol" . ("red"))
                     ("url" . ("[[https://en.wikipedia.org/wiki/Frappato][wikipedia.org]]"))
                     ("link" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"))
                     ("link with alias" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"))
                     ("link with arbitrary desc" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][haha]]"))
                     ("references" . ("[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Note without META]]"
                                      "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"))
                     ("many links" . ("[[id:1cc15044-aedb-442e-b727-9e3f7346be95][Note with link]]"
                                 "[[id:444f94d7-61e0-4b7c-bb7e-100814c6b4bb][Alias of the note without meta]]"
                                 "[[id:5093fc4e-8c63-4e60-a1da-83fc7ecd5db7][Reference]]"
                                 "[[id:68f11246-91e1-4d48-b3c6-801a2ef0160b][Duplicating Term]]"
                                 "[[id:6fccd4ff-d1af-43b0-840e-66f636280acb][Old reference]]"
                                 "[[id:72522ed2-9991-482e-a365-01155c172aa5][Note with an alias]]"
                                 "[[id:7de1afc6-4aef-4ed3-9939-0f2e00971705][meta in the first header]]"
                                 "[[id:eeec8f05-927f-4c61-b39e-2fb8228cf484][Big note]]"
                                 "[[id:ff01962f-47c2-4a32-9bf4-990e41090a9b][Duplicating Term]]"))
                     ("answer" . ("42")))
             :attach-dir (expand-file-name "data/05/907606-f836-45bf-bd36-a8444308eddd" org-roam-directory))))

  (it "survives (org-roam-db-sync 'force)"
    (message "enable autosync")
    (vulpea-db-autosync-enable)
    (-each vulpea-db--tables
      (-lambda ((table version))
        (expect (caar (org-roam-db-query [:select version :from versions :where (= id $s1)] table))
                :to-equal version)))

    (message "force sync")
    (org-roam-db-sync 'force)
    (-each vulpea-db--tables
      (-lambda ((table version))
        (expect (caar (org-roam-db-query [:select version :from versions :where (= id $s1)] table))
                :to-equal version)))))

(describe "vulpea-db-insert-note-functions"
  (before-each
    (vulpea-test--init)
    (spy-on 'insert-handle-fn)
    (add-hook 'vulpea-db-insert-note-functions #'insert-handle-fn))

  (after-each
    (vulpea-test--teardown)
    (remove-hook 'vulpea-db-insert-note-functions #'insert-handle-fn))

  (it "calls insert hook on file level note"
    (let* ((id "1cc15044-aedb-442e-b727-9e3f7346be95")
           (note (vulpea-db-get-by-id id))
           (file (vulpea-note-path note)))
      ;; force sync of a single file by clearing it and syncing manually
      (org-roam-db-clear-file file)
      (org-roam-db-sync)
      (expect 'insert-handle-fn :to-have-been-called-times 1)
      (expect 'insert-handle-fn :to-have-been-called-with
              (make-vulpea-note
               :path (expand-file-name "note-with-link.org" org-roam-directory)
               :title "Note with link"
               :tags nil
               :level 0
               :id "1cc15044-aedb-442e-b727-9e3f7346be95"
               :links nil               ; not supported in this hook
               :properties (list
                            (cons "CATEGORY" "note-with-link")
                            (cons "ID" "1cc15044-aedb-442e-b727-9e3f7346be95")
                            (cons "BLOCKED" "")
                            (cons "FILE" (expand-file-name "note-with-link.org" org-roam-directory))
                            (cons "PRIORITY" "B"))
               :attach-dir (expand-file-name "data/1c/c15044-aedb-442e-b727-9e3f7346be95" org-roam-directory)))))

  (it "calls insert hook on outline level note"
    (let* ((id "1cc15044-aedb-442e-b727-9e3f7346be95"))
      ;; force sync by adding a new header to the end of existing note
      (vulpea-utils-with-note (vulpea-db-get-by-id id)
        (goto-char (point-max))
        (insert
         "\n"
         "* I was added\n")
        (setf id (org-id-get-create))
        (save-buffer))
      (expect 'insert-handle-fn :to-have-been-called-times 2)
      (expect 'insert-handle-fn :to-have-been-called-with
              (make-vulpea-note
               :path (expand-file-name "note-with-link.org" org-roam-directory)
               :title "I was added"
               :tags nil
               :level 1
               :id id
               :links nil               ; not supported in this hook
               :properties (list
                            (cons "CATEGORY" "note-with-link")
                            (cons "ID" id)
                            (cons "BLOCKED" "")
                            (cons "FILE" (expand-file-name "note-with-link.org" org-roam-directory))
                            (cons "PRIORITY" "B")
                            (cons "ITEM" "I was added"))
               :attach-dir (expand-file-name
                            (concat "data/"
                                    (substring-no-properties id 0 2)
                                    "/"
                                    (substring-no-properties id 2))
                            org-roam-directory))))))

(provide 'vulpea-db-test)
;;; vulpea-db-test.el ends here
