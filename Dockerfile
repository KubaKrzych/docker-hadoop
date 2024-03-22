FROM eclipse-temurin:8

WORKDIR /home

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y openssh-client openssh-server wget && \
    wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    tar -xvzf hadoop-3.3.6.tar.gz && \
    ln -s hadoop-3.3.6 hadoop && \
    rm hadoop-3.3.6.tar.gz && \
    ssh-keygen -A

RUN groupadd -r hadoop && \
    useradd -r -g hadoop -d /home/hadoop -m hadoop && \
    mkdir -p /home/hadoop/data/nameNode /home/hadoop/data/dataNode && \
    chmod -R 700 /home/hadoop/data && \
    chown -R hadoop:hadoop /home/hadoop /home/hadoop-3.3.6

ENV HADOOP_HOME=/home/hadoop \
    HADOOP_CONF_DIR=/home/hadoop/etc/hadoop \
    HADOOP_MAPRED_HOME=/home/hadoop \
    HADOOP_COMMON_HOME=/home/hadoop \
    HADOOP_HDFS_HOME=/home/hadoop \
    HDFS_NAMENODE_USER=hadoop \
    HDFS_DATANODE_USER=hadoop \
    HDFS_SECONDARYNAMENODE_USER=hadoop \
    YARN_RESOURCEMANAGER_USER=hadoop \
    YARN_NODEMANAGER_USER=hadoop \
    YARN_HOME=/home/hadoop \
    JAVA_HOME=/opt/java/openjdk \
    PDSH_RCMD_TYPE=ssh \
    PATH=/home/hadoop/bin:/home/hadoop/sbin:/opt/java/openjdk/bin:$PATH

USER hadoop
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

USER root

COPY test.txt /test.txt

CMD ["/usr/sbin/sshd", "-D"]
