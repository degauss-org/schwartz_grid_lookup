FROM rocker/r-ver:4.0.2

# install required version of renv
RUN R --quiet -e "install.packages('remotes', repos = 'https://cran.rstudio.com')"
ENV RENV_VERSION 0.11.0
RUN R --quiet -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

WORKDIR /app

RUN apt-get update \
  && apt-get install -yqq --no-install-recommends \
  libgdal-dev \
  libgeos-dev \
  libudunits2-dev \
  libproj-dev \
  && apt-get clean

COPY renv.lock .
RUN R --quiet -e "renv::restore()"

COPY schwartz_grid_geohashed.qs .
COPY schwartz_grid_lookup.R .

WORKDIR /tmp

ENTRYPOINT ["/app/schwartz_grid_lookup.R"]
