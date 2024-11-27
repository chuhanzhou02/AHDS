#!/bin/bash

mkdir -p ~/AHDS_project/raw
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%22long%20covid%22&retmax=10" > ~/AHDS_project/raw/pmids.xml

for pmid in $(cat ~/AHDS_project/raw/pmids.xml | grep -oP '<Id>\K[0-9]+'); do
    if [ ! -f "~/AHDS_project/raw/article-data-${pmid}.xml" ]; then
        curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=${pmid}" > ~/AHDS_project/raw/article-data-${pmid}.xml
        sleep 1
    fi
done
echo "Data download completed."

mkdir -p ~/AHDS_project/clean

for file in ~/AHDS_project/raw/article-data-*.xml; do
    pmid=$(basename "$file" .xml | grep -oP '\d+')
    year=$(grep -oP '<PubDate>.*?<Year>\K\d+' "$file" | head -n 1)
    title=$(grep -oP '(?<=<ArticleTitle>|<BookTitle>).*?(?=</ArticleTitle>|</BookTitle>)' "$file" | sed 's/<[^>]*>//g')

    if [ -z "$title" ]; then
        title="N/A"
    fi

    echo -e "$pmid\t$year\t$title" >> ~/AHDS_project/clean/articles.tsv
done

for file in ~/AHDS_project/raw/article-data-*.xml; do
    pmid=$(basename "$file" .xml | grep -oP '\d+')
    if ! grep -q "$pmid" ~/AHDS_project/clean/articles.tsv; then
        echo "$file" >> ~/AHDS_project/clean/missing_files.txt
    fi
done

echo "Data cleaning completed. Check '~/AHDS_project/clean/articles.tsv' and '~/AHDS_project/clean/missing_files.txt' for results."
