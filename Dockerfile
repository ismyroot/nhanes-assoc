# NHANES 单变量临床关联分析运行环境（9 个 Quarto qmd 共用）
# 基础镜像已含 R 4.4.1、Quarto 1.6.40、TeX Live 2025（中文 PDF 支持）。
# 不包含 qmd 脚本；由 Galaxy 工具目录（PVC）或任务工作目录在运行时提供。
#
# 构建示例：
#   cd /home/ubuntu/zhaoyiran/TOOL-Dockerfile/NHANES
#   docker build -t quay.io/1733295510/nhanes-assoc:V1.0.0 .
#   docker tag quay.io/1733295510/nhanes-assoc:V1.0.0 \
#     genaibase-cn-beijing.cr.volces.com/genaibase/nhanes-assoc:v1
#   docker push genaibase-cn-beijing.cr.volces.com/genaibase/nhanes-assoc:v1

FROM quay.io/1733295510/base-image:V3.1

LABEL maintainer="1733295510 <1733295510@qq.com>"
LABEL org.opencontainers.image.title="nhanes-assoc"
LABEL org.opencontainers.image.description="NHANES univariate clinical association Quarto tools on base-image (R/Quarto/TeX)."

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

ARG CRAN_REPO=https://cloud.r-project.org

USER root
WORKDIR /work

# kableExtra / svglite / textshaping 编译与运行时依赖（对齐 bulkrna-Base / scRNA-base）
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libtiff5-dev \
    libuv1-dev \
    zlib1g-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxml2-dev \
 && rm -rf /var/lib/apt/lists/*

# 分步安装，避免 dependencies=TRUE 并行拉取大量 Suggests 导致 kableExtra 装完却无法 load
RUN R -e "install.packages(c('data.table', 'dplyr', 'survey', 'ggplot2', 'knitr'), repos='${CRAN_REPO}', ask=FALSE)" && \
    R -e "remotes::install_version('kableExtra', '1.4.0', repos='${CRAN_REPO}', upgrade='never')" && \
    R -e "install.packages('forestplot', repos='${CRAN_REPO}', ask=FALSE)"

RUN R -e "suppressPackageStartupMessages({ \
  library(data.table); library(dplyr); library(survey); library(ggplot2); \
  library(knitr); library(kableExtra); library(forestplot); \
}); cat('nhanes-assoc R packages OK\n')" \
 && quarto --version | head -1
