# frozen_string_literal: true

require "test_helper"

class BigWigTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil Bio::BigWig::VERSION
  end

  def fname
    File.expand_path("fixtures/test.bw", __dir__)
  end

  def test_open
    bw = Bio::BigWig.new(fname)
    assert_equal Bio::BigWig, bw.class
    bw.close
  end

  def test_header
    bw = Bio::BigWig.new(fname)
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
end
