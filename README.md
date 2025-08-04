# finviz-screener
These Racket programs will download the FinViz Screener CSV documents and insert the sector and industry data into a PostgreSQL database. 
This is just to augment the [spdr-etf-holdings](https://github.com/evdubs/spdr-etf-holdings) data. The intended usage is:

```bash
$ racket extract.rkt
$ racket transform-load.rkt
```

You will need to provide a FinViz email and password for `extract.rkt` and a database password for `transform-load.rkt`.
The available parameters are:

```bash
$ racket extract.rkt -h
usage: racket extract.rkt [ <option> ... ]
<option> is one of
  -e <email>, --email-address <email>
     Email address used for FinViz
  -p <pass>, --password <pass>
     Password used for FinViz
  --help, -h
     Show this help
  --
     Do not treat any remaining argument as a switch (at this level)
 Multiple single-letter switches can be combined after
 one `-`. For example, `-h-` is the same as `-h --`.

$ racket transform-load.rkt -h
usage: racket transform-load.rkt [ <option> ... ]
<option> is one of
  -b <folder>, --base-folder <folder>
     FinViz screener file base folder. Defaults to /var/local/finviz/screener
  -d <date>, --file-date <date>
     FinViz screener file date. Defaults to today
  -n <name>, --db-name <name>
     Database name. Defaults to 'local'
  -p <password>, --db-pass <password>
     Database password
  -u <user>, --db-user <user>
     Database user name. Defaults to 'user'
  --help, -h
     Show this help
  --
     Do not treat any remaining argument as a switch (at this level)
 Multiple single-letter switches can be combined after
 one `-`. For example, `-h-` is the same as `-h --`.
```

### Dependencies

It is recommended that you start with the standard Racket distribution. With that, you will need to install the following packages:

```bash
$ raco pkg install --skip-installed gregor http-easy threading
```
