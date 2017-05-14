(defconstant *msize* 4096)

(defvar *ip*)
(defvar *dstack*)
(defvar *rstack*)
(defvar *memory* (make-array (list *msize*) :initial-element 0))
(defvar *instructions* (make-array '(16) :initial-element 'undefined))

(defun fetch ()
  (prog1 (aref *memory* *ip*)
    (incf *ip*)))

(defun fetch2 ()
  (+ (fetch) (ash (fetch) 8)))

(defun sign-extend (n)
  (if (zerop (logand n #x80))
      n
      (logior n #x-100)))

(defun load-image (file)
  (with-open-file (s file :element-type '(unsigned-byte 8))
    (read-sequence *memory* s)))

(defmacro definstruction (code &body body)
  `(setf (aref *instructions* ,code)
	 (lambda () ,@body)))

(definstruction 0
  nil)

(definstruction 1
  (setf (first *dstack*)
	(+ (aref *memory* (first *dstack*))
	   (ash (aref *memory* (1+ (first *dstack*))) 8))))

(definstruction 2
  (let ((n (fetch2)))
    (push *ip* *rstack*)
    (setf *ip* n)))

(definstruction 3
  (setf *ip* (pop *rstack*)))

(definstruction 4
  (push (fetch2) *dstack*))

(definstruction 7
    (push (pop *rstack*) *dstack*))

(definstruction 8
  (let ((n (pop *dstack*)))
    (setf (first *dstack*)
	  (logand (+ (first *dstack*) n) #xFFFF))))

(definstruction 9
  (let ((n (pop *dstack*)))
    (setf (first *dstack*)
	  (logxor (logand (first *dstack*) n) #xFFFF))))

(definstruction 10
    (push (pop *dstack*) *rstack*))

(definstruction 11
  (let ((n (fetch)))
    (when (zerop (pop *dstack*))
      (incf *ip* (sign-extend n)))))

(definstruction 12
  (let ((a (pop *dstack*))
	(n (pop *dstack*)))
    (setf (aref *memory* a) (logand n 255))
    (setf (aref *memory* (1+ a)) (logand (ash n -8) 255))))

(defun undefined ()
  (format t "~&HALTED~%")
  (throw 'halt nil))

(defun execute (code)
  (funcall (aref *instructions* code)))

(defun run ()
  (loop for i = (fetch) do
        (format t "~&~4,'0X ~2,'0X " (1- *ip*) i)
        (execute (logand (ash i -4) 15))
        (execute (logand i 15))))

(defun start (&optional file)
  (when file
    (load-image file))
  (let ((*ip* 0)
	(*dstack* nil)
	(*rstack* nil))
    (catch 'halt (run))))
