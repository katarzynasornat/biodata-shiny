# Use base image with shiny-server pre-installed
FROM rocker/r-ver:4.3.1

# Install system libs
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libglpk-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    libv8-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    zlib1g-dev \
    && apt-get clean

# Install R packages
RUN R -e "install.packages(c('shiny', 'leaflet', 'dplyr', 'data.table', 'highcharter', 'lubridate', 'DT', 'glue', 'geosphere', 'httr', 'jsonlite', 'duckdb', 'DBI', 'shinyjs'), repos='https://cloud.r-project.org')"

COPY . /home/app/
WORKDIR /home/app

# Expose the port your app will run on
EXPOSE 8180

# Run your app
CMD ["Rscript", "app1.R"]


