FROM python:2.7
LABEL maintainer="Peter Huang<peterhlycf@gmail.com>"
RUN pip  install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com  flask 
COPY app.py /app/
WORKDIR /app
EXPOSE 5000
CMD ["python", "app.py"]
