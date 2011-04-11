package Business::Cart::Generic::View::Order;

use strict;
use warnings;

use JSON::XS;

use Moose;

use Text::Xslate 'mark_raw';

extends 'Business::Cart::Generic::View::Base';

use namespace::autoclean;

our $VERSION = '0.80';

# -----------------------------------------------

sub format_order
{
	my($self, $order) = @_;

	$self -> db -> logger -> log(debug => "format_order(...)");

	my($id) = $$order{id};

	my(@row);

	push @row,
	[
	 {td => "Order #:$id"},
	];

	push @row,
	[
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	];

	push @row,
	[
	 {td => 'Customer:'},
	 {td => 'Customer address:'},
	];

	# Warning: These hash keys are faked, just to work with the following loop.

	my(%extra) =
	(
	 street_1     => "$$order{customer}{title} $$order{customer}{name}",
	 locality     => '',
	 zone_name    => '',
	 country_name => '',
	);

	for my $line (qw/street_1 locality zone_name country_name/)
	{
		push @row,
		[
		 {td => $extra{$line} },
		 {td => $$order{customer_address}{$line} },
		];
	};

	push @row,
	[
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	];

	push @row,
	[
	 {td => 'Order:'},
	 {td => 'Delivery address:'},
	];

	# Warning: These hash keys are faked, just to work with the following loop.

	%extra =
	(
	 street_1     => "Added: $$order{date_added}",
	 locality     => "Completed: $$order{date_completed}",
	 zone_name    => '',
	 country_name => "Payment method: $$order{payment_method}",
	);

	for my $line (qw/street_1 locality zone_name country_name/)
	{
		push @row,
		[
		 {td => $extra{$line} },
		 {td => $$order{delivery_address}{$line} },
		];
	};

	push @row,
	[
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	];

	push @row,
	[
	 {td => 'Items:'},
	];

	push @row,
	[
	 {td => 'Name'},
	 {td => 'Price'},
	 {td => 'Quantity'},
	 {td => 'Tax'},
	];

	for my $item (@{$$order{item} })
	{
		push @row,
		[
		 {td => $$item{name} },
		 {td => $$item{price} },
		 {td => $$item{quantity} },
		 {td => $$item{tax} },
		];
	}

	push @row,
	[
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	];

	push @row,
	[
	 {td => 'Total price:'},
	 {td => $$order{total_price} },
	 {td => 'Total tax:'},
	 {td => $$order{total_tax} },
	];

	push @row,
	[
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	 {td => mark_raw('<hr />')},
	];

	return \@row;

} # End of display.

# -----------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
