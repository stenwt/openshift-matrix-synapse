FROM centos:7

# MAINTAINER Sten Turpin <sten@redhat.com>

ENV REPORT_STATS yes

LABEL io.k8s.description="Platform for building matrix synapse" \
      io.k8s.display-name="builder matrix synapse" \
      io.openshift.expose-services="8008:http" \
      io.openshift.tags="builder,matrix,synapse"

RUN yum -y install epel-release && yum clean all

RUN yum install -y python-devel libtiff-devel libjpeg-devel libzip-devel freetype-devel lcms2-devel libwebp-devel tcl-devel tk-devel python-pip libffi-devel openssl-devel && yum -y groupinstall "Development Tools" && yum clean all -y

RUN pip install --upgrade setuptools

RUN pip install https://github.com/matrix-org/synapse/tarball/master

RUN pip install psycopg2

RUN mkdir -p /opt/app-root/src/synapse && python -B -m synapse.app.homeserver --config-path /opt/app-root/src/synapse/homeserver.yaml --generate-config --server-name=openshift-synapse --report-stats no

RUN mkdir /synapse

RUN for str in media_store uploads homeserver.db homeserver.log homeserver.pid ; do sed -i "s/\/$str/\/synapse\/$str/" /opt/app-root/src/synapse/homeserver.yaml; done

RUN sed -i 's/\/homeserver.log/\/synapse\/homeserver.log/' /opt/app-root/src/synapse/openshift-synapse.log.config

RUN chmod -R a+rwx /opt/app-root/src/synapse /synapse

EXPOSE 8008

CMD ["python", "-m", "synapse.app.homeserver", "--config-path", "/opt/app-root/src/synapse/homeserver.yaml" ]
