package Tiamail::Sender;

use strict;
use warnings;

use base qw( Tiamail::Base );

sub _verify {
	my $self = shift;
	unless ($self->{args}->{template}) {
		die "template not specified";
	}
	unless ($self->{args}->{persist}) {
		die "persist not specified";
	}
	unless ($self->{args}->{mta}) {
		die "MTA not specified";
	}
	unless ($self->{args}->{from}) {
		die "from not specified";
	}
	unless ($self->{args}->{recorder}) {
		die "recorder not specified";
	}
}

sub send {
	my ($self) = @_;

	$self->_verify();

	while (my ($email, $template_data) = $self->{args}->{persist}->get_entry()) {
		my $mta_id = $self->{args}->{mta}->send(
				$self->{args}->{from},
				$email,
				$self->{args}->{template}->render($template_data)
			);
		
		if ($mta_id) {
			$self->{args}->{recorder}->record_email_send(
				$template_data->{ $self->{args}->{template}->{id} },
				$self->{args}->{template}->{template_id},
				$mta_id,
			);

			$self->{args}->{persist}->remove_entry($email);
		}
		else {
			die sprintf("Send failed for %s\n", $email);
		}

	}
}


1;
