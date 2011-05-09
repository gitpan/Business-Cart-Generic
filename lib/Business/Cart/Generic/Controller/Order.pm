package Business::Cart::Generic::Controller::Order;

use parent 'Business::Cart::Generic::Controller';
use strict;
use warnings;

use Business::Cart::Generic::Util::Validator;

use Try::Tiny;

# We don't use Moose because we isa CGI::Application.

our $VERSION = '0.82';

# -----------------------------------------------

sub add_to_cart
{
	my($self) = @_;

	$self -> log(debug => 'add_to_cart()');

	my($message);
	my($order);

	try
	{
		($order, $message) = $self -> param('db') -> connector -> txn(fixup => sub{$self -> add_to_cart_txn_1});
	}
	catch
	{
		$message = $self -> param('templater') -> render('online.order.error.tx', {});
		$message = $self -> param('view') -> format_errors({'Unable to add to cart' => [$message]});
	};

	if (! $message)
	{
		$self -> log(debug => 'Order data is valid');

		try
		{
			$message = $self -> param('db') -> connector -> txn(fixup => sub{$self -> add_to_cart_txn_2($order)});
		}
		catch
		{
			$message = $self -> param('templater') -> render('online.order.error.tx', {});
			$message = $self -> param('view') -> format_errors({'Unable to add to cart' => [$message]});
		};
	}

	return $message;

} # End of add_to_cart.

# -----------------------------------------------

sub add_to_cart_txn_1
{
	my($self) = @_;

	$self -> log(debug => 'add_to_cart_txn_1()');

	my($order) = Business::Cart::Generic::Util::Validator -> new
	(
	 db     => $self -> param('db'),
	 query  => $self -> query,
	) -> validate_order;

	my($message);

	if ($$order{_rejects})
	{
		$self -> log(debug => 'Order data is not valid');

		$message = $self -> param('view') -> format_errors
			($$order{_rejects}{product}
			 ? {product => ['Unknown product, or quantity 0, or quantity ordered > quantity on hand']}
			 : $$order{_rejects});
	}

	return ($order, $message);

} # End of add_to_cart_txn_1.

# -----------------------------------------------

sub add_to_cart_txn_2
{
	my($self, $order) = @_;

	$self -> log(debug => 'add_to_cart_txn_2()');

	my($order_session) = $self -> param('db') -> connector -> txn(fixup => sub{$self -> param('db') -> order -> add_to_cart($order)});

	$order = $self -> param('db') -> order -> get_orders({'me.id' => $$order{id} });

	return $self -> param('view') -> order -> display($order -> single, 'Add', $order_session);

} # End of add_to_cart_txn_2.

# -----------------------------------------------

sub cancel_order
{
	my($self) = @_;

	$self -> log(debug => 'cancel_order()');

	my($message);

	try
	{
		$message = $self -> param('db') -> connector -> txn(fixup => sub{$self -> cancel_order_txn});
	}
	catch
	{
		$message = $self -> param('templater') -> render('online.order.error.tx', {});
		$message = $self -> param('view') -> format_errors({'Unable to cancel order' => [$message]});
	};

	return $message;

} # End of cancel_order.

# -----------------------------------------------

sub cancel_order_txn
{
	my($self) = @_;

	$self -> log(debug => 'cancel_order_txn()');

	$self -> param('db') -> connector -> txn(fixup => sub{$self -> param('db') -> order -> cancel_order});

	return $self -> param('view') -> order -> cancel_order;

} # End of cancel_order_txn.

# -----------------------------------------------

sub cgiapp_init
{
	my($self) = @_;

	$self -> run_modes([qw/add_to_cart cancel_order change_country checkout remove_from_cart/]);

} # End of cgiapp_init.

# -----------------------------------------------

sub change_country
{
	my($self) = @_;

	$self -> log(debug => 'change_country()');

	# TODO Validate $country_id.

	my($country_id) = $self -> query -> param('country_id');

	my($message);

	try
	{
		$message = $self -> param('view') -> order -> change_country($country_id);
	}
	catch
	{
		$message = $self -> param('templater') -> render('online.order.error.tx', {});
		$message = $self -> param('view') -> format_errors({'Unable to change country' => [$message]});
	};

	return $message;

} # End of change_country.

# -----------------------------------------------

sub checkout
{
	my($self) = @_;

	$self -> log(debug => 'checkout()');

	my($message);

	try
	{
		$message = $self -> param('db') -> connector -> txn(fixup => sub{$self -> checkout_txn});
	}
	catch
	{
		$message = $self -> param('templater') -> render('online.order.error.tx', {});
		$message = $self -> param('view') -> format_errors({'Unable to checkout' => [$message]});
	};

	return $message;

} # End of checkout.

# -----------------------------------------------

sub checkout_txn
{
	my($self) = @_;

	$self -> log(debug => 'checkout_txn()');

	$self -> param('db') -> order -> checkout;

	my($message) = $self -> param('view') -> order -> checkout;

	# Note: This must follow the call to view checkout, since the view code
	# checks the item_count in the session to determine which msg to display.

	$self -> param('db') -> reset_order;
	$self -> param('db') -> increment_order_count;

	return $message;

} # End of checkout_txn.

# -----------------------------------------------

sub remove_from_cart
{
	my($self) = @_;

	$self -> log(debug => 'remove_from_cart()');

	my($message);

	try
	{
		$message = $self -> param('db') -> connector -> txn(fixup => sub{$self -> remove_from_cart_txn});
	}
	catch
	{
		$message = $self -> param('templater') -> render('online.order.error.tx', {});
		$message = $self -> param('view') -> format_errors({'Unable to remove from cart' => [$message]});
	}

	return $message;

} # End of remove_from_cart.

# -----------------------------------------------

sub remove_from_cart_txn
{
	my($self) = @_;

	$self -> log(debug => 'remove_from_cart_txn()');

	my($order_id) = $self -> query -> param('order_id');
	my($item_id)  = $self -> query -> param('item_id');

	$self -> param('db') -> order -> remove_from_cart($order_id, $item_id);

	my($order_session) = $self -> param('db') -> session -> param('order');

	my($message);

	if ($$order_session{item_count} == 0)
	{
		$message = $self -> param('view') -> format_note({'Note' => ['All items removed from cart']});
	}
	else
	{
		my($order) = $self -> param('db') -> order -> get_orders({'me.id' => $order_id});
		$message   = $self -> param('view') -> order -> display($order -> single, 'Remove', $order_session);
	}

	return $message;

} # End of remove_from_cart_txn.

# -----------------------------------------------

1;
