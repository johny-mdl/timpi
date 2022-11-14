FROM ubuntu:22.04 as base

EXPOSE 5000 5001

RUN apt-get update && apt-get upgrade -y
RUN apt-get install p7zip-full -y \
	&& apt install curl -y \
	&& apt install wget -y

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

ARG fileName=Timpi_0.8.37

RUN wget https://cdn.discordapp.com/attachments/981709237812072498/1031449625741250621/Timpi_Linux_0.8.37.7z
RUN 7z x Timpi_Linux_0.8.37.7z

RUN chmod 711 ./$fileName/TimpiCollector
RUN chmod 711 ./$fileName/TimpiManagerLinux
RUN chmod 711 ./$fileName/TimpiUI

COPY start.sh ./$fileName
RUN chmod 700 ./$fileName/start.sh

# RUN echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/userns.conf

# RUN chown timpi:timpi /var/log/timpi
# RUN chown timpi:timpi /etc/timpi
# RUN chown timpi:timpi ./$fileName
# RUN chown timpi:timpi ./$fileName/TimpiCollector
# RUN chown timpi:timpi ./$fileName/start.sh

#RUN apt install qemu-user-static -y

# USER timpi
WORKDIR $fileName
ENTRYPOINT ["./start.sh"]
