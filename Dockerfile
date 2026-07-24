# NHANES 单变量临床关联分析运行环境（9 个 Quarto qmd 共用）
# V1.3.2 在 V1.1 镜像基础上增量安装基线表 R 包；gtsummary 仅装 Depends/Imports，避免 Suggests 拖慢构建。
#
# 构建示例（Quay.io 触发构建后）：
#   cd /home/ubuntu/zhaoyiran/TOOL-Dockerfile/NHANES
#   docker build -t quay.io/1733295510/nhanes-assoc:V1.3.2 .
#   docker tag quay.io/1733295510/nhanes-assoc:V1.3.2 \
#     genaibase-cn-beijing.cr.volces.com/genaibase/nhanes-assoc:v1
#   docker push genaibase-cn-beijing.cr.volces.com/genaibase/nhanes-assoc:v1

FROM quay.io/1733295510/nhanes-assoc:V1.1

LABEL maintainer="1733295510 <1733295510@qq.com>"
LABEL org.opencontainers.image.title="nhanes-assoc"
LABEL org.opencontainers.image.description="NHANES clinical association + baseline table (readr/stringr/tableone/gtsummary) on nhanes-assoc V1.1."

ARG CRAN_REPO=https://cloud.r-project.org

USER root
WORKDIR /work

# 分步安装：不拉 gtsummary Suggests（gt/ragg/flextable 等），避免 Quay 构建超时与编译失败
RUN R -e "install.packages(c('readr', 'stringr', 'tableone'), repos='${CRAN_REPO}', ask=FALSE)" && \
    R -e "install.packages(c('cards', 'cardx', 'broom.helpers', 'tidyr'), repos='${CRAN_REPO}', ask=FALSE)" && \
    R -e "install.packages('gtsummary', repos='${CRAN_REPO}', ask=FALSE, dependencies=c('Depends','Imports'))"

RUN R -e "suppressPackageStartupMessages({ \
  library(data.table); library(dplyr); library(survey); library(ggplot2); \
  library(knitr); library(kableExtra); library(forestplot); \
  library(readr); library(stringr); library(tidyr); library(tableone); library(gtsummary); \
}); cat('nhanes-assoc R packages OK (V1.3.2)\n')" \
 && quarto --version | head -1
