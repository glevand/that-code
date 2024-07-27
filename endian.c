/*
 * Print out the endianness and the direction of stack growth.
 */

#define _GNU_SOURCE
#define _ISOC99_SOURCE

#include <assert.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>

static const char program_name[] = "endian";

enum opt_value {opt_undef = 0, opt_yes, opt_no};

struct opts {
	enum opt_value help;
};

static void print_usage(void)
{

	fprintf(stderr,
"%s - Print out the endianness and the direction of stack growth.\n"
"Usage: %s [flags]\n"
"Option flags:\n"
"  -h --help         - Show this help and exit.\n",
		program_name, program_name
	);
}

static int opts_parse(struct opts *opts, int argc, char *argv[])
{
	static const struct option long_options[] = {
		{"help",           no_argument, NULL, 'h'},
		{ NULL,            0,           NULL, 0},
	};
	static const char short_options[] = "h";

	*opts = (struct opts){
		.help = opt_no,
	};

	int option_index = 0;		
	while (1) {
		int c = getopt_long(argc, argv, short_options, long_options,
			&option_index);

		if (c == EOF) {
// 			fprintf(stderr, "got EOF\n");
			break;
		}

		switch (c) {
		case 'h':
			opts->help = opt_yes;
			break;
		default:
			assert(0);
			opts->help = opt_yes;
			return -1;
		}
	}

	return 0;
}
static const char *endian(void) 
{
	static unsigned int a = 0x12;
	static unsigned char* p = (unsigned char*)&a;

	return (*p == 0x12) ? "Little" : "Big";
}

static const char *stack_helper(int *pa)
{
	int b = 100;
	int *pb = &b;

	return (pa < pb) ? "down" : "up";
}

static const char *stack_direction(void)
{
	int a = 100;

	return stack_helper(&a);
}

int main(int argc, char *argv[])
{
	struct opts opts;
	const char *e_result;
	const char *s_result;

	if (opts_parse(&opts, argc, argv)) {
		print_usage();
		return EXIT_FAILURE;
	}

	if (opts.help == opt_yes) {
		print_usage();
		return EXIT_SUCCESS;
	}

	e_result = endian();
	s_result = stack_direction();
	
	printf("== %s endian, stack grows %s ==\n", e_result, s_result);
}
