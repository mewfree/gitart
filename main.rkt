#lang racket
(require gregor)

(define (create-script)
  (define output-filename "gitart.sh")
  (if (file-exists? output-filename) (delete-file output-filename) (void))

  (define string-start
    (string-join (list "#!/bin/bash"
                       (string-replace "REPO=GITART_REPO_NAME" "GITART_REPO_NAME" (getenv "GITART_REPO_NAME"))
                       "git init $REPO"
                       "cd $REPO"
                       "touch README.md"
                       "git add README.md"
                       "touch gitart"
                       "git add gitart") "\n"))

  (define string-content
    (string-join
      (map (lambda (i)
        (string-join
          (list
            "echo meow >> gitart"
            (string-replace "GIT_AUTHOR_DATE=FAKE_DATET12:00:00 GIT_COMMITTER_DATE=FAKE_DATET12:00:00 git commit -a -m \"gitart\" > /dev/null"
                            "FAKE_DATE"
                            (date->iso8601 (-days (today) i)))) "\n"))
        (range 0 (+ 365 7))) "\n"))

  (define string-end
    (string-join (list (string-replace "git remote add origin git@github.com:GITART_USERNAME/$REPO.git" "GITART_USERNAME" (getenv "GITART_USERNAME"))
                       "git pull"
                       "git push -u origin master") "\n"))

  (define string-complete
    (string-join (list string-start string-content string-end) "\n"))

  (display-to-file string-complete output-filename))

(if (and (getenv "GITART_REPO_NAME") (getenv "GITART_USERNAME"))
    (create-script)
    (displayln "Please provide GITART_REPO_NAME and GITART_USERNAME environment variables"))
