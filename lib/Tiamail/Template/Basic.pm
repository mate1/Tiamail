package Tiamail::Template::Basic;

use strict;
use warnings;

use base qw( Tiamail::Template );

=doc 

Very basic/simple Tiamail template.

Does a search/replace on ##field## replacing it with args{field}


=cut

sub render {
	my ($self, $id, $template_id, $base_url, $tracking, $params) = @_;

	my $body = $self->{args}->{body};
	my $headers = $self->{args}->{headers};
	
	# some sanity cleanup after headers
	$headers =~ s/[\r\n]+$//;

	$headers = $self->_search_replace($headers, $params);
	$body = $self->_search_replace($body, $params);
	if ($tracking) {
		$body = $self->_add_tracking($body, $id, $template_id, $base_url);
	}
	return $headers . "\n\n" . $body;
}


sub _search_replace {
	my ($self,$content,$params) = @_;

	my @replace = $content =~ m/##(.*?)##/g;
	foreach my $key (@replace) {
		unless ($params->{$key}) {
			die "expected $key in params and did not receive it";
		}
		$content =~ s/##$key##/$params->{$key}/g;
	}
	return $content;
}

sub _add_tracking {
	my ($self, $content, $id, $template_id, $base_url) = @_;	

	# ugly matching, this will fail spectacularly if html strays from what these regexes expect.
	# ideally do this via a proper html grammar parser but this is the basic template, 
	# so you get what you paid for.

	$base_url =~ s/\/$//;
	
	# add our tracking image after body
	$content =~ s#(<body.*?>)#$1 <img src="$base_url/x.gif/$id/$template_id"/>#;

	# add our hrefs
	$content =~ s#(a\s+href=["'])(.*?)['"]#$1$base_url/r/$id/$template_id/$2#;

	return $content;
}

1;
