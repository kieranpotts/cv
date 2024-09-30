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

# Generate the CV PDF file.
docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
  $(for attr in $attributes; do echo -a $attr; done) \
  -D $BUILD_DIR \
  -o "Kieran Potts - CV.pdf" \
  $SOURCE_DIR/cv.adoc

# Generate the cover letter PDF.
docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
  $(for attr in $attributes; do echo -a $attr; done) \
  -D $BUILD_DIR \
  -o "Kieran Potts - Cover Letter.pdf" \
  $SOURCE_DIR/letter.adoc

# The above commands use a temporary container to generate the initial PDF
# files. We want to modify these files using the `cpdf` tool, but Docker-generated
# files will be owned by root and other users will have only read access. To
# allow editing, change ownership to the current user.
me=$(whoami)
sudo chown $me:$me "$BUILD_DIR/Kieran Potts - CV.pdf"
sudo chown $me:$me "$BUILD_DIR/Kieran Potts - Cover Letter.pdf"

# Use cpdf to make some adjustments to the generated PDF files, eg. give them
# titles (which are not created by asciidoctor-pdf), and also merge them into
# a single file. This tool sends to stdout an annoying license message, which
# I'm redirecting away. https://github.com/coherentgraphics/cpdf-binaries/
./bin/cpdf "$BUILD_DIR/Kieran Potts - CV.pdf" \
  AND -set-title "Kieran Potts - CV" \
  -o "$BUILD_DIR/Kieran Potts - CV.pdf" &> /dev/null

./bin/cpdf "$BUILD_DIR/Kieran Potts - Cover Letter.pdf" \
  AND -set-title "Kieran Potts - Cover Letter" \
  -o "$BUILD_DIR/Kieran Potts - Cover Letter.pdf" &> /dev/null

./bin/cpdf -merge $BUILD_DIR/"Kieran Potts - Cover Letter.pdf" $BUILD_DIR/"Kieran Potts - CV.pdf" \
  AND -set-title "Kieran Potts - CV and Cover Letter" \
  -o $BUILD_DIR/"Kieran Potts - CV and Cover Letter.pdf" &> /dev/null

