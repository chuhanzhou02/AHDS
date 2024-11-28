

rule all:
    input:
         "raw/pmids.xml",
	 "clean/articles.tsv",
	 "clean/article_clean.tsv",
         "plots/Thematic_Word_Frequency_Trends_2019-2026.png",
         "plots/Word_Frequency_Trends_2019-2026.png"




rule download_data:
    output:
         "raw/pmids.xml"
    shell:
        """
        bash scripts/download_data.sh
        """

rule clean_data:
    input:
         "raw/pmids.xml"
    output:
         "clean/articles.tsv"
    shell:
        """
        bash scripts/clean_data.sh
        """

rule clean_title:
    input:
          "clean/articles.tsv"
    output:
         "clean/article_clean.tsv"
    shell:
        """
        Rscript scripts/clean_data.R
        """

rule plot:
    input:
          "clean/article_clean.tsv"
    output:
         "plots/Thematic_Word_Frequency_Trends_2019-2026.png",
         "plots/Word_Frequency_Trends_2019-2026.png"
    shell:
        """
        Rscript scripts/plot_data.R
        """


rule clean:
    "Clean"
    shell: """
    if [ -d raw ]; then
      rm -r raw
    else
      echo directory raw does not exist
    fi
    if [ -d plots ]; then
      rm -r plots
    else
      echo directory plots does not exist
    fi
    if [ -d clean ]; then
      rm -r clean
    else
      echo directory clean does not exist
    fi
    """