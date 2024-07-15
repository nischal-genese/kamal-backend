# `python-base` sets up all our shared environment variables
FROM public.ecr.aws/d4h9f1v3/python-3.10:latest as python-base

    # python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_VERSION=1.7.1 \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # make poetry create virtual environment in the project's root directory
    # naming of virtual environment directory is .venv
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    # stores poetry caches
    POETRY_CACHE_DIR="/tmp/poetry_cache" \
    # location for requirements + virtual environment
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"


# `builder-base` stage is used to build deps + create virual environment
FROM python-base as builder-base
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    # deps for installing poetry
    curl \
    # deps for building python deps
    build-essential

# install poetry - respects $POETRY_VERSION and $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | python3 -

# copy project pyproject.toml and poetry.lock for caching purpose
WORKDIR $PYSETUP_PATH
COPY pyproject.toml ./

# installs runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
# https://python-poetry.org/docs/configuration/
RUN poetry install --no-dev --no-root


# `development` image is used during development / testing
FROM python-base as development
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    # deps for installing poetry
    curl \
    # deps for building python deps
    build-essential

ENV FASTAPI_ENV=development
WORKDIR $PYSETUP_PATH

# copy in our built poetry + venv
COPY --from=builder-base $POETRY_HOME $POETRY_HOME
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH

# install all dependencies
RUN poetry install --no-root

# will become mountpoint of our code
WORKDIR /app

COPY . /app/

EXPOSE 8000
CMD [ "uvicorn", "main:app", "--host", "0.0.0.0"]