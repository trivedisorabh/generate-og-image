 
FROM node:12.10

RUN  apt-get update \
     # See https://crbug.com/795759
     && apt-get install -yq libgconf-2-4 \
     # Install latest chrome dev package, which installs the necessary libs to
     # make the bundled version of Chromium that Puppeteer installs work.
     && apt-get install -y wget --no-install-recommends \
     && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
     && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
     && apt-get update \
     && apt-get install -y google-chrome-unstable --no-install-recommends \
     && rm -rf /var/lib/apt/lists/*

# When installing Puppeteer through npm, instruct it to not download Chromium.
# Puppeteer will need to be launched with:
#   browser.launch({ executablePath: 'google-chrome-unstable' })
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

RUN mkdir -p /usr/local/src/generate-og-image
WORKDIR /usr/local/src/generate-og-image

COPY package.json package-lock.json /usr/local/src/generate-og-image/
RUN npm ci

# copy in src
COPY LICENSE README.md /usr/local/src/generate-og-image/
COPY src/ /usr/local/src/generate-og-image/src/
COPY __tests__/ /usr/local/src/generate-og-image/__tests__/
COPY dist/ /usr/local/src/generate-og-image/dist/

RUN chmod +x /usr/local/src/generate-og-image/dist/index.js

ENTRYPOINT ["/usr/local/src/generate-og-image/dist/index.js"]