FROM ubuntu:22.04 as base

EXPOSE 5000 5001

RUN apt-get update && apt-get upgrade -y
RUN apt-get install p7zip-full -y \
	&& apt install curl -y \
	&& apt install wget -y \
	&& apt install unzip

RUN mkdir /var/log/timpi
RUN mkdir /etc/timpi

RUN export DEBIAN_FRONTEND=noninteractive; \
    export DEBCONF_NONINTERACTIVE_SEEN=true; \
    echo 'tzdata tzdata/Areas select Etc' | debconf-set-selections; \
    echo 'tzdata tzdata/Zones/Etc select UTC' | debconf-set-selections; \
    apt update -qqy \
	&& apt install -qqy --no-install-recommends tzdata \
 	&& apt clean \
 	&& rm -rf /var/lib/apt/lists/* && apt update

RUN apt -q -y install lxqt

####################################################################################################################################################
####################################################################################################################################################
####################################################################################################################################################
FROM base as timpi_version

RUN useradd -ms /bin/bash timpi
WORKDIR /home/timpi

ARG fileName=Linux_0.8.39

RUN wget https://cdn.discordapp.com/attachments/981709237812072498/1045776867841556490/Linux_0.8.39.zip
RUN unzip $fileName.zip

RUN rm -rf $fileName.zip

RUN chmod 711 ./$fileName/TimpiCollector
RUN chmod 711 ./$fileName/TimpiManagerLinux
RUN chmod 711 ./$fileName/TimpiUI

COPY start.sh ./$fileName
RUN chmod 700 ./$fileName/start.sh

# RUN echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/userns.conf
#RUN apt install qemu-user-static -y
RUN chown timpi:timpi /var/log/timpi
RUN chown timpi:timpi /etc/timpi
RUN chown timpi:timpi ./$fileName
RUN chown timpi:timpi ./$fileName/TimpiCollector
RUN chown timpi:timpi ./$fileName/TimpiManagerLinux
RUN chown timpi:timpi ./$fileName/TimpiUI
RUN chown timpi:timpi ./$fileName/start.sh

USER timpi
WORKDIR $fileName
ENTRYPOINT ["./start.sh"]
