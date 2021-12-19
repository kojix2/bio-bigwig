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

static void
BigWig_free(void *ptr)
{
  if (ptr)
  {
    bwClose((bigWigFile_t *)ptr);
  }
}

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

//Return 1 if there are any entries at all
int hasEntries(bigWigFile_t *bw) {
    if(bw->hdr->indexOffset != 0) return 1;  // No index, no entries pyBigWig issue #111
    //if(bw->hdr->nBasesCovered > 0) return 1;  // Sometimes headers are broken
    return 0;
}

static VALUE
bigwig_init(VALUE self, VALUE rb_fname, VALUE rb_mode)
{
  char *fname;
  char *mode;
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

static VALUE
bigwig_close(VALUE self)
{
  bigWigFile_t *bw = get_bigWigFile(self);

  if (bw)
  {
    bwClose(bw);
    DATA_PTR(self) = NULL;
  }

  return Qnil;
}

static VALUE
bw_get_header(VALUE self)
{
  bigWigFile_t *bw = get_bigWigFile(self);
  VALUE rb_header;

  if (!bw)
  {
    rb_raise(rb_eRuntimeError, "The bigWig file handle is not opened!");
    return Qnil;
  }

  if (bw->isWrite == 1)
  {
    rb_raise(rb_eRuntimeError, "The header cannot be accessed in files opened for writing!");
    return Qnil;
  }

  rb_header = rb_hash_new();

  // FIXME return int or double?
  rb_hash_aset(rb_header, ID2SYM(rb_intern("version")), ULONG2NUM(bw->hdr->version));
  rb_hash_aset(rb_header, ID2SYM(rb_intern("levels")), ULONG2NUM(bw->hdr->nLevels));
  rb_hash_aset(rb_header, ID2SYM(rb_intern("bases_covered")), ULL2NUM(bw->hdr->nBasesCovered));
  rb_hash_aset(rb_header, ID2SYM(rb_intern("min_val")), INT2NUM((int)bw->hdr->minVal));
  rb_hash_aset(rb_header, ID2SYM(rb_intern("max_val")), INT2NUM((int)bw->hdr->maxVal));
  rb_hash_aset(rb_header, ID2SYM(rb_intern("sum_data")), INT2NUM((int)bw->hdr->sumData));
  rb_hash_aset(rb_header, ID2SYM(rb_intern("sum_squared")), INT2NUM((int)bw->hdr->sumSquared));

  return rb_header;

error:
  rb_raise(rb_eRuntimeError, "Received an error while getting the bigWig header!");
  return Qnil;
}

static VALUE
bw_get_chroms(int argc, VALUE *argv, VALUE self)
{
  bigWigFile_t *bw = get_bigWigFile(self);
  VALUE rb_chrom, val, ret;
  char *chrom = NULL;
  uint32_t i;

  ret = Qnil; // return nil if no chrom is found

  if (!bw)
  {
    rb_raise(rb_eRuntimeError, "The bigWig file handle is not opened!");
    return Qnil;
  }

  if (bw->isWrite == 1)
  {
    rb_raise(rb_eRuntimeError, "Chromosomes cannot be accessed in files opened for writing!");
    return Qnil;
  }

  rb_scan_args(argc, argv, "01", &rb_chrom);

  if (argc == 0)
  {
    ret = rb_hash_new();
    for (i = 0; i < bw->cl->nKeys; i++)
    {
      val = ULONG2NUM(bw->cl->len[i]);
      rb_hash_aset(ret, rb_str_new2(bw->cl->chrom[i]), val);
    }
  }
  else
  {
    chrom = StringValueCStr(rb_chrom);
    for (i = 0; i < bw->cl->nKeys; i++)
    {
      if (strcmp(bw->cl->chrom[i], chrom) == 0)
      {
        ret = ULONG2NUM(bw->cl->len[i]);
        break;
      }
    }
  }

  return ret;
}

enum bwStatsType char2enum(char *s)
{
  if (strcmp(s, "mean") == 0)
    return mean;
  if (strcmp(s, "std") == 0)
    return stdev;
  if (strcmp(s, "dev") == 0)
    return dev;
  if (strcmp(s, "max") == 0)
    return max;
  if (strcmp(s, "min") == 0)
    return min;
  if (strcmp(s, "cov") == 0)
    return cov;
  if (strcmp(s, "coverage") == 0)
    return cov;
  if (strcmp(s, "sum") == 0)
    return sum;
  return -1;
};

// double *bwStats        (bigWigFile_t *fp, char *chrom, uint32_t start, uint32_t end, uint32_t nBins, enum bwStatsType type);
// double *bwStatsFromFull(bigWigFile_t *fp, char *chrom, uint32_t start, uint32_t end, uint32_t nBins, enum bwStatsType type);

static VALUE
bw_get_stats(VALUE self, VALUE rb_chrom, VALUE rb_start, VALUE rb_end, VALUE rb_nBins, VALUE rb_type, VALUE rb_exact)
{
  bigWigFile_t *bw = get_bigWigFile(self);
  double *val;
  unsigned long startl = 0, endl = -1;
  uint32_t start, end = -1, tid;
  int nBins = 1, i;
  char *chrom = NULL, *type = "mean";
  VALUE ret;

  if (!bw)
  {
    rb_raise(rb_eRuntimeError, "The bigWig file handle is not opened!");
    return Qnil;
  }

  if (bw->isWrite == 1)
  {
    rb_raise(rb_eRuntimeError, "Statistics cannot be accessed in files opened for writing!");
    return Qnil;
  }

  if (bw->type == 1)
  {
    rb_raise(rb_eRuntimeError, "bigBed files have no statistics!");
    return Qnil;
  }

  if (rb_chrom != Qnil)
  {
    chrom = StringValueCStr(rb_chrom);
  }

  if (rb_start != Qnil)
    startl = NUM2LONG(rb_start);

  if (rb_end != Qnil)
    endl = NUM2LONG(rb_end);

  if (rb_nBins != Qnil)
    nBins = NUM2INT(rb_nBins);

  if (rb_type != Qnil)
    type = StringValueCStr(rb_type);

  if (rb_exact != Qnil)
  {
    if (NUM2INT(rb_exact) == 1)
      endl = startl + nBins - 1;
  }

  tid = bwGetTid(bw, chrom);

  if (endl == (unsigned long)-1 && tid != (uint32_t)-1)
    endl = bw->cl->len[tid];

  if (tid == (uint32_t)-1 || startl > end || endl > end)
  {
    rb_raise(rb_eRuntimeError, "Invalid interval bounds!");
    return Qnil;
  }

  start = (uint32_t)startl;
  end = (uint32_t)endl;

  if (end <= start || end > bw->cl->len[tid] || start >= end)
  {
    rb_raise(rb_eRuntimeError, "Invalid interval bounds!");
    return Qnil;
  }

  if (char2enum(type) == doesNotExist)
  {
    rb_raise(rb_eRuntimeError, "Invalid type!");
    return Qnil;
  }

  if (!hasEntries(bw))
  {
    ret = rb_ary_new2(nBins);
    for (i = 0; i < nBins; i++)
    {
      rb_ary_store(ret, i, Qnil);
    }
    return ret;
  }

  if(RTEST(rb_exact))
  {
    val = bwStatsFromFull(bw, chrom, start, end, nBins, char2enum(type));
  }
  else
  {
    val = bwStats(bw, chrom, start, end, nBins, char2enum(type));
  }

  if(!val)
  {
    rb_raise(rb_eRuntimeError, "Error getting statistics!An error was encountered while fetching statistics.");
    return Qnil;
  }

  ret = rb_ary_new2(nBins);
  for (i = 0; i < nBins; i++)
  {
    if(isnan(val[i])) {
      rb_ary_store(ret, i, Qnil);
    } else {
      rb_ary_store(ret, i, rb_float_new(val[i]));
    }
  }
  free(val);

  return ret;
}

void Init_bigwigext()
{
  rb_Bio = rb_define_module("Bio");
  rb_BigWig = rb_define_class_under(rb_Bio, "BigWig", rb_cObject);

  rb_define_alloc_func(rb_BigWig, bigwig_allocate);

  rb_define_private_method(rb_BigWig, "initialize_raw", bigwig_init, 2);
  rb_define_method(rb_BigWig, "close", bigwig_close, 0);
  rb_define_method(rb_BigWig, "header", bw_get_header, 0);
  rb_define_method(rb_BigWig, "chroms", bw_get_chroms, -1);
  rb_define_method(rb_BigWig, "stats", bw_get_stats, 6);
}