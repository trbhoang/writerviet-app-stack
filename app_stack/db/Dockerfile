FROM mariadb:10.4

# Create a user and group on the container and use this user to run container
# then assign appropriate permission for this GID on host
RUN groupadd -g 2000 mygroup
RUN adduser --disabled-password --gecos "" --force-badname --ingroup mygroup myuser

# Set file permission for volumes on host
# chown -R root:2000 /data/myvolume
# chmod -R 775 /data/myvolume
# chmod g+s /data/myvolume

# Change current user to myuser
USER myuser

# Expose port 3306 and start mariadb server
EXPOSE 3306
CMD ["mysqld"]