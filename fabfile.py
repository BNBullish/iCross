
from fabric.api import *

env.roledefs={
'groupfrom':['root@192.168.100.216'],
'groupto64':['root@192.168.100.239','root@192.168.100.233','lk@192.168.100.202','root@192.168.100.226'],
'groupto32':['root@192.168.100.227','root@192.168.100.217','lk@192.168.100.219']
}
env.passwords={
'root@192.168.100.216:22':'123', #64bin from
'root@192.168.100.239:22':"123", #SUSE10 64
'root@192.168.100.233:22':"tiancun", #Centos5 64
'lk@192.168.100.202:22':"123", #ubuntu10 64
'root@192.168.100.226:22':"tiancun", #debian6 64
'root@192.168.100.227:22':"tiancun", #Centos5 32
'root@192.168.100.217:22':"tiancun", #debian6 32
'lk@192.168.100.219:22':"123" #Ubuntu10 32
}

def tar_dir(project_file='cpp11'):
    tar_file = project_file + '.tar.gz'
    local('tar -zcvf %s %s' % (tar_file,project_file))
    local("mkdir -p result")

@roles('groupto32')
#@roles('groupto64')
def put_dir(project_file='cpp11'):
    tar_file = project_file + '.tar.gz'
    put(tar_file,'/tmp')
    with cd('/tmp'):
        run('tar zxvf %s' % tar_file)

@roles('groupto32')
#@roles('groupto64')
def run_and_get(project_file='cpp11'):
    with cd ('/tmp/%s' %project_file):
        run("for i in `ls`;do ./$i >> result;rm -vrf test.txt;echo '==='>>result;done;")
        # run("something > result")
    host = env.host_string
    get('/tmp/%s/result' %project_file, '/home/fabric-workspace/result/%s' %host)     

@roles('groupto32')
#@roles('groupto64')
def remove_dir(project_file='cpp11'):
   run("rm -rf /tmp/%s*" %project_file)

@roles('groupto32')
#@roles('groupto64')
def shutdown():
    run("shutdown -h now")
