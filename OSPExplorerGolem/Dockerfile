# Use the official R image with R 4.3 and Ubuntu
FROM rocker/r-ver:4.3.1

# System dependencies for Shiny and your packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    pandoc \
    pandoc-citeproc \
    libcairo2-dev \
    libxt-dev \
    libssh2-1-dev \
    libpq-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff5-dev \
    libglib2.0-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages required: remotes + shiny + golem + others
# RUN R -e "install.packages(c('shiny', 'golem', 'remotes', 'DT', 'plotly'), repos='https://cloud.r-project.org')"
RUN install2.r --error shiny golem remotes DT plotly

# Copy your app source code into the container
COPY . /app

# Set working directory
WORKDIR /app

# Install your golem app package from local source
RUN R -e "remotes::install_local('.')"

# Expose the port the Shiny app listens on
EXPOSE 3838

# Run the Shiny app using your golem run_app function on 0.0.0.0 to be accessible outside the container
CMD ["R", "-e", "OSPExplorerGolem::run_app(options = list(host = '0.0.0.0', port = 3838))"]
