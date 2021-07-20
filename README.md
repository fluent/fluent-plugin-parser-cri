# fluent-plugin-parser-cri

[Fluentd](https://fluentd.org/) parser plugin to parse CRI logs.

CRI logs consist of `time`, `stream`, `logtag` and `message` parts like below:

```
2020-10-10T00:10:00.333333333Z stdout F Hello Fluentd

time: 2020-10-10T00:10:00.333333333Z
stream: stdout
logtag: F
message: Hello Fluentd
```

## Installation

### RubyGems

```
$ gem install fluent-plugin-parser-cri --no-document
```

## Configuration

* **merge_cri_fields** (bool) (optional): Put `stream`/`logtag` fields or not when `<parse>` section is specified. Default is `true`

### \<parse\> section (optional)

Same as [parser plugin configuration](https://docs.fluentd.org/configuration/parse-section).

```aconf
<parse>
  @type cri
  <parse>
    @type json
  </parse>
</parse>
```

This nested `<parse>` is used for parsing `message` part.

## Log and configuration example

### Basic case

```aconf
<parse>
  @type cri
</parse>
```

With this configuration, following CRI log

```
2020-10-10T00:10:00.333333333Z stdout F Hello Fluentd
```

is parsed to

```
time: 2020-10-10T00:10:00.333333333Z
record: {"stream":"stdout","logtag":"F","message":"Hello Fluentd","time':'2020-10-10T00:10:00.333333333Z"}
```

### Parse message part with parsers

By specifying `<parse>` section, you can parse `message` part with parser plugins.

```aconf
<parse>
  @type cri
  <parse>
    @type json
    time_key time
    time_format %Y-%m-%dT%H:%M:%S.%L%z
    # keep_time_key true # if you want to keep "time" field, enable this parameter
  </parse>
</parse>
```

With this configuration, following CRI log

```
2020-10-10T00:10:00.333333333Z stdout F {"foo":"bar","num":100,"time":"2020-11-11T00:11:00.111111111Z"}
```

is parsed to

```
time: 2020-11-11T00:11:00.111111111Z
record: {"foo":"bar","num":100,"stream":"stdout","logtag":"F"}
```

If you don't need `stream`/`logtag` fields, set `merge_cri_fields false` like below:

```
<parse>
  @type cri
  merge_cri_fields false
  <parse>
    @type json
    time_key time
    time_format %Y-%m-%dT%H:%M:%S.%L%z
  </parse>
</parse>
```

### Concatenate multiple `message` records into one

If you want to concatenate the following `message` records into one record, 
use @type [concat](https://github.com/fluent-plugins-nursery/fluent-plugin-concat) filter plugin with `use_partial_cri_logtag` parameter.

 ```
2020-10-10 09:10:00.333333333 +0900 cri: {"stream":"stdout","logtag":"P","message":"This is first line","time":"2020-10-10T00:10:00.333333333Z"}
2020-10-10 09:11:00.333333333 +0900 cri: {"stream":"stdout","logtag":"F","message":"This is last line","time":"2020-10-10T00:11:00.333333333Z"}
```

See fluent-plugin-concat's [usage](https://github.com/fluent-plugins-nursery/fluent-plugin-concat#usage) in more details.


## Copyright

* Copyright(c) 2020- Fluentd project
* License
  * Apache License, Version 2.0
