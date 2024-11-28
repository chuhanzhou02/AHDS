#!/bin/bash

mkdir -p "$HOME/AHDS_project/raw"
echo "Downloading PubMed IDs..."

curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%22long%20covid%22&retmax=10" > "$HOME/AHDS_project/raw/pmids.xml"
echo "PubMed IDs downloaded to $HOME/AHDS_project/raw/pmids.xml."

echo "Downloading article metadata..."

for pmid in $(grep -oP '<Id>\K[0-9]+' "$HOME/AHDS_project/raw/pmids.xml"); do
    file_path="$HOME/AHDS_project/raw/article-data-${pmid}.xml"

    if [ -f "$file_path" ]; then
        echo "File already exists: article-data-${pmid}.xml, skipping..."
        continue
    fi

    echo "Downloading: article-data-${pmid}.xml"
    curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=${pmid}" > "$file_path"
    sleep 1
done

echo "All articles downloaded."

