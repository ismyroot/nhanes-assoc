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

USER root
WORKDIR /work

# NHANES 关联分析 R 包（P3M bookworm 二进制，与 base-image 一致）
RUN R -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/bookworm/latest')); \
  Sys.setenv(RSPM_ROOT = 'https://packagemanager.posit.co/cran/__linux__/bookworm/latest'); \
  install.packages(c( \
    'data.table', 'dplyr', 'survey', 'ggplot2', 'knitr', 'kableExtra', 'forestplot' \
  ), Ncpus = parallel::detectCores(), ask = FALSE)"

RUN R -e "pkgs <- c('data.table', 'dplyr', 'survey', 'ggplot2', 'knitr', 'kableExtra', 'forestplot'); \
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]; \
  if (length(missing) > 0) stop('Missing packages: ', paste(missing, collapse = ', ')); \
  cat('nhanes-assoc R packages OK\n')" \
 && quarto --version | head -1


