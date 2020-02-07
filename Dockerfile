FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

ARG bbb_properties=/usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties

RUN apt-get update && apt-get install -y locales language-pack-en

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8 

RUN apt-get update && \
	apt-get install -y wget apt-transport-https software-properties-common haveged tomcat7 net-tools sudo

RUN add-apt-repository ppa:bigbluebutton/support -y && \
	add-apt-repository ppa:rmescandon/yq -y

RUN apt-get update && \
	apt-get dist-upgrade -y

RUN wget -qO - https://www.mongodb.org/static/pgp/server-3.4.asc | sudo apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
RUN apt-get update && \
	apt-get install -y mongodb-org curl

RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
	apt-get install -y nodejs

RUN wget https://ubuntu.bigbluebutton.org/repo/bigbluebutton.asc -O- | sudo apt-key add - && \
	echo "deb https://ubuntu.bigbluebutton.org/xenial-220/ bigbluebutton-xenial main" | sudo tee /etc/apt/sources.list.d/bigbluebutton.list && \
	apt-get update

RUN ACCEPT_EULA=Y apt-get install -y bigbluebutton bbb-html5

RUN apt-get update && \
	apt-get dist-upgrade -y

RUN sed -i "s/attendeesJoinViaHTML5Client=false/attendeesJoinViaHTML5Client=true/g" $bbb_properties && \
	sed -i "s/moderatorsJoinViaHTML5Client=false/moderatorsJoinViaHTML5Client=true/g" $bbb_properties && \
	sed -i "s/swfSlidesRequired=true/swfSlidesRequired=false/g" $bbb_properties

ENV XDG_RUNTIME_DIR="/run/user/$UID"
ENV DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

#RUN systemctl set-environment LANG=en_US.UTF-8

EXPOSE 80 443
CMD ["bbb-conf", "--restart", "--setip localhost"]