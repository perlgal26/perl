#!/usr/bin/perl -w

use strict;
use warnings;
use Cwd;
use MarketData::AppSettings;
use MarketData::Portfolio;
use MarketData::Concepts;
use MarketData::DB;
use MarketData::Data;
use Data::Dumper;


#use Proc::Daemon;
#Proc::Daemon::Init();


my $db = MarketData::DB->new( MarketData::AppSettings::postgres_handle );
$db->make_database_classes;

my $logDir = MarketData::AppSettings::get_log_dir;
#`echo    "here I m logDir===$logDir">>/tmp/test.txt`;
# make my log files
my $time = time;

open STDOUT, ">$logDir/calc_exchange_rate_$time.log";
open STDERR, ">$logDir/calc_exchange_rate_err_$time.log";

# get entity id for Imperial Oil Limited for both US and Canadian exchanges
# Imperial Oil Limited's ticker is IMO. in Canada and IMO in United States
my $interListedCompany1SymbolUSD = 'IMO';
my $interListedCompany1SymbolCAD = 'IMO.';

# get entity id for Barrick Gold Corporation for both US and Canadian exchanges
# Barrick Gold Corporation's ticker is ABX. in Canada and ABX in United States
my $interListedCompany2SymbolUSD = 'ABX';
my $interListedCompany2SymbolCAD = 'ABX.';

# get entity ids for interlisted securities for exchange rate calcs
my $interListedEntity1USD = MarketData::DB::Entity->new( $db->dbh );
$interListedEntity1USD->retrieveOn( symbol => $interListedCompany1SymbolUSD );
my $interListedEntityId1USD = $interListedEntity1USD->entity_id;

my $interListedEntity1CAD = MarketData::DB::Entity->new( $db->dbh );
$interListedEntity1CAD->retrieveOn( symbol => $interListedCompany1SymbolCAD );
my $interListedEntityId1CAD = $interListedEntity1CAD->entity_id;

my $interListedEntity2USD = MarketData::DB::Entity->new( $db->dbh );
$interListedEntity2USD->retrieveOn( symbol => $interListedCompany2SymbolUSD );
my $interListedEntityId2USD = $interListedEntity2USD->entity_id;

my $interListedEntity2CAD = MarketData::DB::Entity->new( $db->dbh );
$interListedEntity2CAD->retrieveOn( symbol => $interListedCompany2SymbolCAD );
my $interListedEntityId2CAD = $interListedEntity2CAD->entity_id;

#ticket 117 --- 31-oct-2011

my $port = MarketData::Portfolio->new(dbh => $db->dbh);
my $oneMonthBackDate = $port->get_MonthsBackDate(2);
#`echo    "here I m 1===$oneMonthBackDate----------USD = $interListedEntityId1USD-----CAD= $interListedEntityId1CAD">>/tmp/test.txt`;
my $threeMonthBackDate = $port->get_MonthsBackDate(4);
#`echo    "here I m 3===$threeMonthBackDate">>/tmp/test.txt`;
my $sixMonthBackDate = $port->get_MonthsBackDate(7);
#`echo    "here I m 6===$sixMonthBackDate">>/tmp/test.txt`;
my $twelveMonthBackDate = $port->get_MonthsBackDate(13);
#`echo    "here I m 12===$twelveMonthBackDate">>/tmp/test.txt`;
my $hist = MarketData::Data->new(dbh => $db->dbh);
my $dataCategoryId = 158;

#IMO USD prices for 1,3,6,12 months back..
my $price1OneMonthBackDateUSD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId1USD,
							$oneMonthBackDate);
#`echo     "here I m price1USD 1===$price1OneMonthBackDateUSD">>/tmp/test.txt`;
my $price1ThreeMonthBackDateUSD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId1USD,
							$threeMonthBackDate);
#`echo     "here I m price1USD 3===$price1ThreeMonthBackDateUSD">>/tmp/test.txt`;
my $price1SixMonthBackDateUSD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId1USD,
							$sixMonthBackDate);
