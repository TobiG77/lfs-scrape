FROM tobig77/centos7-rbenv

MAINTAINER Tobias Gerschner <tobias.gerschner@gmail.com>

RUN su -lc 'mkdir -p /home/developer/lfs-scrape' developer
RUN su -lc 'echo "ruby-2.3.1" > /home/developer/lfs-scrape/.ruby-version' developer

ADD ./lfs-scrape.rb ./Gemfile* /home/developer/lfs-scrape/

RUN su -lc 'source ~/.bash_profile && cd /home/developer/lfs-scrape && gem install bundler && bundle install' developer

ENTRYPOINT [ "/bin/su", "--command", "source ~/.bash_profile && cd /home/developer/lfs-scrape/ && ruby lfs-scrape.rb", "developer" ]
