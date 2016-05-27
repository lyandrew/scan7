### Getting Started

1) Install dependencies
```sh
bundle install
```

2) Run the app
```sh
ruby stats.rb
```

Sample output (Varies depending on system specifications). 
```
$ ruby stats.rb 
Average scan time: 1280.5346073495698 seconds
Fastest scan: Asset: 1311455 with 0.001 seconds
Longest scan: Asset: 2481871 with 589277.649 seconds
Fastest average scan: IP: 160.253.214.132 with 0.018 seconds
Longest average scan IP: 23.20.1.26 with 440928.1 seconds
Ran in 31.8 seconds
```

### Design choices:
* [Oj](https://github.com/ohler55/oj#performance-comparisons) was used because it performs a lot better than the default Ruby JSON parsers.
* To calculate average response time, used a hash with ip as key and array of its response time as value.