#`echo     "here I m price1USD 6===$price1SixMonthBackDateUSD">>/tmp/test.txt`;							
my $price1TwelveMonthBackDateUSD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId1USD,
							$twelveMonthBackDate);
#`echo     "here I m price1USD 12===$price1TwelveMonthBackDateUSD">>/tmp/test.txt`;

#IMO. CAD prices for 1,3,6,12 months back..
my $price1OneMonthBackDateCAD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId1CAD,
							$oneMonthBackDate);
#`echo     "here I m price1 CAD 1===$price1OneMonthBackDateCAD">>/tmp/test.txt`;
my $price1ThreeMonthBackDateCAD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId1CAD,
							$threeMonthBackDate);
#`echo     "here I m price1 CAD 3===$price1ThreeMonthBackDateCAD">>/tmp/test.txt`;
my $price1SixMonthBackDateCAD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId1CAD,
							$sixMonthBackDate);
#`echo     "here I m price1 CAD 6===$price1SixMonthBackDateCAD">>/tmp/test.txt`;							
my $price1TwelveMonthBackDateCAD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId1CAD,
							$twelveMonthBackDate);
#`echo     "here I m price1 CAD 12===$price1TwelveMonthBackDateCAD">>/tmp/test.txt`;	



#ABX USD prices for 1,3,6,12 months back..
my $price2OneMonthBackDateUSD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId2USD,
							$oneMonthBackDate);
#`echo     "here I m price2USD 1===$price2OneMonthBackDateUSD">>/tmp/test.txt`;
my $price2ThreeMonthBackDateUSD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId2USD,
							$threeMonthBackDate);
#`echo     "here I m price2USD 3===$price2ThreeMonthBackDateUSD">>/tmp/test.txt`;
my $price2SixMonthBackDateUSD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId2USD,
							$sixMonthBackDate);
#`echo     "here I m price2USD 6===$price2SixMonthBackDateUSD">>/tmp/test.txt`;							
my $price2TwelveMonthBackDateUSD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId2USD,
							$twelveMonthBackDate);
#`echo     "here I m price2USD 12===$price2TwelveMonthBackDateUSD">>/tmp/test.txt`;

#ABX. CAD prices for 1,3,6,12 months back..
my $price2OneMonthBackDateCAD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId2CAD,
							$oneMonthBackDate);
#`echo     "here I m price2 CAD 2===$price2OneMonthBackDateCAD">>/tmp/test.txt`;
my $price2ThreeMonthBackDateCAD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId2CAD,
							$threeMonthBackDate);
#`echo     "here I m price2 CAD 3===$price2ThreeMonthBackDateCAD">>/tmp/test.txt`;
my $price2SixMonthBackDateCAD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId2CAD,
							$sixMonthBackDate);
#`echo     "here I m price2 CAD 6===$price2SixMonthBackDateCAD">>/tmp/test.txt`;							
my $price2TwelveMonthBackDateCAD = $hist->get_dated_value_for_entity(
							$dataCategoryId,	
							$interListedEntityId2CAD,
							$twelveMonthBackDate);
#`echo     "here I m price2 CAD 12===$price2TwelveMonthBackDateCAD">>/tmp/test.txt`;	

#Xchange Rate begins
my $CADtoUSD1MonthBack;
my $CADtoUSD3MonthBack;
my $CADtoUSD6MonthBack;
my $CADtoUSD12MonthBack;

my $USDtoCAD1MonthBack;
my $USDtoCAD3MonthBack;
my $USDtoCAD6MonthBack;
my $USDtoCAD12MonthBack;

# calculate interlisted eschange rate using IMO first if available and then ABX if IMO is undefined
if ( defined ($price1OneMonthBackDateUSD) && length($price1OneMonthBackDateUSD) > 0 && defined ($price1OneMonthBackDateCAD) && length($price1OneMonthBackDateCAD) > 0 )
                        {
                                $CADtoUSD1MonthBack = ( $price1OneMonthBackDateUSD /$price1OneMonthBackDateCAD );
                                $USDtoCAD1MonthBack = ( $price1OneMonthBackDateCAD / $price1OneMonthBackDateUSD );
                        }
