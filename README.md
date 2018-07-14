# VIC Cipher

[![Build Status](https://travis-ci.org/FLCN17/Nihilist.jl.svg?branch=master)](https://travis-ci.org/FLCN17/Nihilist.jl)

[![Coverage Status](https://coveralls.io/repos/FLCN17/Nihilist.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/FLCN17/Nihilist.jl?branch=master)

[![codecov.io](http://codecov.io/github/FLCN17/Nihilist.jl/coverage.svg?branch=master)](http://codecov.io/github/FLCN17/Nihilist.jl?branch=master)


## Usage:

This cipher works by encoding plaintext letters into one or a pair of digits according to a straddling checkerboard chart.

The message can further be added to a 'keysteam' of digits. Historically, these were taken from statistical almanacs, and the page/section given as a special group buried in the output.

## Chart:

```julia
chart = Nihilist.chart_maker()
```

Creates a DataFrame containing the generated chart. Can pass a file location to load from, or a file location to save to.

```julia
chart = Nihilist.chart_maker(file_out="/src/chart.csv")
```

```julia
loaded_chart = Nihilist.chart_maker(file_loc="/src/chart.csv")
```

## Encoding:

Takes a number of arguments and returns the decoded text, with options for file input/output as above.

```julia
cleartext="The Nihilist cipher was used extensively by the Soviets during and after the war in the 40s."
```

```julia
ciphertext = Nihilist.encode(cleartext, chart)
```

Produces:

> 07558 67564 46107 96407 55347 91461 57757 60581
> 67054 44142 41075 51270 65017 74636 84398 77974
> 05307 55479 36807 55484 44480 00145 74979 39632

```julia
ciphertext = Nihilist.encode(cleartext, "/src/chart.csv", spacing_enable=false, num_repeat=4, file_out="output.txt")
```

Produces:

>0755867564461079640755347914615775760581
>6705444142410755127065017746368439877974
>0530755479368075548444448000014574979396

## Decoding:

Simpler then encoding; returns the decoded text, with same options for file input/output as above.

```julia
plaintext = Nihilist.decode(ciphertext, chart)
```

```julia
plaintext = Nihilist.decode("output.txt", "/src/chart.csv", num_repeat=4, file_out="clearoutput.txt")
```

Produces:

> thenihilistcipherwasusedextensivelybythesovietsduringandafterthewarinthe40s.facrair

## TODO:

Implement the Key, implement the keygroup insertion, and tidy up some bottlenecks.