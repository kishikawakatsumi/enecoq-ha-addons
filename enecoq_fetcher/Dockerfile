ARG BUILD_FROM
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-venv python3-pip ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
 && /opt/venv/bin/pip install --no-cache-dir enecoq-data-fetcher playwright \
 && /opt/venv/bin/python -m playwright install --with-deps chromium

ENV PATH="/opt/venv/bin:${PATH}"

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
