# NHANES / 纯临床队列分析运行环境
# V1.3.3 在 V1.3.2 基础上增量安装 rms（列线图、Cox 校准）及模型验证常用包。
# 不安装 rms Suggests，避免 Quay 构建超时。
#
# 构建示例：
#   cd tool-dockerfile/nhanes-assoc
#   docker build -t quay.io/1733295510/nhanes-assoc:V1.3.3 .
#   docker tag quay.io/1733295510/nhanes-assoc:V1.3.3 \
#     genaibase-cn-beijing.cr.volces.com/genaibase/nhanes-assoc:v1
#   docker push quay.io/1733295510/nhanes-assoc:V1.3.3
#   docker push genaibase-cn-beijing.cr.volces.com/genaibase/nhanes-assoc:v1

FROM quay.io/1733295510/nhanes-assoc:V1.3.2

LABEL maintainer="1733295510 <1733295510@qq.com>"
LABEL org.opencontainers.image.title="nhanes-assoc"
LABEL org.opencontainers.image.description="NHANES + clinical cohort tools with rms/pROC/survivalROC on nhanes-assoc V1.3.2."

ARG CRAN_REPO=https://cloud.r-project.org

USER root
WORKDIR /work

# rms 依赖 Hmisc；pROC / survivalROC 供模型验证 ROC 使用
RUN R -e "install.packages(c('Hmisc', 'rms', 'pROC', 'survivalROC'), repos='${CRAN_REPO}', ask=FALSE, dependencies=c('Depends','Imports'))"

RUN R -e "suppressPackageStartupMessages({ \
  library(rms); library(pROC); library(survivalROC); \
  library(readr); library(gtsummary); \
}); cat('nhanes-assoc R packages OK (V1.3.3)\n')" \
 && quarto --version | head -1
