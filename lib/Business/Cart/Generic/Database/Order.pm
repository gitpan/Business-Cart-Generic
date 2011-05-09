package Business::Cart::Generic::Database::Order;

use strict;
use warnings;

use Moose;

extends 'Business::Cart::Generic::Database::Base';

use namespace::autoclean;

our $VERSION = '0.82';

# --------------------------------------------------

sub add_to_cart
{
	my($self, $order) = @_;

	$self -> db -> logger -> log(debug => 'add_to_cart()');

	# Note: save_order() sets $$order{id}, and both
	# save_order() and save_order_history() use $$order{status_id}.

	my($order_session) = $self -> db -> session -> param('order');
	my(@status2id)     = $self -> schema -> resultset('OrderStatuse') -> search({}, {columns => [qw/name id/]});
	my(%status2id)     = map{($_ -> name, $_ -> id)} @status2id;
	my($status)        = 'Processing';
	$$order{status_id} = $status2id{$status};

	# Is it a new order?

	if ($$order_session{item_count} == 0)
	{
		$self -> save_order($order);

		$$order_session{id} = $$order{id};
	}
	else
	{
		$$order{id} = $$order_session{id};
	}

	$$order_session{item_id} = $$order{item_id} = $self -> save_order_item($order);

	$self -> save_order_history($order);

	$$order_session{item_count}++;

	$self -> db -> session -> param(order => $order_session);
	$self -> db -> logger -> log(info => "Order item saved. id: $$order{id}. item id: $$order{item_id}. item count: $$order_session{item_count}");

	return $order_session;

} # End of add_to_cart.

# --------------------------------------------------

sub cancel_order
{
	my($self) = @_;

	$self -> db -> logger -> log(debug => 'cancel_order()');

	my($order_session) = $self -> db -> session -> param('order');

	$self -> schema -> resultset('OrderHistory') -> search({order_id => $$order_session{id} }) -> delete;
	$self -> schema -> resultset('OrderItem') -> search({order_id => $$order_session{id} }) -> delete;
	$self -> schema -> resultset('Order') -> search({id => $$order_session{id} }) -> delete;
	$self -> db -> logger -> log(info => "Order cancelled: id: $$order_session{id}");
	$self -> db -> reset_order;

} # End of cancel_order.

# --------------------------------------------------

sub checkout
{
	my($self) = @_;

	$self -> db -> logger -> log(debug => 'checkout()');

	my($order_session)          = $self -> db -> session -> param('order');
	my($order_db)               = $self -> schema -> resultset('Order') -> search({id => $$order_session{id} }) -> single;
	my($order_inflated)         = $self -> inflate_order($order_db);
	my(@status2id)              = $self -> schema -> resultset('OrderStatuse') -> search({}, {columns => [qw/name id/]});
	my(%status2id)              = map{($_ -> name, $_ -> id)} @status2id;
	$$order_inflated{status}    = 'Checked out';
	$$order_inflated{status_id} = $status2id{$$order_inflated{status} };

	my($option);
	my($product);

	for my $item (@{$$order_inflated{item} })
	{
		$self -> db -> logger -> log(debug => "Updating product. id: $$item{product_id}");

		$product = $self -> schema -> resultset('Product') -> search({id => $$item{product_id} }) -> single;
		$option  =
		{
			quantity_on_hand => $product -> quantity_on_hand - $$item{quantity},
			quantity_ordered => $product -> quantity_ordered + $$item{quantity},
		};

		$product -> update($option);
	}

	$self -> db -> logger -> log(debug => "Updating order. id: $$order_session{id}");

	$option =
	{
		date_completed  => \'now()',
		date_modified   => \'now()',
		order_status_id => $$order_inflated{status_id},
	};

	$order_db -> update($option);

	# Note: save_order_history() inserts item_id into the comment field in the order_history table.

	$$order_inflated{item_id} = $$order_session{item_id};

	$self -> save_order_history($order_inflated);

} # End of checkout.

# --------------------------------------------------

sub get_orders
{
	my($self, $limit) = @_;
	$limit ||= {};

	$self -> db -> logger -> log(debug => 'get_orders()');

	return scalar $self -> schema -> resultset('Order') -> search
		(
		 $limit,
		 {
			 join     => [qw/billing_address customer customer_address delivery_address order_status payment_method/],
			 order_by => [qw/me.date_added/],
		 }
		);

} # End of get_orders.

# --------------------------------------------------

