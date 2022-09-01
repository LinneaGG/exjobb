module load bioinfo-tools
module load python
# pip install grapetree

python /domus/h1/linne/.local/lib/python3.9/site-packages/grapetree/grapetree.py -p core.aln -m NJ > treefile.txt
