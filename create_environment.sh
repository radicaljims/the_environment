docker stop tomcat-centos-proc
docker rm tomcat-centos-proc

docker build -t tomcat-centos .

docker run -d -p 8080:8080 --name tomcat-centos-proc tomcat-centos
sleep 1
docker exec tomcat-centos-proc service mongod start

docker logs -f tomcat-centos-proc