sub inflate_order
{
	my($self, $order) = @_;

	$self -> db -> logger -> log(debug => 'inflate_order()');

	my($id)      = $order -> id;
	my $item_set = $self -> schema -> resultset('OrderItem') -> search
		(
		 {
			 order_id => $id
		 },
		 {
			 join     => [qw/product/],
			 order_by => [qw/product.name/],
		 }
		);
	my(%total) =
		(
		 price    => 0,
		 quantity => 0,
		 tax      => 0,
		);

	my(@item);
	my($value);

	while (my $item = $item_set -> next)
	{
		$value           = $item -> quantity * $item -> price;
		$total{price}    += $value;
		$total{quantity} += $item -> quantity;
		$total{tax}      += $value * $item -> tax_rate;

		push @item,
		{
			currency_id => $item -> product -> currency_id,
			description => $item -> product -> description,
			item_id     => $item -> id,
			name        => $item -> name,
			order_id    => $item -> order_id,
			price       => $item -> price,
			product_id  => $item -> product_id,
			quantity    => $item -> quantity,
			tax_rate    => $item -> tax_rate,
		};
	}

	return
	{
		billing_address =>
		{
			country_name => $order -> billing_address -> country -> name,
			locality     => $order -> billing_address -> locality,
			street_1     => $order -> billing_address -> street_1,
			zone_name    => $order -> billing_address -> zone -> name,
		},
		customer =>
		{
			name  => $order -> customer -> name,
			title => $order -> customer -> title -> name,
		},
		customer_address =>
		{
			country_name => $order -> customer_address -> country -> name,
			locality     => $order -> customer_address -> locality,
			street_1     => $order -> customer_address -> street_1,
			zone_name    => $order -> customer_address -> zone -> name,
		},
		delivery_address =>
		{
			country_name => $order -> delivery_address -> country -> name,
			locality     => $order -> delivery_address -> locality,
			street_1     => $order -> delivery_address -> street_1,
			zone_name    => $order -> delivery_address -> zone -> name,
		},
		date_added     => $order -> date_added,
		date_completed => $order -> date_completed,
		id             => $id,
		item           => [@item],
		order_status   => $order -> order_status -> name,
		payment_method => $order -> payment_method -> name,
		total_price    => $total{price},
		total_quantity => $total{quantity},
		total_tax      => $total{tax},
	};

} # End of inflate_order.

# --------------------------------------------------

sub remove_from_cart
{
	my($self, $order_id, $item_id) = @_;

	$self -> db -> logger -> log(debug => "remove_from_cart($order_id, $item_id)");

	$self -> schema -> resultset('OrderItem') -> search({id => $item_id}) -> delete;

	if ($self -> db -> decrement_order_items($order_id) == 0)
	{
		$self -> cancel_order;
	}

} # End of remove_from_cart.

# --------------------------------------------------

sub save_order
{
	my($self, $order) = @_;

	$self -> db -> logger -> log(debug => 'save_order()');

	my($rs)     = $self -> schema -> resultset('Order');
	my($result) = $rs -> create
		({
			billing_address_id  => $$order{billing_address_id},
			customer_address_id => $$order{customer_address_id},
			customer_id         => $$order{customer_id},
			date_added          => \'now()',
			date_completed      => \'now()',
			date_modified       => \'now()',
			delivery_address_id => $$order{delivery_address_id},
			order_status_id     => $$order{status_id},
			payment_method_id   => $$order{payment_method_id},
		});
	my($fix_quote) = \'now()';
	$$order{id}    = $result -> id;

} # End of save_order.

# --------------------------------------------------

sub save_order_history
{
	my($self, $order) = @_;

	$self -> db -> logger -> log(debug => 'save_order_history()');

	my($rs)          = $self -> schema -> resultset('OrderHistory');
	my(@yesno2id)    = $self -> schema -> resultset('YesNo') -> search({}, {columns => [qw/name id/]});
	my(%yesno2id)    = map{($_ -> name, $_ -> id)} @yesno2id;
	my($notified_id) = $yesno2id{'No'};
	my($result)      = $rs -> create
		({
			comment              => "item_id: $$order{item_id}",
			date_added           => \'now()',
			date_modified        => \'now()',
			customer_notified_id => $notified_id,
			order_id             => $$order{id},
			order_status_id      => $$order{status_id},
		 });

} # End of save_order_history.

# --------------------------------------------------

sub save_order_item
{
	my($self, $order) = @_;

	$self -> db -> logger -> log(debug => 'save_order_item()');

	my($product)  = $self -> schema -> resultset('Product') -> search({id => $$order{product_id} },{}) -> single;
	my($tax_rate) = $self -> schema -> resultset('TaxRate') -> search({tax_class_id => $$order{tax_class_id}, zone_id => $$order{zone_id} }, {}) -> single;
	my($rs)       = $self -> schema -> resultset('OrderItem');
	my($result)   = $rs -> create
		({
			model      => $product -> model,
			name       => $product -> name,
			order_id   => $$order{id},
			price      => $product -> price,
			product_id => $$order{product_id},
			quantity   => $$order{quantity},
			tax_rate   => $tax_rate -> rate,
			upper_name => uc $product -> name,
		 });

	return $result -> id;

} # End of save_order_item.

# --------------------------------------------------

__PACKAGE__ -> meta -> make_immutable;

1;
