#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

if [ $(ls $DIR | grep "\.tex$" | wc -l)==1 ]; then
  main_filename=$(basename $(ls $DIR | grep "\.tex$") .tex)
else
  main_filename="main"
fi

compile() {
  if [ $(command -v xelatex) ] && [ $(command -v bibtex) ]; then
    makeindex $main_filename.nlo -s nomencl.ist -o $main_filename.nls
    xelatex --interaction=nonstopmode $main_filename.tex
    bibtex $main_filename.aux > /dev/null 2>&1
    xelatex --interaction=nonstopmode $main_filename.tex
    xelatex --interaction=nonstopmode $main_filename.tex

    # https://tex.stackexchange.com/questions/53235/why-does-latex-bibtex-need-three-passes-to-clear-up-all-warnings

    # At the first latex run, all \cite{...} arguments are written in the file document.aux.

    # At the bibtex run, this information is taken by bibtex and the relevant entries are put into the .bbl file, sorted either alphabetically or by citation order (sometimes called "unsorted") and formatted according to the instructions provided by the bibliography style that's in use.

    # At the next run of latex, the .bbl file is included at the point the \bibliography instructions, and the correct labels for \cite{...} commands are written in .aux file.

    # Only at the last run, latex knows what the correct labels are and includes them in the document.

  else
    echo "TexLive not installed!!"
    exit 1
  fi

}

view() {
  # --------view the pdf
  if [ $(command -v evince) ]; then
    evince $main_filename.pdf &

  elif [ $(command -v okular) ]; then
    okular $main_filename.pdf

  elif [ $(command -v mupdf) ]; then
    mupdf $main_filename.pdf

  elif [ $(command -v foxitreader) ]; then
    foxitreader $main_filename.pdf

  else
    echo "Install a pdf viewer to view the document."
    exit 1
  fi

}

clear() {
  rm *aux *bbl *blg *brf *lof *log *lot *nlo *out *toc

}

while getopts cvr: opt; do
  case $opt in
    c)
      compile
      clear
      ;;
    v)
      compile
      view
      ;;
    r)
        while true
        do
            compile
            view
            clear
            sleep 30
        done
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      compile
      ;;
  esac
done

