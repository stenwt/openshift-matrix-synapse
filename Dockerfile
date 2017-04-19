FROM centos:7

# MAINTAINER Sten Turpin <sten@redhat.com>

ENV REPORT_STATS yes

LABEL io.k8s.description="Platform for building matrix synapse" \
      io.k8s.display-name="builder matrix synapse" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,matrix,synapse"

RUN yum -y install epel-release && yum clean all

RUN yum install -y python-devel libtiff-devel libjpeg-devel libzip-devel freetype-devel lcms2-devel libwebp-devel tcl-devel tk-devel python-pip libffi-devel openssl-devel && yum -y groupinstall "Development Tools" && yum clean all -y

RUN pip install --upgrade setuptools

RUN pip install https://github.com/matrix-org/synapse/tarball/master

RUN mkdir /var/run/synapse && python -B -m synapse.app.homeserver -c /var/run/synapse/homeserver.yaml --generate-config --server-name=openshift-synapse --report-stats no

EXPOSE 8008

CMD ["python -m synapse.app.homeserver --config-path /var/run/synapse/homeserver.yaml"]
