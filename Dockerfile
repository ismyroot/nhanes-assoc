# NHANES 单变量临床关联分析运行环境（9 个 Quarto qmd 共用）
# V1.3 在 V1.1 镜像基础上增量安装 tableone / gtsummary，避免全量重建。
#
# 构建示例（Quay.io 触发构建后）：
#   cd /home/ubuntu/zhaoyiran/TOOL-Dockerfile/NHANES
#   docker build -t quay.io/1733295510/nhanes-assoc:V1.3.0 .
#   docker tag quay.io/1733295510/nhanes-assoc:V1.3.0 \
#     genaibase-cn-beijing.cr.volces.com/genaibase/nhanes-assoc:v1
#   docker push genaibase-cn-beijing.cr.volces.com/genaibase/nhanes-assoc:v1

FROM quay.io/1733295510/nhanes-assoc:V1.1

LABEL maintainer="1733295510 <1733295510@qq.com>"
LABEL org.opencontainers.image.title="nhanes-assoc"
LABEL org.opencontainers.image.description="NHANES clinical association + baseline table (tableone/gtsummary) on nhanes-assoc V1.1."

ARG CRAN_REPO=https://cloud.r-project.org

USER root
WORKDIR /work

# 在 V1.1 已有 R/Quarto/TeX 与 NHANES 关联分析包之上，增量安装基线表依赖
RUN R -e "install.packages('tableone', repos='${CRAN_REPO}', ask=FALSE)" && \
    R -e "install.packages('gtsummary', repos='${CRAN_REPO}', ask=FALSE, dependencies=TRUE)"

RUN R -e "suppressPackageStartupMessages({ \
  library(data.table); library(dplyr); library(survey); library(ggplot2); \
  library(knitr); library(kableExtra); library(forestplot); \
  library(tableone); library(gtsummary); \
}); cat('nhanes-assoc R packages OK (V1.3)\n')" \
 && quarto --version | head -1
