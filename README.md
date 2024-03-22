# docker-hadoop
A simple yet helpful hadoop configuration.

# Instructions

**PLEASE** first read the entire README. At the bottom there are commands listed that might help you resolve the problem you've encountered.

## Commands to run (please stick to the order)
1. `docker ps` # check for namenode container hash
2. `docker exec -it NAMENODE_HASH bash`

## Comands to run on **NAMENODE**
1. `su hadoop && ./hadoop/bin/hdfs namenode -format`
2. `./hadoop/sbin/start-dfs.sh`
3. `jps` # Check if namenode, secondary name node, and jps are listed

### Swap to **RESOURCE MANAGER**
1. `docker ps # check for resource manager container hash`
2. `docker exec -it NAMENODE_HASH bash`
3. `su hadoop`
4. `PATH=$PATH:/home/hadoop/bin:$JAVA_HOME/bin`
5. `yarn resourcemanager`

### Swap back to **NAMENODE**
1. `./hadoop/sbin/start-yarn.sh`
2. `hdfs dfs -mkdir -p /user/hadoop/books`
3. `hdfs dfs -put ../test.txt books`
4. `yarn jar /home/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar wordcount books/test.txt output`

If you wish you can also copy a book of your choice to the namenode container and run a mapreduce that aims to wordcount that book. You can do that with: `docker cp`.

## Helpful commands

#### Switch to hadoop user (do it whenever you're logged in as root)
`su hadoop`

#### Check your envs whenever you see an error
`env `

#### If you've encountered an error regarding envs
`PATH=$PATH:/home/hadoop/bin:$JAVA_HOME/bin`
