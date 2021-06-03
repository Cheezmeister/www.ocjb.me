FROM hexpm/elixir:1.11.3-erlang-22.0.6-alpine-3.11.3

# https://github.com/phoenixframework/phoenix/issues/2838#issuecomment-481913535
ENV MIX_HOME=/root/.mix

# https://docs.appsignal.com/support/operating-systems.html#musl-build-override
ENV APPSIGNAL_BUILD_FOR_MUSL=1

RUN apk add --update alpine-sdk coreutils npm