elsif ( defined ($price2OneMonthBackDateUSD) && length($price2OneMonthBackDateUSD) > 0 && defined ($price2OneMonthBackDateCAD) && length($price2OneMonthBackDateCAD) > 0 )
                        {
                                $CADtoUSD1MonthBack = ( $price2OneMonthBackDateUSD / $price2OneMonthBackDateCAD);
                                $USDtoCAD1MonthBack = ( $price2OneMonthBackDateCAD / $price2OneMonthBackDateUSD );
                        }	
print STDOUT "here are the calcuated exchange rates for 1 month back: " . $CADtoUSD1MonthBack . " and " . $USDtoCAD1MonthBack . "\n";                        
#`echo    "here are the calcuated exchange rates for 1 month back: $CADtoUSD1MonthBack  and  $USDtoCAD1MonthBack  ">>/tmp/test.txt`;	
if ( defined ($price1ThreeMonthBackDateUSD) && length($price1ThreeMonthBackDateUSD) > 0 && defined ($price1ThreeMonthBackDateUSD) && length($price1ThreeMonthBackDateUSD) > 0 )
                        {
                                $CADtoUSD3MonthBack = ( $price1ThreeMonthBackDateUSD /$price1ThreeMonthBackDateUSD );
                                $USDtoCAD3MonthBack = ( $price1ThreeMonthBackDateUSD / $price1ThreeMonthBackDateUSD );
                        }
elsif ( defined ($price2ThreeMonthBackDateUSD) && length($price2ThreeMonthBackDateUSD) > 0 && defined ($price2ThreeMonthBackDateCAD) && length($price2ThreeMonthBackDateCAD) > 0 )
                        {
                                $CADtoUSD3MonthBack = ( $price2ThreeMonthBackDateUSD / $price2ThreeMonthBackDateCAD);
                                $USDtoCAD3MonthBack = ( $price2ThreeMonthBackDateCAD / $price2ThreeMonthBackDateUSD );
                        }	
print STDOUT "here are the calcuated exchange rates for 3 month back: " . $CADtoUSD3MonthBack . " and " . $USDtoCAD3MonthBack . "\n"; 
#`echo    "here are the calcuated exchange rates for 3 month back: $CADtoUSD3MonthBack  and  $USDtoCAD3MonthBack ">>/tmp/test.txt`;

if ( defined ($price1SixMonthBackDateUSD) && length($price1SixMonthBackDateUSD) > 0 && defined ($price1SixMonthBackDateCAD) && length($price1SixMonthBackDateCAD) > 0 )
                        {
                                $CADtoUSD6MonthBack = ( $price1SixMonthBackDateUSD /$price1SixMonthBackDateCAD );
                                $USDtoCAD6MonthBack = ( $price1SixMonthBackDateCAD / $price1SixMonthBackDateUSD );
                        }
elsif ( defined ($price2SixMonthBackDateUSD) && length($price2SixMonthBackDateUSD) > 0 && defined ($price2SixMonthBackDateCAD) && length($price2SixMonthBackDateCAD) > 0 )
                        {
                                $CADtoUSD6MonthBack = ( $price2SixMonthBackDateUSD / $price2SixMonthBackDateCAD);
                                $USDtoCAD6MonthBack = ( $price2SixMonthBackDateCAD / $price2SixMonthBackDateUSD );
                        }	
print STDOUT "here are the calcuated exchange rates for 6 month back: " . $CADtoUSD6MonthBack . " and " . $USDtoCAD6MonthBack . "\n"; 
#`echo    "here are the calcuated exchange rates for 6 month back: $CADtoUSD6MonthBack  and $USDtoCAD6MonthBack  ">>/tmp/test.txt`;

