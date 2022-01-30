# frozen_string_literal: true

require "test_helper"

class BigWigTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil Bio::BigWig::VERSION
  end

  def bwfile
    File.expand_path("fixtures/test.bw", __dir__)
  end

  def bbfile
    File.expand_path("fixtures/test.bigBed", __dir__)
  end

  def bwurl
    "https://raw.githubusercontent.com/dpryan79/pyBigWig/master/pyBigWigTest/test.bw"
  end

  def bedfile
    File.expand_path("fixtures/test.bigBed", __dir__)
  end

  def test_open
    bw = Bio::BigWig.new(bwfile)
    assert_equal Bio::BigWig, bw.class
    bw.close
  end

  def test_file_type
    Bio::BigWig.open(bwfile) do |bw|
      assert_equal "BigWig", bw.file_type
      assert_equal true, bw.is_bigwig?
      assert_equal false, bw.is_bigbed?
    end
    Bio::BigWig.open(bbfile) do |bb|
      assert_equal "BigBed", bb.file_type
      assert_equal false, bb.is_bigwig?
      assert_equal true, bb.is_bigbed?
    end
  end

  def test_header
    bw = Bio::BigWig.new(bwfile)
    assert_equal(
      {
        version: 4,
        levels: 1,
        bases_covered: 154,
        min_val: 0,
        max_val: 2,
        sum_data: 272,
        sum_squared: 500
      },
      bw.header
    )
    bw.close
  end

  %i[bwfile].each do |fname|
    define_method("test_chroms_#{fname}") do
      bw = Bio::BigWig.new(public_send(fname))
      assert_equal({ "1" => 195_471_971, "10" => 130_694_993 }, bw.chroms)
      assert_equal(195_471_971, bw.chroms("1"))
      assert_equal(130_694_993, bw.chroms("10"))
      assert_nil bw.chroms("11")
      bw.close
    end

    define_method("test_stats_#{fname}") do
      bw = Bio::BigWig.new(public_send(fname))
      assert_equal([0.2000000054637591], bw.stats("1", 0, 3))
      assert_equal([0.30000001192092896], bw.stats("1", 0, 3, type: "max"))
      assert_equal([1.399999976158142, 1.5], bw.stats("1", 99, 200, type: "max", nbins: 2))
      assert_equal([1.3351851569281683], bw.stats("1"))
      assert_equal([0.03], bw.stats("1", 0, 100, type: "coverage"))
      o = bw.stats("1", 0, 2, nbins: 4)
      assert_equal([0.10000000149011612, 0.20000000298023224], o.values_at(1, 3))
      assert_equal(true, o.values_at(0, 2).all?(&:nan?))
      bw.close
    end

    define_method("test_sum_#{fname}") do
      bw = Bio::BigWig.new(public_send(fname))
      assert([35.0, 36.5], bw.stats("1", 100, 151, type: "sum", nbins: 2))
      bw.close
    end

    define_method("test_values_#{fname}") do
      bw = Bio::BigWig.new(public_send(fname))
      assert_equal(
        [0.10000000149011612, 0.20000000298023224, 0.30000001192092896],
        bw.values("1", 0, 3)
      )
      # assert_equal([0.10000000149011612, 0.20000000298023224, 0.30000001192092896], bw.values("1", np.int64(0), np.int64(3))
      r = bw.values("1", 0, 4)
      assert_equal(
        [0.10000000149011612, 0.20000000298023224, 0.30000001192092896],
        r[0..2]
      )
      assert_equal(true, r[3].nan?)
      assert_raises(ArgumentError) { bw.values("1") }
      bw.close
    end

    define_method("test_intervals_#{fname}") do
      bw = Bio::BigWig.new(public_send(fname))
      assert_equal(
        [[0, 1, 0.10000000149011612], [1, 2, 0.20000000298023224], [2, 3, 0.30000001192092896]],
        bw.intervals("1", 0, 3)
      )
      assert_equal(
        [[0, 1, 0.10000000149011612], [1, 2, 0.20000000298023224], [2, 3, 0.30000001192092896],
         [100, 150, 1.399999976158142], [150, 151, 1.5]],
        bw.intervals("1")
      )
      bw.close
    end
  end

  def test_bb_entry
    bb = Bio::BigWig.new(bbfile)
    o = bb.entries("chr1", 10_000_000, 10_020_000)
    expected = [[10_009_333, 10_009_640, "61035\t130\t-\t0.026\t0.42\t404"],
                [10_014_007, 10_014_289, "61047\t136\t-\t0.029\t0.42\t404"],
                [10_014_373, 10_024_307, "61048\t630\t-\t5.420\t0.00\t2672399"]]
    assert_equal expected, o
    o = bb.entries("chr1", 10_000_000, 10_020_000, text: false)
    expected = [[10_009_333, 10_009_640],
                [10_014_007, 10_014_289],
                [10_014_373, 10_024_307]]
    assert_equal expected, o
    bb.close
  end

  def test_bb_sql
    expected = <<~SQL
      table RnaElements#{" "}
      "BED6 + 3 scores for RNA Elements data "
          (
          string chrom;      "Reference sequence chromosome or scaffold"
          uint   chromStart; "Start position in chromosome"
          uint   chromEnd;   "End position in chromosome"
          string name;       "Name of item"
          uint   score;      "Normalized score from 0-1000"
          char[1] strand;    "+ or - or . for unknown"
          float level;       "Expression level such as RPKM or FPKM. Set to -1 for no data."
          float signif;      "Statistical significance such as IDR. Set to -1 for no data."
          uint score2;       "Additional measurement/count e.g. number of reads. Set to 0 for no data."
          )
    SQL
    bb = Bio::BigWig.open(bbfile)
    assert_equal(expected, bb.sql)
    bb.close
    bw = Bio::BigWig.open(bwfile)
    assert_raises { bb.sql }
    bw.close
  end
end
