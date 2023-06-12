# firmy-cz-scraper

```
swift build && cp .build/arm64-apple-macosx/debug/firmy-cz-scraper .
```

```
swift build
```

```
swift build -c release
```

## Usage

```
OVERVIEW: Scrapes data from firmy.cz

USAGE: firmy-cz-scraper <query>
       firmy-cz-scraper <query> --limit 5 --format "title;address;web;phone;email;ico;description;fimylink"

ARGUMENTS:
  <query>                 search query

OPTIONS:
  -l, --limit <limit>     page limit, default: 150 (default: 150)
  -o, --output <output>   output file, default: ./data.csv
  -f, --format <format>   format the data, default: title;web;phone;email;firmylink
  -a, --append            append to output file, defaul: false
  -p, --prepend-col-names prepend column names in output file, default: false
  -h, --help              Show help information.
```
