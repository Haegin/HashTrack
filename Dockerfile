FROM ruby:2.2-onbuild
ENV RACK_ENV=production
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0"]
EXPOSE 4567
