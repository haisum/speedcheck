FROM golang:1.14-buster
RUN apt update -y
RUN apt install jq -y
RUN go get -v github.com/m-lab/ndt7-client-go/cmd/ndt7-client
COPY speedcheck.sh /speedcheck.sh
ENTRYPOINT [ "bash", "/speedcheck.sh" ]

