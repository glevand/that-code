/*
 * Implementation of a ring-buffer.
 */

#define _GNU_SOURCE
#define _ISOC99_SOURCE

#include <assert.h>
#include <getopt.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef min
# define min(a,b) (((a) < (b)) ? (a) : (b))
#endif

enum opt_value {opt_undef = 0, opt_yes, opt_no};

struct opts {
	enum opt_value help;
};

static void print_usage(void)
{
	fprintf(stderr,
		"ring-buffer - Implementation of a ring-buffer.\n"
		"Usage:ring-buffer [flags]\n"
		"Option flags:\n"
		"  -h --help         - Show this help and exit.\n"
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

static void print_buffer(const int *buffer, unsigned int cnt)
{
	unsigned int i;

	printf("buffer[%d] = ", cnt);
	for (i = 0; i < cnt; i++)
	{
		printf("%d ", buffer[i]);
	}
	printf("\n");
}

struct ring_buffer {
	unsigned int len;
	unsigned int cnt;
	int buf[];
};

static struct ring_buffer *ring_buffer_init(unsigned int len)
{
	struct ring_buffer *r = malloc(sizeof(*r)
		+ len * sizeof(r->buf[0]));

	if (!r) {
		fprintf(stderr, "NO MEMORY\n");
		assert(0);
		return NULL;
	}

	r->len = len;
	r->cnt = 0; 

	return r;
}

static void ring_buffer_print(const struct ring_buffer *r)
{
	unsigned int i;

	printf("ring_buffer[%d] = ", r->len);
	for (i = 0; i < r->len; i++) {
		printf("%d ", r->buf[i]);
	}
	printf(": len=%d cnt=%d\n", r->len, r->cnt);
}

static int ring_buffer_put(struct ring_buffer *r, const int *buffer,
	unsigned int cnt)
{
	unsigned int c1 = 0;

	printf("\n%s: cnt=%d\n", __func__, cnt);
	ring_buffer_print(r);
	print_buffer(buffer, cnt);

	if (r->cnt == r->len) {
		printf("%s: buffer full\n", __func__);
		return 0;
	}

	c1 = min(cnt, r->len - r->cnt);
	printf("%s:%d: c1=%d\n", __func__, __LINE__, c1);

	memcpy(r->buf + r->cnt, buffer, c1 * sizeof(*r->buf));
	r->cnt += c1;

	ring_buffer_print(r);
	return c1;
}

static int ring_buffer_get(struct ring_buffer *r, int *buffer,
	unsigned int cnt)
{
	unsigned int c1;

	printf("\n%s: cnt=%d\n", __func__, cnt);
	ring_buffer_print(r);

	c1 = min(cnt, r->cnt);
	printf("%s:%d: c1=%d\n", __func__, __LINE__, c1);

	r->cnt -= c1;
	memcpy(buffer, r->buf, c1 * sizeof(*r->buf));
	print_buffer(buffer, c1);

	memcpy(r->buf, r->buf + c1, (r->len - c1) * sizeof(*r->buf));

	memset(r->buf + r->cnt, 0, (r->len - r->cnt) * sizeof(*r->buf));

	ring_buffer_print(r);
	return c1;
}

static void run_tests(void)
{
	static const int data1[] = {1,2,3,4,5,6,7,8,9,10,11,12};
	static const int data2[] = {-1,-2,-3,-4};
	static const int data3[] = {9,8,7,6};
	static const int data4[] = {};
	struct ring_buffer *r;
	int buf[128]; 
	int result;

	r = ring_buffer_init(10);

	result = ring_buffer_get(r, buf, 2);
	printf("result=%d\n", result);

	result = ring_buffer_put(r, data1, sizeof(data1) / sizeof(data1[0]));
	printf("result=%d\n", result);

	result = ring_buffer_get(r, buf, 2);
	printf("result=%d\n", result);

	result = ring_buffer_put(r, data4, sizeof(data4) / sizeof(data4[0]));
	printf("result=%d\n", result);

	result = ring_buffer_put(r, data2, sizeof(data2) / sizeof(data2[0]));
	printf("result=%d\n", result);

	result = ring_buffer_put(r, data3, sizeof(data3) / sizeof(data3[0]));
	printf("result=%d\n", result);

	result = ring_buffer_get(r, buf, 1);
	printf("result=%d\n", result);

	result = ring_buffer_put(r, data1, sizeof(data1) / sizeof(data1[0]));
	printf("result=%d\n", result);

	result = ring_buffer_get(r, buf, 5);
	printf("result=%d\n", result);

	result = ring_buffer_get(r, buf, 0);
	printf("result=%d\n", result);

	result = ring_buffer_get(r, buf, 10);
	printf("result=%d\n", result);

	result = ring_buffer_put(r, data2, sizeof(data2) / sizeof(data2[0]));
	printf("result=%d\n", result);
}

int main(int argc, char *argv[])
{
	struct opts opts;

	if (opts_parse(&opts, argc, argv)) {
		print_usage();
		return EXIT_FAILURE;
	}

	if (opts.help == opt_yes) {
		print_usage();
		return EXIT_SUCCESS;
	}

	run_tests();

	return EXIT_SUCCESS;
}

