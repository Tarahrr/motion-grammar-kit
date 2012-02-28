;;;; -*- Lisp -*-
;;;;
;;;; Copyright (c) 2012, Georgia Tech Research Corporation
;;;; All rights reserved.
;;;;
;;;; Author(s): Neil T. Dantam <ntd@gatech.edu>
;;;; Georgia Tech Humanoid Robotics Lab
;;;; Under Direction of Prof. Mike Stilman
;;;;
;;;; This file is provided under the following "BSD-style" License:
;;;;
;;;;   Redistribution and use in source and binary forms, with or
;;;;   without modification, are permitted provided that the following
;;;;   conditions are met:
;;;;   * Redistributions of source code must retain the above
;;;;     copyright notice, this list of conditions and the following
;;;;     disclaimer.
;;;;   * Redistributions in binary form must reproduce the above
;;;;     copyright notice, this list of conditions and the following
;;;;     disclaimer in the documentation and/or other materials
;;;;     provided with the distribution.
;;;;
;;;;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
;;;;   CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
;;;;   INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
;;;;   MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;;;;   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
;;;;   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;;;   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
;;;;   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;;;;   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;;;;   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;;;   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
;;;;   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
;;;;   EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



;;;; Token Classes
;;;;  - Interrupt: Asynchronous
;;;;  - Predicate: Synchronous
;;;;  - Semantic:  A function call


(defun token-interrupt-p (token)
  (and (listp token)
       (eq :interrupt (car token))))

(defun token-predicate-p (token)
  (and (listp token)
       (eq :predicate (car token))))

(defun token-semantic-p (token)
  (and (listp token)
       (eq :semantic (car token))))

;; Parsing Structures:
;; - Big Table
;; - Per-state structure with
;;   - semantic thingy
;;   - Predicate List
;;   - Successor array / Edge List / Search Tree / (Perfect) Hash table

(defun dfa->motion-parser (dfa)
  (assert (dfap dfa))
  (assert (= 1 (length (fa-start dfa))))
  (let ((mover (fa-mover dfa)))
    (lambda (predicate-function semantic-function interrupt-function)
      (labels ((transition (state token)
                 ;; go to the next state
                 (execute (car (funcall mover state token))))
               (execute (state)
                 (let ((zeta (block find-token
                            ;; check predicates
                            (dotimes (i (length (fa-tokens fa)))
                              (when (and (token-predicate-p
                                          (fa-token-name fa i))
                                         (funcall predicate-function i))
                                (return-from find-token i)))
                            ;; check for semantics
                            (dotimes (i (length (fa-tokens fa)))
                              (when (token-semantic-p (fa-token-name fa i))
                                (return-from find-token i)))
                            ;; wait for interrupt
                            (interrupt-function))))
                   (unless (= zeta -1)
                     (transition state zeta))))))
      (execute (car (fa-start dfa))))))





