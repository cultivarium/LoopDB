FROM ubuntu:20.04

RUN apt-get update && apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata

RUN apt-get -y install postgresql-12 git curl python-dev gcc python2
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && python2 get-pip.py

RUN mkdir LoopDesigner
ADD . LoopDesigner/
RUN pip install loopdb
RUN cd LoopDesigner && pip install -r requirements.txt

RUN echo '#!/bin/bash\n\
/usr/lib/postgresql/12/bin/postgres -D /var/lib/postgresql/12/main -c config_file=/etc/postgresql/12/main/postgresql.conf &\n\
sleep 10\n\
python2 /LoopDesigner/server.py\n'\
> start.sh
RUN chmod +x start.sh

USER postgres
RUN  /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker loopdb

EXPOSE 8000
CMD ["/start.sh"]