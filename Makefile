include .env
export
.PHONY: 0_install_tools 1_fetch_sitemap 2_parse_sitemap 3_make_topic_csv 4_fetch_html 5_treat_too_many_request 6_parse_html_parallel 6_parse_html_sequential 6_parse_html_xargs 7_compress_html 8_convert_html_xargs_lynx 8_convert_html_seq_lynx 9_clean_csv 10_init_db 11_bulk_insert

0_install_tools:
	bash ${SHELL_DIR}/0_install_tools.sh

1_fetch_sitemap:
	bash ${SHELL_DIR}/1_fetch_sitemap.sh

2_parse_sitemap:
	bash ${SHELL_DIR}/2_parse_sitemap.sh

3_make_topic_csv:
	bash ${SHELL_DIR}/3_make_topic_csv.sh

4_fetch_html:
	bash ${SHELL_DIR}/4_fetch_html.sh

5_treat_too_many_request:
	bash ${SHELL_DIR}/5_treat_too_many_request.sh

6_parse_html_parallel:
	bash ${SHELL_DIR}/6_parse_html_parallel.sh

6_parse_html_sequential:
	bash ${SHELL_DIR}/6_parse_html_sequential.sh

6_parse_html_xargs:
	bash ${SHELL_DIR}/6_parse_html_xargs.sh

7_compress_html:
	bash ${SHELL_DIR}/7_compress_html.sh

8_convert_html_xargs_lynx:
	bash ${SHELL_DIR}/8_convert_html_xargs_lynx.sh

8_convert_html_seq_lynx:
	bash ${SHELL_DIR}/8_convert_html_seq_lynx.sh

9_clean_csv:
	bash ${SHELL_DIR}/9_clean_csv.sh

10_init_db:
	bash ${SHELL_DIR}/10_init_db.sh

11_bulk_insert:
	bash ${SHELL_DIR}/11_bulk_insert.sh