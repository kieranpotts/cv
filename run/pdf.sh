#!/usr/bin/env sh

# Pass additional CLI parameters as attributes to Asciidoctor via its `-a`
# option. Various `env-*` attributes can be used to conditionally toggle parts
# of the document.
# https://docs.asciidoctor.org/asciidoc/latest/attributes/document-attributes-ref/
attributes="${@}"
if [ -z "${attributes}" ]; then
  attributes=()
fi

# The directory where the source files are located, relative to the project root.
SOURCE_DIR=src

# The directory where the generated output files will be created, relative to
# the project root
BUILD_DIR=dist

docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
  $(for attr in $attributes; do echo -a $attr; done) \
  -D $BUILD_DIR \
  -o "Kieran Potts - CV.pdf" \
  $SOURCE_DIR/cv.adoc

docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
  $(for attr in $attributes; do echo -a $attr; done) \
  -D $BUILD_DIR \
  -o "Kieran Potts - Cover Letter.pdf" \
  $SOURCE_DIR/letter.adoc