if ( defined ($price1TwelveMonthBackDateUSD) && length($price1TwelveMonthBackDateUSD) > 0 && defined ($price1TwelveMonthBackDateCAD) && length($price1TwelveMonthBackDateCAD) > 0 )
                        {
                                $CADtoUSD12MonthBack = ( $price1TwelveMonthBackDateUSD /$price1TwelveMonthBackDateCAD );
                                $USDtoCAD12MonthBack = ( $price1TwelveMonthBackDateCAD / $price1TwelveMonthBackDateUSD );
                        }
elsif ( defined ($price2TwelveMonthBackDateUSD) && length($price2TwelveMonthBackDateUSD) > 0 && defined ($price2TwelveMonthBackDateCAD) && length($price2TwelveMonthBackDateCAD) > 0 )
                        {
                                $CADtoUSD12MonthBack = ( $price2TwelveMonthBackDateUSD / $price2TwelveMonthBackDateCAD);
                                $USDtoCAD12MonthBack = ( $price2TwelveMonthBackDateCAD / $price2TwelveMonthBackDateUSD );
                        }	
print STDOUT "here are the calcuated exchange rates for 12 month back: " . $CADtoUSD12MonthBack . " and " . $USDtoCAD12MonthBack . "\n"; 
#`echo    "here are the calcuated exchange rates for 12 month back:  $CADtoUSD12MonthBack  and  $USDtoCAD12MonthBack  ">>/tmp/test.txt`;					
=comment
my $concepts = MarketData::Concepts->new( dbh => $db->dbh );

#now get the daily price from the entity_stat_current table
my ($interListedPriceEntity1USD, $entityStatObject) = $concepts->get_entity_stat($interListedEntityId1USD, 'Price', "GetEntStatCurrent", undef  );
my ($interListedPriceEntity1CAD, $entityStatObject1) = $concepts->get_entity_stat($interListedEntityId1CAD, 'Price', "GetEntStatCurrent", undef  );
my ($interListedPriceEntity2USD, $entityStatObject2) = $concepts->get_entity_stat($interListedEntityId2USD, 'Price', "GetEntStatCurrent", undef  );
my ($interListedPriceEntity2CAD, $entityStatObject3) = $concepts->get_entity_stat($interListedEntityId2CAD, 'Price', "GetEntStatCurrent", undef  );

# calculate interlisted eschange rate using IMO first if available and then ABX if IMO is undefined

my $CADtoUSD;
my $USDtoCAD;
if ( defined ($interListedPriceEntity1USD) && length($interListedPriceEntity1USD) > 0 && defined ($interListedPriceEntity1CAD) && length($interListedPriceEntity1CAD) > 0 )
                        {
                                $CADtoUSD = ( $interListedPriceEntity1USD / $interListedPriceEntity1CAD );
                                $USDtoCAD = ( $interListedPriceEntity1CAD / $interListedPriceEntity1USD );
                        }
elsif ( defined ($interListedPriceEntity2USD) && length($interListedPriceEntity2USD) > 0 && defined ($interListedPriceEntity2CAD) && length($interListedPriceEntity2CAD) > 0 )
                        {
                                $CADtoUSD = ( $interListedPriceEntity2USD / $interListedPriceEntity2CAD );
                                $USDtoCAD = ( $interListedPriceEntity2CAD / $interListedPriceEntity2USD );
                        }

print STDOUT "here are the calcuated exchange rates: " . $CADtoUSD . " and " . $USDtoCAD . "\n";

# update exchange rate in exchange rate table
my $exchangeRate = MarketData::DB::CurrencyExchangeRate->new( $db->dbh );
my $isRecord = $exchangeRate->retrieveOn( from_symbol => 'CAD', to_symbol => 'USD',);

        $exchangeRate->rate( $CADtoUSD );
        $exchangeRate->update if $isRecord;

my $isRecord1 = $exchangeRate->retrieveOn( from_symbol => 'USD', to_symbol => 'CAD',);

        $exchangeRate->rate( $USDtoCAD );
        $exchangeRate->update if $isRecord1;
=cut
exit(0);


