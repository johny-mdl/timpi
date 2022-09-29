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

ARG fileName=Collector_Linux_0.8.36

#RUN curl https://cdn.discordapp.com/attachments/981709237812072498/997361180022681621/TimpiCollector-0-8-35-linux.7z -o timpi.7z || wget https://cdn.discordapp.com/attachments/981709237812072498/997361180022681621/TimpiCollector-0-8-35-linux.7z -o timpi.7z
#RUN 7z x timpi.7z

RUN wget https://cdn.discordapp.com/attachments/981709237812072498/1011434761786507404/$fileName.zip
RUN unzip $fileName.zip

RUN chmod 700 ./$fileName/TimpiCollector

COPY start.sh ./$fileName
RUN chmod 700 ./$fileName/start.sh

#RUN echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/userns.conf

RUN chown timpi:timpi /var/log/timpi
RUN chown timpi:timpi /etc/timpi
RUN chown timpi:timpi ./$fileName/TimpiCollector
RUN chown timpi:timpi ./$fileName/start.sh

#RUN apt install qemu-user-static -y

#RUN apt-get install jq -y

USER timpi
WORKDIR $fileName
ENTRYPOINT ["./start.sh"]
