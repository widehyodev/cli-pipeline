~/gitclone/cli-pipeline $ make 6_parse_html_sequential 
bash /home/widehyo/gitclone/cli-pipeline/shell/6_parse_html_sequential.sh
Parsing HTML...
[SEQUENTIAL] Parsing HTML...
Time taken: 74968 milliseconds

~/gitclone/cli-pipeline $ make 6_parse_html_xargs 
bash /home/widehyo/gitclone/cli-pipeline/shell/6_parse_html_xargs.sh
Parsing HTML...
[XARGS] Parsing HTML...
Extracting content from html file
Time taken: 33023 milliseconds

~/gitclone/cli-pipeline $ make 6_parse_html_parallel 
bash /home/widehyo/gitclone/cli-pipeline/shell/6_parse_html_parallel.sh
Parsing HTML...
[PARALLEL] Parsing HTML...
Extracting content from html file
Time taken: 258315 milliseconds
Parsing HTML done

~/gitclone/cli-pipeline $ !!
bash util/split_dir.sh --directory data/html/ --dest data/split/sp_128 --line 128 --prefix sp_128
directory: /home/widehyo/gitclone/cli-pipeline/data/html, prefix: sp_128, dest: /home/widehyo/gitclone/cli-pipeline/data/split/sp_128, line: 128
~/gitclone/cli-pipeline $ bash util/split_dir.sh --directory data/html/ --dest data/split/sp_1024 --line 1024 --prefix sp_1024
directory: /home/widehyo/gitclone/cli-pipeline/data/html, prefix: sp_1024, dest: /home/widehyo/gitclone/cli-pipeline/data/split/sp_1024, line: 1024

~/gitclone/cli-pipeline $ du -s data/parallel_parsed/
147784  data/parallel_parsed/
~/gitclone/cli-pipeline $ du -s data/xargs_parsed/
147780  data/xargs_parsed/
~/gitclone/cli-pipeline $ du -s data/sequential_parsed/
147780  data/sequential_parsed/


~/gitclone/cli-pipeline $ wc data/sequential_parsed/* | sort -k1,4 -nr > sequential_wc.txt
~/gitclone/cli-pipeline $ wc data/parallel_parsed/* | sort -k1,4 -nr > parallel_wc.txt
~/gitclone/cli-pipeline $ wc data/xargs_parsed/* | sort -k1,4 -nr > xargs_wc.txt

~/gitclone/cli-pipeline $ difft note/parallel_wc_work.txt note/xargs_wc_work.txt 
~/gitclone/cli-pipeline $ difft note/parallel_wc_work.txt note/sequential_wc_work.txt 

~/gitclone/cli-pipeline $ make 8_convert_html_xargs_lynx 
bash /home/widehyo/gitclone/cli-pipeline/shell/8_convert_html_xargs_lynx.sh
Converting html to markdown using xargs and lynx...
[xargs, lynx] Converting html to csv file...
[xargs, lynx] Time taken: 733404 milliseconds
/home/widehyo/gitclone/cli-pipeline/data/parsed/xargs_lynx_out.csv done

~/gitclone/cli-pipeline $ make 8_convert_html_xargs_lynx 
bash /home/widehyo/gitclone/cli-pipeline/shell/8_convert_html_xargs_lynx.sh
Converting html to markdown using xargs and lynx...
[xargs, lynx] Converting html to csv file...

[xargs, lynx] Time taken: 1646657 milliseconds
/home/widehyo/gitclone/cli-pipeline/data/parsed/xargs_lynx_out.csv done

~/gitclone/cli-pipeline $ make 8_convert_html_seq_lynx 
bash /home/widehyo/gitclone/cli-pipeline/shell/8_convert_html_seq_lynx.sh
Converting html to markdown using seq and lynx...
[seq, lynx] Converting html to csv file...
[seq, lynx] Time taken: 1716947 milliseconds
/home/widehyo/gitclone/cli-pipeline/data/parsed/seq_lynx_out.csv done

~/gitclone/cli-pipeline $ make 8_convert_html_xargs_lynx 
bash /home/widehyo/gitclone/cli-pipeline/shell/8_convert_html_xargs_lynx.sh
Converting html to markdown using xargs and lynx...
Checking filesystem type for /tmpfs...
✓ TMPFS detected: /tmpfs is mounted as tmpfs
  Size:   1G, Available:    1G
[xargs, lynx] Converting html to csv file...
reducing csv files...
compressing csv files...
tar: Removing leading `/' from member names
tar: Removing leading `/' from hard link targets
[xargs, lynx] Time taken: 619517 milliseconds
/home/widehyo/gitclone/cli-pipeline/data/result/xargs_lynx_out.csv done
Cleaning up temp files...


