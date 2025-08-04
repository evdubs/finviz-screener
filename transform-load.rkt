#lang racket/base

(require db
         gregor
         racket/cmdline
         racket/list
         racket/match
         racket/port
         racket/set
         racket/string)

(define base-folder (make-parameter "/var/local/finviz/screener"))

(define file-date (make-parameter (today)))

(define db-user (make-parameter "user"))

(define db-name (make-parameter "local"))

(define db-pass (make-parameter ""))

(command-line
 #:program "racket transform-load.rkt"
 #:once-each
 [("-b" "--base-folder") folder
                         "FinViz screener file base folder. Defaults to /var/local/finviz/screener"
                         (base-folder folder)]
 [("-d" "--file-date") date
                       "FinViz screener file date. Defaults to today"
                       (file-date (iso8601->date date))]
 [("-n" "--db-name") name
                     "Database name. Defaults to 'local'"
                     (db-name name)]
 [("-p" "--db-pass") password
                     "Database password"
                     (db-pass password)]
 [("-u" "--db-user") user
                     "Database user name. Defaults to 'user'"
                     (db-user user)])

(define dbc (postgresql-connect #:user (db-user) #:database (db-name) #:password (db-pass)))

(define sector (hash "Basic Materials" "Materials"
                     "Communication Services" "Communication Services"
                     "Consumer Cyclical" "Consumer Discretionary"
                     "Consumer Defensive" "Consumer Staples"
                     "Energy" "Energy"
                     "Financial" "Financials"
                     "Healthcare" "Health Care"
                     "Industrials" "Industrials"
                     "Real Estate" "Real Estate"
                     "Technology" "Information Technology"
                     "Utilities" "Utilities"))

(define industry (hash "Advertising Agencies" "Media"
                       "Aerospace & Defense" "Aerospace & Defense"
                       "Agricultural Inputs" "Chemicals"
                       "Airlines" "Airlines"
                       "Aluminum" "Metals & Mining"
                       "Apparel Manufacturing" "Textiles Apparel & Luxury Goods"
                       "Apparel Retail" "Specialty Retail"
                       "Asset Management" "Capital Markets"
                       "Auto Manufacturers" "Automobiles"
                       "Auto Parts" "Automobile Components"
                       "Auto & Truck Dealerships" "Specialty Retail"
                       "Banks - Diversified" "Banks"
                       "Banks - Regional" "Banks"
                       "Beverages - Brewers" "Beverages"
                       "Beverages - Non-Alcoholic" "Beverages"
                       "Beverages - Wineries & Distilleries" "Beverages"
                       "Biotechnology" "Biotechnology"
                       "Building Materials" "Construction Materials"
                       "Building Products & Equipment" "Building Products"
                       "Capital Markets" "Capital Markets"
                       "Chemicals" "Chemicals"
                       "Communication Equipment" "Communications Equipment"
                       "Computer Hardware" "Technology Hardware Storage & Peripherals"
                       "Confectioners" "Food Products"
                       "Conglomerates" "Industrial Conglomerates"
                       "Consulting Services" "Professional Services"
                       "Consumer Electronics" "Technology Hardware Storage & Peripherals"
                       "Copper" "Metals & Mining"
                       "Credit Services" "Consumer Finance"
                       "Department Stores" "Broadline Retail"
                       "Diagnostics & Research" "Health Care Providers & Services"
                       "Discount Stores" "Consumer Staples Distribution & Retail"
                       "Drug Manufacturers - General" "Pharmaceuticals"
                       "Drug Manufacturers - Specialty & Generic" "Pharmaceuticals"
                       "Electronic Components" "Electronic Equipment Instruments & Components"
                       "Electronic Gaming & Multimedia" "Entertainment"
                       "Engineering & Construction" "Construction & Engineering"
                       "Entertainment" "Entertainment"
                       "Farm & Heavy Construction Machinery" "Machinery"
                       "Farm Products" "Food Products"
                       "Financial Conglomerates" "Diversified Financial Services"
                       "Financial Data & Stock Exchanges" "Capital Markets"
                       "Food Distribution" "Consumer Staples Distribution & Retail"
                       "Footwear & Accessories" "Textiles Apparel & Luxury Goods"
                       "Furnishings, Fixtures & Appliances" "Household Durables"
                       "Gold" "Metals & Mining"
                       "Grocery Stores" "Consumer Staples Distribution & Retail"
                       "Healthcare Plans" "Health Care Providers & Services"
                       "Health Information Services" "Health Care Equipment & Supplies"
                       "Home Improvement Retail" "Specialty Retail"
                       "Household & Personal Products" "Household Products"
                       "Industrial Distribution" "Trading Companies & Distributors"
                       "Information Technology Services" "It Services"
                       "Insurance Brokers" "Insurance"
                       "Insurance - Diversified" "Insurance"
                       "Insurance - Life" "Insurance"
                       "Insurance - Property & Casualty" "Insurance"
                       "Insurance - Reinsurance" "Insurance"
                       "Insurance - Specialty" "Insurance"
                       "Integrated Freight & Logistics" "Air Freight & Logistics"
                       "Internet Content & Information" "Interactive Media & Services"
                       "Internet Retail" "Broadline Retail"
                       "Leisure" "Leisure Products"
                       "Lodging" "Hotels Restaurants & Leisure"
                       "Luxury Goods" "Textiles Apparel & Luxury Goods"
                       "Medical Care Facilities" "Health Care Providers & Services"
                       "Medical Devices" "Health Care Equipment & Supplies"
                       "Medical Distribution" "Health Care Providers & Services"
                       "Medical Instruments & Supplies" "Health Care Equipment & Supplies"
                       "Metal Fabrication" "Metals & Mining"
                       "Oil & Gas Drilling" "Oil Gas & Consumable Fuels"
                       "Oil & Gas E&P" "Oil Gas & Consumable Fuels"
                       "Oil & Gas Equipment & Services" "Energy Equipment & Services"
                       "Oil & Gas Integrated" "Oil Gas & Consumable Fuels"
                       "Oil & Gas Midstream" "Oil Gas & Consumable Fuels"
                       "Oil & Gas Refining & Marketing" "Oil Gas & Consumable Fuels"
                       "Other Industrial Metals & Mining" "Metals & Mining"
                       "Other Precious Metals & Mining" "Metals & Mining"
                       "Packaged Foods" "Food Products"
                       "Packaging & Containers" "Containers & Packaging"
                       "Pharmaceutical Retailers" "Consumer Staples Distribution & Retail"
                       "Railroads" "Ground Transportation"
                       "Real Estate - Development" "Real Estate Management & Development"
                       "Real Estate - Diversified" "Real Estate Management & Development"
                       "REIT - Diversified" "Specialized REITs"
                       "REIT - Healthcare Facilities" "Health Care REITs"
                       "REIT - Hotel & Motel" "Hotel & Resort REITs"
                       "REIT - Industrial" "Industrial REITs"
                       "REIT - Office" "Office REITs"
                       "REIT - Residential" "Residential REITs"
                       "REIT - Retail" "Retail REITs"
                       "REIT - Specialty" "Specialized REITs"
                       "Residential Construction" "Household Durables"
                       "Resorts & Casinos" "Hotels Restaurants & Leisure"
                       "Restaurants" "Hotels Restaurants & Leisure"
                       "Scientific & Technical Instruments" "Electronic Equipment Instruments & Components"
                       "Security & Protection Services" "Building Products"
                       "Semiconductor Equipment & Materials" "Semiconductors & Semiconductor Equipment"
                       "Semiconductors" "Semiconductors & Semiconductor Equipment"
                       "Software - Application" "Software"
                       "Software - Infrastructure" "Software"
                       "Solar" "Semiconductors & Semiconductor Equipment"
                       "Specialty Business Services" "Commercial Services & Supplies"
                       "Specialty Chemicals" "Chemicals"
                       "Specialty Industrial Machinery" "Building Products"
                       "Specialty Retail" "Specialty Retail"
                       "Staffing & Employment Services" "Professional Services"
                       "Steel" "Metals & Mining"
                       "Telecom Services" "Diversified Telecommunication Services"
                       "Textile Manufacturing" "Textiles Apparel & Luxury Goods"
                       "Tobacco" "Tobacco"
                       "Tools & Accessories" "Machinery"
                       "Travel Services" "Hotels Restaurants & Leisure"
                       "Trucking" "Ground Transportation"
                       "Utilities - Diversified" "Multi-Utilities"
                       "Utilities - Regulated Electric" "Electric Utilities"
                       "Utilities - Regulated Gas" "Gas Utilities"
                       "Utilities - Regulated Water" "Water Utilities"
                       "Waste Management" "Commercial Services & Supplies"))

(define sub-industry (hash "Aerospace & Defense" "Aerospace & Defense"
                           "Airlines" "Passenger Airlines"
                           "Aluminum" "Aluminum"
                           "Apparel Retail" "Apparel Retail"
                           "Asset Management" "Asset Management & Custody Banks"
                           "Auto Parts" "Automotive Retail"
                           "Auto & Truck Dealerships" "Automotive Retail"
                           "Banks - Diversified" "Diversified Banks"
                           "Banks - Regional" "Regional Banks"
                           "Biotechnology" "Biotechnology"
                           "Building Products & Equipment" "Building Products"
                           "Capital Markets" "Investment Banking & Brokerage"
                           "Coking Coal" "Steel"
                           "Communication Equipment" "Communications Equipment"
                           "Computer Hardware" "Technology Hardware Storage & Peripherals"
                           "Consumer Electronics" "Technology Hardware Storage & Peripherals"
                           "Copper" "Copper"
                           "Department Stores" "Broadline Retail"
                           "Diagnostics & Research" "Health Care Services"
                           "Discount Stores" "Consumer Staples Merchandise Retail"
                           "Drug Manufacturers - General" "Pharmaceuticals"
                           "Drug Manufacturers - Specialty & Generic" "Pharmaceuticals"
                           "Electronic Components" "Semiconductors"
                           "Electronic Gaming & Multimedia" "Interactive Home Entertainment"
                           "Financial Conglomerates" "Diversified Financial Services"
                           "Financial Data & Stock Exchanges" "Financial Exchanges & Data"
                           "Footwear & Accessories" "Apparel Retail"
                           "Furnishings, Fixtures & Appliances" "Household Appliances"
                           "Gold" "Gold"
                           "Grocery Stores" "Food Retail"
                           "Healthcare Plans" "Managed Health Care"
                           "Health Information Services" "Health Care Equipment"
                           "Home Improvement Retail" "Home Improvement Retail"
                           "Information Technology Services" "It Consulting & Other Services"
                           "Insurance Brokers" "Insurance Brokers"
                           "Insurance - Diversified" "Multi-Line Insurance"
                           "Insurance - Life" "Life & Health Insurance"
                           "Insurance - Property & Casualty" "Property & Casualty Insurance"
                           "Insurance - Reinsurance" "Reinsurance"
                           "Insurance - Specialty" "Multi-Line Insurance"
                           "Integrated Freight & Logistics" "Air Freight & Logistics"
                           "Internet Content & Information" "Interactive Media & Services"
                           "Internet Retail" "Broadline Retail"
                           "Luxury Goods" "Other Specialty Retail"
                           "Marine Shipping" "Marine"
                           "Medical Care Facilities" "Health Care Facilities"
                           "Medical Devices" "Health Care Equipment"
                           "Medical Distribution" "Health Care Distributors"
                           "Medical Instruments & Supplies" "Health Care Equipment"
                           "Metal Fabrication" "Steel"
                           "Mortgage Finance" "Commercial & Residential Mortgage Finance"
                           "Oil & Gas Drilling" "Oil & Gas Drilling"
                           "Oil & Gas E&P" "Oil & Gas Exploration & Production"
                           "Oil & Gas Equipment & Services" "Oil & Gas Equipment & Services"
                           "Oil & Gas Integrated" "Integrated Oil & Gas"
                           "Oil & Gas Refining & Marketing" "Oil & Gas Refining & Marketing"
                           "Other Industrial Metals & Mining" "Diversified Metals & Mining"
                           "Pharmaceutical Retailers" "Drug Retail"
                           "Railroads" "Rail Transportation"
                           "Real Estate Services" "Real Estate Services"
                           "Residential Construction" "Homebuilding"
                           "Scientific & Technical Instruments" "Electronic Equipment & Instruments"
                           "Security & Protection Services" "Building Products"
                           "Semiconductors" "Semiconductors"
                           "Software - Application" "Application Software"
                           "Software - Infrastructure" "Systems Software"
                           "Solar" "Semiconductors"
                           "Specialty Industrial Machinery" "Building Products"
                           "Specialty Retail" "Other Specialty Retail"
                           "Steel" "Steel"
                           "Telecom Services" "Integrated Telecommunication Services"
                           "Thermal Coal" "Coal & Consumable Fuels"
                           "Trucking" "Cargo Ground Transportation"))

(define symbols (list->set (query-list dbc "
select distinct
  component_symbol
from
  spdr.etf_holding
where
  date = (select max(date) from spdr.etf_holding);
")))

(let ([file-name (string-append (base-folder) "/" (~t (file-date) "yyyy-MM-dd") ".csv")])
  (call-with-input-file file-name
    (λ (in) (let* ([lines (string-split (port->string in) "\n")]
                   [vals (filter-map (λ (l) (match l
                                              [(regexp #rx"([0-9]+),\"([A-Z\\-]+)\",\"(.*?)\",\"([a-zA-Z ]+)\",\"([a-zA-Z ,&\\-]+)\""
                                                        (list str num symbol description sector industry))
                                               (list (string-replace symbol "-" ".") sector industry)]
                                              [_ (displayln (string-append "Could not match " l)) #f]))
                                     lines)]
                   [components (filter (λ (v)
                                         (set-member? symbols (first v)))
                                       vals)])
              (for-each (λ (v)
                          (query-exec dbc "
update
  spdr.etf_holding
set
  sector = $1::text::spdr.sector
where
  sector is null and
  date = (select max(date) from spdr.etf_holding) and
  component_symbol = $2 and
  etf_symbol in ('DIA', 'SPY', 'MDY', 'SLY', 'SPSM');
"
                                      (hash-ref sector (second v))
                                      (first v))
                          (cond [(hash-has-key? industry (third v))
                                 (query-exec dbc "
update
  spdr.etf_holding
set
  industry = $1::text::spdr.industry
where
  industry is null and
  date = (select max(date) from spdr.etf_holding) and
  component_symbol = $2 and
  etf_symbol in ('XLB', 'XLC', 'XLE', 'XLF', 'XLI', 'XLK', 'XLP', 'XLRE', 'XLU', 'XLV', 'XLY');
"
                                             (hash-ref industry (third v))
                                             (first v))]
                                [else (displayln (string-append (third v) " not found for " (first v)))])
                          (cond [(hash-has-key? sub-industry (third v))
                                 (query-exec dbc "
update
  spdr.etf_holding
set
  sub_industry = $1::text::spdr.sub_industry
where
  sub_industry is null and
  date = (select max(date) from spdr.etf_holding) and
  component_symbol = $2 and
  etf_symbol in ('KBE', 'KCE', 'KIE', 'KRE', 'XAR', 'XBI', 'XES', 'XHB', 'XHE', 'XHS',
    'XME', 'XOP', 'XPH', 'XRT', 'XSD', 'XSW', 'XTL', 'XTN', 'XWEB');
"
                                             (hash-ref sub-industry (third v))
                                             (first v))]
                                [else (displayln (string-append (third v) " not found for " (first v)))]))
                        components)))))
