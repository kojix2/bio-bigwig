# frozen_string_literal: true

require "test_helper"

class BigWigTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil Bio::BigWig::VERSION
  end

  def bwfile
    File.expand_path("fixtures/test.bw", __dir__)
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
      assert_equal([0.2000000054637591], bw.stats("1", 0, 3, nil, nil, nil))
      assert_equal([0.30000001192092896], bw.stats("1", 0, 3, nil, "max", nil))
      assert_equal([1.399999976158142, 1.5], bw.stats("1", 99, 200, 2, "max", nil))
      assert_equal([1.3351851569281683], bw.stats("1", nil, nil, nil, nil, nil))
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
end
