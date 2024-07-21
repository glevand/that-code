/*
 * Given a string, remove the chars having multiple instances.
 */

#define _GNU_SOURCE
#define _ISOC99_SOURCE

#include <assert.h>
#include <errno.h>
#include <getopt.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

static const char program_name[] = "delete-chars";

enum opt_value {opt_undef = 0, opt_yes, opt_no};

struct opts {
	enum opt_value run_tests;
	enum opt_value help;
};

static void print_usage(const struct opts *opts)
{
	fprintf(stderr,
	"%s - Delete the chars having multiple instances.\n"
	"Usage: %s [flags] input-string\n"
	"Option flags:\n"
	"  -t --run_tests    - run_tests. Default: '%s'.\n"
	"  -h --help         - Show this help and exit.\n",
		program_name, program_name,
		(opts->run_tests ? "yes" : "no")
	);
}

static int opts_parse(struct opts *opts, int argc, char *argv[], char **input_string)
{
	static const struct option long_options[] = {
		{"run_tests",      no_argument, NULL, 't'},
		{"help",           no_argument, NULL, 'h'},
		{ NULL,            0,           NULL, 0},
	};
	static const char short_options[] = "th";

	*opts = (struct opts){
		.run_tests = opt_no,
		.help = opt_no,
	};

	if (0) {
		int i;

// 		fprintf(stderr, "argc = %d\n", argc);
// 		fprintf(stderr, "optind = %d\n", optind);

		for (i = 0; i < argc; i++) {
			fprintf(stderr, "  %d: %p = '%s'\n", i, &argv[i], argv[i]);
		}

// 		if (optind) {
// 			fprintf(stderr, "got optind: '%s'\n", argv[optind]);
// 		}
	}

	int option_index = 0;		
	while (1) {
		int c = getopt_long(argc, argv, short_options, long_options,
			&option_index);

		if (c == EOF) {
// 			fprintf(stderr, "got EOF\n");
			break;
		}

// 		if (0) {
// 			fprintf(stderr, "%c => '%s'\n", c, optarg);
// 		}

		switch (c) {
		case 't':
			opts->run_tests = opt_yes;
			break;
		case 'h':
			opts->help = opt_yes;
			break;
		default:
			assert(0);
			opts->help = opt_yes;
			return -1;
		}
	}

	if (optind < argc) {
		strcpy(*input_string, argv[optind]);
// 		printf ("non-option ARGV-elements: ");
// 		while (optind < argc)
// 			printf ("%s ", argv[optind++]);
// 		putchar ('\n');
	}

	return 0;
}

static int delete_chars(const char *str, char **output_string)
{
	const unsigned int str_len = strlen(str);
	const unsigned int out_len = strlen(str) + 1;
	char dupes[str_len];
	unsigned int str_i;
	unsigned int str_j;
	unsigned int dupes_i;
	unsigned int output_i;

	fprintf(stderr, "str = '%s'\n", str);
// 	fprintf(stderr, "out_len = %d\n", out_len);

	memset(dupes, 0, str_len);

	*output_string = malloc(out_len);

	if (!*output_string) {
		fprintf(stderr, "malloc output_string failed\n");
		return -1;
	}

	memset(*output_string, 0, out_len);

	dupes_i = 0;
	for (str_i = 0; str_i < str_len; str_i++) {
// 		fprintf(stderr, "str[%d] = %c\n", str_i, str[str_i]);
		for (str_j = str_i + 1; str_j < str_len; str_j++) {
			if (str[str_i] == str[str_j]) {
				fprintf(stderr, "dupe [%d, %d] = %c\n", str_i, str_j, str[str_j]);
				dupes[dupes_i] = str[str_i];
				dupes_i++;
				goto next_str;
			}
		}
next_str:
	}

	output_i = 0;
	for (str_i = 0; str_i < str_len; str_i++) {
		for (dupes_i = 0; dupes_i < str_len; dupes_i++) {
			if (str[str_i] == dupes[dupes_i]) {
				fprintf(stderr, "skip [%d, %d] = %c\n", str_i, dupes_i, str[str_i]);
				goto skip;
			}
		}
		fprintf(stderr, "add str[%d] = %c @ %d\n", str_i, str[str_i], output_i);
// 		fprintf(stderr, "output_i = %d\n", output_i);
// 		fprintf(stderr, "output_string = %p\n", &(*output_string)[output_i]);
		(*output_string)[output_i] = str[str_i];
		output_i++;
skip:
	}

	return 0;
}

static int run_tests(void)
{
	char *output_string = 0;
	char *test_1 = "abcde";
	char *expected_1 = "abcde";
	char *test_2 = "aaabc";
	char *expected_2 = "bc";
	char *test_3 = "aabbc";
	char *expected_3 = "c";
	char *test_4 = "bacdec1-ehsvrkjtkjntrjytcft453464536^%&^*^UUJG(FDGyt547y32!@#$%^&*()_eitfg";
	char *expected_4 = "bad1-hsvnJFD72!@#$)_ig";
	int result;

	result = delete_chars(test_1, &output_string);
	fprintf(stderr, "---- test_1: result = '%s', expected result = '%s' ----\n", output_string, expected_1);
	if (result) {
		return result;
	}

	result = delete_chars(test_2, &output_string);
	fprintf(stderr, "---- test_2: result = '%s', expected result = '%s' ----\n", output_string, expected_2);
	if (result) {
		return result;
	}

	result = delete_chars(test_3, &output_string);
	fprintf(stderr, "---- test_3: result = '%s', expected result = '%s' ----\n", output_string, expected_3);
	if (result) {
		return result;
	}

	result = delete_chars(test_4, &output_string);
	fprintf(stderr, "---- test_4: result = '%s', expected result = '%s' ----\n", output_string, expected_4);
	if (result) {
		return result;
	}

	return 0;
}

int main(int argc, char *argv[])
{
	char *input_string;
	char *output_string;
	struct opts opts;
	int result;

	input_string = malloc(256);
	memset(input_string, 0, 256);

	if (opts_parse(&opts, argc, argv, &input_string)) {
		print_usage(&opts);
		return EXIT_FAILURE;
	}

	if (opts.help == opt_yes) {
		print_usage(&opts);
		return EXIT_SUCCESS;
	}

	if (opts.run_tests == opt_yes) {
// 		fprintf(stderr, "opts.run_tests\n");
		result = run_tests();
		return result;
	}

	result = delete_chars(input_string, &output_string);

	fprintf(stderr, "input_string  = '%s'\n", input_string);
	fprintf(stderr, "output_string = '%s'\n", output_string);

	return result ? EXIT_FAILURE : EXIT_SUCCESS;
}

