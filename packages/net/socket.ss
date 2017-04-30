;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-04-29 00:03:30.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (net socket) 
  (export
   SOCK_STREAM     
   SOCK_DGRAM      
   SOCK_RAW      
   SOCK_RDM        
   SOCK_SEQPACKET
   SOCK_PACKET
   AF_INET
   INADDR_ANY
   make-sockaddr-in
   
   close
   socket:bind
   socket:close
   bind
   connect
   listen
   accept
   socket:listen
   socket:accept
   getsockname
   getpeername
   socketpair
   shutdown
   setsockopt
   getsockopt
   sendmsg
   recvmsg
   send
   recv
   sendto
   recvfrom

   make-socket
   make-fd-input-port
   make-fd-output-port
   
   )

 (import (scheme) (utils libutil) (cffi cffi) (net socket-ffi) )



 (define (make-fd-input-port fd)
  (let ((buf (cffi-alloc 8)))
    (make-input-port (lambda (msg . args)
		     (record-case
		      (cons msg args)
		      [block-read (p s n) (block-read fd s n)]
		      [read-char (p)
				 (let* ((c (cread fd buf 1))
					(char (cffi-get-char buf)))
				   (if (= c -1)
				       char
				       char ))
				 ]
		      [close-port (p) (mark-port-closed! p)]
		      [else (assertion-violationf 'make-fd-input-port
						  "operation ~s not handled"
						  msg)]
		      ))
		     "")))

  (define (make-fd-output-port fd)
  (let ((buf (cffi-alloc 8)))
    (make-output-port (lambda (msg . args)
		     (record-case
		      (cons msg args)
		      [block-write (p s n) 
				   (cwrite fd s n)]
		      [write-char (c p)
				  (cffi-set-char buf c)
				  (cwrite fd buf 1)
				 ]
		      [close-port (p) (mark-port-closed! p)]
		      [else (assertion-violationf 'make-fd-output-port
						  "operation ~s not handled"
						  msg)]
		      )  
		     )
		   "")))
 
 (define (make-socket family type port)
   (let* ((socket-fd (socket family type 0))
	  (server-addr (make-sockaddr-in family INADDR_ANY port ))
	  (i (cffi-alloc 32))
	  )
     
     (setsockopt socket-fd SOL_SOCKET SO_REUSEADDR i 32)
     (cffi-free i)
     (list socket-fd server-addr)
     ))
     
 (define-syntax socket:accept
   (syntax-rules ()
     [(_ socket addr addr-len)
      (accept (car socket) addr addr-len)]
     [(_ socket )
      (let ((ret (accept (car socket) 0 0)))
	ret)
		]))

  (define-syntax socket:bind
    (syntax-rules ()
      [(_ socket)
       (bind (car socket) (car (cdr socket)) 16 ) ]))


  (define-syntax socket:listen
    (syntax-rules ()
      [(_ socket )
       (listen (car socket)  10)]
      [(_ socket back-log)
       (listen (car socket) back-log)]
      ))
 
  (define (socket:close socket)
    (close (car socket) ))
  
)