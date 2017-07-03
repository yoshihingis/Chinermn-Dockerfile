# Chinermn-Dockerfile
This Dockerfile is base on beta release ChainerMN ny PFU.

(1)Usage
 1.At first,please build dockerfile
   :nvidia-docker build -t chainermn:0 .
   
 2.If Build will be finished with No problems, please start up dokcer container.
   :nvidia-docker run --rm -it chainermn:0
  
 3.If Container will start ,you will on directory /home/py34 on th container.
 
 4.If you use imagnet, you have to do python3.4,
 
    a) source bin/activate
    b) cd ./lib/python3.4/site-packages/chainermn/imagenet
    c) mpiexec --allow-run-as-root -n 1 pyhton train_imagnet.py -a alex train.txt test.txt 
    
    ※Caution
      1.train_imagnet.py supports only GPU mode , not CPU mode.
      2.Somtimes train_imagnet wull be crash and stopeed by Error.
       This problem happens by using both Open-MPI and Pyhton.
       Now PFU is trying to delete this issue.
