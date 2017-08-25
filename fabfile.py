
from fabric.api import *

env.roledefs={
'groupfrom':['root@192.168.100.216'],
'groupto64':['root@192.168.100.201','root@192.168.100.202','root@192.168.100.226','root@192.168.100.237','root@192.168.100.233','root@192.168.100.221'],
'groupto32':['root@192.168.100.205','root@192.168.100.219','root@192.168.100.217','root@192.168.100.204','root@192.168.100.227','root@192.168.100.234']
}
env.passwords={
'root@192.168.100.216:22':'123', #64bin from

'root@192.168.100.201:22':"tiancun", #SUSE11 64 +
'root@192.168.100.205:22':"tiancun", #SUSE11 32 +

'root@192.168.100.221:22':"123", #SUSE10 64 +
'root@192.168.100.234:22':"123", #SUSE10 32 +

'root@192.168.100.202:22':"123", #ubuntu10 64 +
'root@192.168.100.219:22':"123", #Ubuntu10 32 +

'root@192.168.100.226:22':"tiancun", #debian6 64 +
'root@192.168.100.217:22':"tiancun", #debian6 32 +

'root@192.168.100.237:22':"tiancun", #Centos6 64 +
'root@192.168.100.204:22':"tiancun", #Centos6 32 +

'root@192.168.100.233:22':"tiancun", #Centos5 64 +
'root@192.168.100.227:22':"tiancun"  #Centos5 32 +
}

#======================================================

my_dir = "/fabric"

def tar_dir_32(project_file='cppbin-32'):
    tar_file = project_file + '.tar.gz'
    local('tar -zcvf %s %s' % (tar_file,project_file))
    local("mkdir -p result-32")

@roles('groupto32')
def put_dir_32(project_file='cppbin-32'):
    tar_file = project_file + '.tar.gz'
    put(tar_file,'/tmp')
    with cd('/tmp'):
        run('tar zxvf %s' % tar_file)

@roles('groupto32')
def run_and_get_32(project_file='cppbin-32'):
    with cd ('/tmp/%s' %project_file):
        run("for i in `ls`;do ./$i >> result;rm -vrf test.txt;echo '==='>>result;done;")
        # run("something > result")
    host = env.host_string
    get('/tmp/%s/result' %project_file, '%s/result-32/%s' %(my_dir,host))     

@roles('groupto32')
def remove_dir_32(project_file='cppbin-32'):
   run("rm -rf /tmp/%s* /tmp/nginx*" %project_file)

@roles('groupto32')
def shutdown_32():
    run("shutdown -h now")

#======================================================

def tar_dir_64(project_file='cppbin-64'):
    tar_file = project_file + '.tar.gz'
    local('tar -zcvf %s %s' % (tar_file,project_file))
    local("mkdir -p result-64")

@roles('groupto64')
def put_dir_64(project_file='cppbin-64'):
    tar_file = project_file + '.tar.gz'
    put(tar_file,'/tmp')
    with cd('/tmp'):
        run('tar zxvf %s' % tar_file)

@roles('groupto64')
def run_and_get_64(project_file='cppbin-64'):
    with cd ('/tmp/%s' %project_file):
        run("for i in `ls`;do ./$i >> result;rm -vrf test.txt;echo '==='>>result;done;")
        # run("something > result")
    host = env.host_string
    get('/tmp/%s/result' %project_file, '%s/result-64/%s' %(my_dir,host))     

@roles('groupto64')
def remove_dir_64(project_file='cppbin-64'):
   run("rm -rf /tmp/%s* /tmp/nginx*" %project_file)

@roles('groupto64')
def shutdown_64():
    run("shutdown -h now")

#======================================================

@roles('groupto64')
def run_nginx_get_64(project_file='nginx-64'):
    with cd ('/tmp/%s' %project_file):
        try:
            run("/usr/sbin/groupadd -f nobody")
        except:
            pass
    	try:
            run("/usr/sbin/useradd -g nobody nobody")
        except:
            pass
        run("./nginx")

@roles('groupto32')
def run_nginx_get_32(project_file='nginx-32'):
    with cd ('/tmp/%s' %project_file):
    	try:
            run("/usr/sbin/groupadd -f nobody")
        except:
            pass
    	try:
            run("/usr/sbin/useradd -g nobody nobody")
        except:
            pass
        run("./nginx")

@roles('groupto64')
def stop_nginx_get_64(project_file='nginx-64'):
    with cd ('/tmp/%s' %project_file):
        run("./nginx -s stop")

@roles('groupto32')
def stop_nginx_get_32(project_file='nginx-32'):
    with cd ('/tmp/%s' %project_file):
        run("./nginx -s stop")
