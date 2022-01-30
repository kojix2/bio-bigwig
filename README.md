# bio-bigwig

Ruby wrapper to [libBigWig](https://github.com/dpryan79/libBigWig) compatible with [pyBigWig](https://github.com/deeptools/pyBigWig).

* Currently, curl does not seem to work well.
* File writing is not implemented.

## Installation

Installation from source.

```
git clone --recursive https://github.com/kojix2/bio-bigwig
cd bio-bigwig
bundle install
bundle exec rake compile
bundle exec rake install
```

Not yet uploaded to the Gem server.

```
gem install bio-bigwig
```

## Usage

```ruby
require "bio/bigwig"

bw = Bio::BigWig.open("test/fixtures/test.bw")
bw.is_bigwig?

bw.chroms
# {"1"=>195471971, "10"=>130694993}

bw.chroms("1")
# 195471971

bw.header
# {
#           :version => 4,       the version number                        
#            :levels => 1,       the number of zoom levels                       
#     :bases_covered => 154,     the number of bases described                        
#           :min_val => 0,       the minimum value                       
#           :max_val => 2,       the maximum value                        
#          :sum_data => 272,     the sum of all values                        
#       :sum_squared => 500      the sum of all squared values                        
# }


bw.stats("1", 0, 3)
# [0.2000000054637591]

bw.stats("1", 0, 3, type: :max)
# [0.30000001192092896]

bw.values("1", 0, 3)
# [0.10000000149011612, 0.20000000298023224, 0.30000001192092896]

bw.values("1", 0, 4)
# [0.10000000149011612, 0.20000000298023224, 0.30000001192092896, NaN]

bw.intervals("1", 0, 3)
# [[0, 1, 0.10000000149011612], [1, 2, 0.20000000298023224], [2, 3, 0.30000001192092896]]

bw.intervals("1")
[[0, 1, 0.10000000149011612], [1, 2, 0.20000000298023224], [2, 3, 0.30000001192092896], [100, 150, 1.399999976158142], [150, 151, 1.5]]
```

## Development

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/bio-bigwig.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
