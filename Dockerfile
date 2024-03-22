FROM eclipse-temurin:8 as build

WORKDIR /home

# Downloading and unpacking Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    tar -xvzf hadoop-3.3.6.tar.gz && \
    ln -s hadoop-3.3.6 hadoop

RUN apt update && apt upgrade -y

# Creating the `hadoop` user and group
RUN groupadd -r hadoop && useradd -r -g hadoop -d /home/hadoop -m hadoop

# Setting environment variables
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
    PDSH_RCMD_TYPE=ssh

# Correcting JAVA_HOME appending
ENV JAVA_HOME=/opt/java/openjdk \
    PATH=/home/hadoop/bin:/home/hadoop/sbin:$PATH 


# Copying Hadoop configuration and setting the proper owner
# Ensure that the Hadoop configuration files are present in the build context
COPY --chown=hadoop:hadoop ./hadoop/etc/hadoop $HADOOP_CONF_DIR
COPY --chown=hadoop:hadoop run.sh /home/hadoop/run.sh

# Making run.sh executable
RUN chmod +x /home/hadoop/run.sh

# Installing necessary packages
RUN apt install -y openssh-client openssh-server && ssh-keygen -A && \
    mkdir /run/sshd

# Changing ownership of the Hadoop directories to `hadoop` user
# This line already changes ownership recursively, the `-h` option is for symbolic links
RUN chown -R hadoop:hadoop /home/hadoop /home/hadoop-3.3.6

# Switching to `hadoop` user
USER hadoop
RUN echo "export HADOOP_HOME=/home/hadoop" >> ~/.bashrc
RUN echo "export HADOOP_CONF_DIR=/home/hadoop/etc/hadoop" >> ~/.bashrc
RUN echo "export HADOOP_MAPRED_HOME=/home/hadoop" >> ~/.bashrc
RUN echo "export HADOOP_COMMON_HOME=/home/hadoop" >> ~/.bashrc
RUN echo "export HADOOP_HDFS_HOME=/home/hadoop" >> ~/.bashrc
RUN echo "export HDFS_NAMENODE_USER=hadoop" >> ~/.bashrc
RUN echo "export HDFS_DATANODE_USER=hadoop" >> ~/.bashrc
RUN echo "export HDFS_SECONDARYNAMENODE_USER=hadoop" >> ~/.bashrc
RUN echo "export YARN_RESOURCEMANAGER_USER=hadoop" >> ~/.bashrc
RUN echo "export YARN_NODEMANAGER_USER=hadoop" >> ~/.bashrc
RUN echo "export YARN_HOME=/home/hadoop" >> ~/.bashrc
RUN echo "export PDSH_RCMD_TYPE=ssh" >> ~/.bashrc
RUN echo "export JAVA_HOME=/opt/java/openjdk" >> ~/.bashrc
RUN echo "export PATH=/home/hadoop/bin:/home/hadoop/sbin:/opt/java/openjdk/bin:$PATH" >> ~/.bashrc


# Generating SSH keys for `hadoop` user and setting permissions
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# Creating necessary data directories and assigning them to `hadoop` user
# Note: Adjusting path for dataNode directory creation and permissions
RUN mkdir -p /home/hadoop/data/nameNode /home/hadoop/data/dataNode && \
    chmod -R 700 /home/hadoop/data

COPY test.txt /test.txt

# Switching back to root user if necessary for CMD
USER root

CMD ["/usr/sbin/sshd", "-D"]
