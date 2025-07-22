# bio-bigwig

[![Gem Version](https://img.shields.io/gem/v/bio-bigwig?color=brightgreen)](https://rubygems.org/gems/bio-bigwig)
[![test](https://github.com/kojix2/bio-bigwig/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/bio-bigwig/actions/workflows/ci.yml)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/bio-bigwig)
[![DOI](https://zenodo.org/badge/438516085.svg)](https://doi.org/10.5281/zenodo.13860901)

Ruby wrapper to [libBigWig](https://github.com/dpryan79/libBigWig) compatible with [pyBigWig](https://github.com/deeptools/pyBigWig).

* Supports both local and remote file access via HTTP/HTTPS.
* File writing is not implemented.

## Installation

```
gem install bio-bigwig
```

## Usage

[bigWig Track Format](https://genome.ucsc.edu/goldenPath/help/bigWig.html)

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

# types
# mean         - the average value (default)
# min          - the minimum value
# max          - the maximum value
# cov/coverage - the fraction of bases covered
# std          - the standard deviation of the values
# dev          - 
# sum          - 

bw.stats("1",99, 200, type: :max, nbins: 2)
# [1.399999976158142, 1.5]

bw.stats("1")
# [1.3351851569281683]

bw.values("1", 0, 3)
# [0.10000000149011612, 0.20000000298023224, 0.30000001192092896]

bw.values("1", 0, 4)
# [0.10000000149011612, 0.20000000298023224, 0.30000001192092896, NaN]

bw.intervals("1", 0, 3)
# [[0, 1, 0.10000000149011612], [1, 2, 0.20000000298023224], [2, 3, 0.30000001192092896]]

bw.intervals("1")
# [[0, 1, 0.10000000149011612], [1, 2, 0.20000000298023224], [2, 3, 0.30000001192092896],
# [100, 150, 1.399999976158142], [150, 151, 1.5]]
```

[bigBed Track Format](https://genome.ucsc.edu/goldenPath/help/bigBed.html)

```ruby
require "bio/bigwig"

bb = Bio::BigWig.open("test/fixtures/test.bigBed")

bb.entries("chr1", 10000000, 10020000) 
# [[10009333, 10009640, "61035\t130\t-\t0.026\t0.42\t404"],                  
#  [10014007, 10014289, "61047\t136\t-\t0.029\t0.42\t404"],                  
#  [10014373, 10024307, "61048\t630\t-\t5.420\t0.00\t2672399"]]   

bb = Bio::BigWig.open("test/fixtures/test.bigBed")
bb.entries("chr1", 10000000, 10020000, with_string: false) 
# [[10009333, 10009640],                  
#  [10014007, 10014289],                  
#  [10014373, 10024307]] 

bb.sql
# table RnaElements 
# "BED6 + 3 scores for RNA Elements data "                                   
#     (                                                                      
#     string chrom;      "Reference sequence chromosome or scaffold"         
#     uint   chromStart; "Start position in chromosome"                      
#     uint   chromEnd;   "End position in chromosome"                        
#     string name;       "Name of item"                                      
#     uint   score;      "Normalized score from 0-1000"
#     char[1] strand;    "+ or - or . for unknown"
#     float level;       "Expression level such as RPKM or FPKM. Set to -1 for no data."
#     float signif;      "Statistical significance such as IDR. Set to -1 for no data."
#     uint score2;       "Additional measurement/count e.g. number of reads. Set to 0 for no data."
#     )
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/kojix2/bio-bigwig>.

## Development

Pull requests are welcome!

    Do you need commit rights to my repository?
    Do you want to get admin rights and take over the project?
    If so, please feel free to contact us @kojix2.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
