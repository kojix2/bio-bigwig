#include "bigwigext.h"

#define SIZEOF_INT32 4
#define SIZEOF_INT64 8

#if SIZEOF_SHORT == SIZEOF_INT32
#define NUM2UINT32 NUM2USHORT
#define NUM2INT32 NUM2SHORT
#define UINT32_2NUM USHORT2NUM
#define INT32_2NUM SHORT2NUM
#elif SIZEOF_INT == SIZEOF_INT32
#define NUM2UINT32 NUM2UINT
#define NUM2INT32 NUM2INT
#define UINT32_2NUM UINT2NUM
#define INT32_2NUM INT2NUM
#elif SIZEOF_LONG == SIZEOF_INT32
#define NUM2UINT32 NUM2ULONG
#define NUM2INT32 NUM2LONG
#define UINT32_2NUM ULONG2NUM
#define INT32_2NUM LONG2NUM
#else
#error "Neither int, long, nor short is the same size as int32_t"
#endif

#if SIZEOF_INT == SIZEOF_INT64
#define NUM2UINT64 NUM2UINT
#define NUM2INT64 NUM2INT
#define UINT64_2NUM UINT2NUM
#define INT64_2NUM INT2NUM
#elif SIZEOF_LONG == SIZEOF_INT64
#define NUM2UINT64 NUM2ULONG
#define NUM2INT64 NUM2LONG
#define UINT64_2NUM ULONG2NUM
#define INT64_2NUM LONG2NUM
#elif SIZEOF_LONGLONG == SIZEOF_INT64
#define NUM2UINT64 NUM2ULL
#define NUM2INT64 NUM2LL
#define UINT64_2NUM ULL2NUM
#define INT64_2NUM LL2NUM
#else
#error "Neither int, long, nor short is the same size as int64_t"
#endif

VALUE rb_Bio;
VALUE rb_BigWig;

static void BigWig_free(void *ptr);
static size_t BigWig_memsize(const void *ptr);

static const rb_data_type_t BigWig_type = {
    "BigWig",
    {
        0,
        BigWig_free,
        BigWig_memsize,
    },
    0,
    0,
    RUBY_TYPED_FREE_IMMEDIATELY};

static size_t BigWig_memsize(const void *ptr)
{
  const bigWigFile_t *data = ptr;

  return data ? sizeof(*data) : 0;
}

static bigWigFile_t *get_bigWigFile(VALUE obj)
{
  bigWigFile_t *data;
  TypedData_Get_Struct(obj, bigWigFile_t, &BigWig_type, data);
  return data;
}

static VALUE
bigwig_allocate(VALUE klass)
{
  bigWigFile_t *bw = NULL;

  return TypedData_Wrap_Struct(klass, &BigWig_type, bw);
}

static VALUE
bigwig_init(VALUE self, VALUE rb_fname, VALUE rb_mode)
{
  char *fname;
  char *mode = "r";
  bigWigFile_t *bw = NULL;

  fname = StringValueCStr(rb_fname);
  mode = StringValueCStr(rb_mode);

  //Open the local/remote file
  if (strchr(mode, 'w') != NULL || bwIsBigWig(fname, NULL))
  {
    bw = bwOpen(fname, NULL, mode);
  }
  else
  {
    bw = bbOpen(fname, NULL);
  }
  if (!bw)
  {
    fprintf(stderr, "[pyBwOpen] bw is NULL!\n");
    goto error;
  }
  if (!mode || !strchr(mode, 'w'))
  {
    if (!bw->cl)
      goto error;
  }

  //Set the data pointer
  DATA_PTR(self) = bw;

  rb_ivar_set(self, rb_intern("@last_tid"), INT2NUM(-1));
  rb_ivar_set(self, rb_intern("@last_type"), INT2NUM(-1));
  rb_ivar_set(self, rb_intern("@last_span"), INT2NUM(-1));
  rb_ivar_set(self, rb_intern("@last_step"), INT2NUM(-1));
  rb_ivar_set(self, rb_intern("@last_start"), INT2NUM(-1));

  return self;

error:
  if (bw)
    bwClose(bw);
  rb_raise(rb_eRuntimeError, "Received an error during file opening!");
  return Qnil;
}

void Init_bigwigext()
{
  rb_Bio = rb_define_module("Bio");
  rb_BigWig = rb_define_class_under(rb_Bio, "BigWig", rb_cObject);

  rb_define_alloc_func(rb_BigWig, bigwig_allocate);

  rb_define_private_method(rb_BigWig, "initialize_raw", bigwig_init, 2);
}
