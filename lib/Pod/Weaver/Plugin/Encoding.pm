package Pod::Weaver::Plugin::Encoding;
# ABSTRACT: (DEPRECATED) Add an encoding command to your POD

our $VERSION = '0.03';

use Moose;
use List::Util 1.33 'any';
use MooseX::Types::Moose qw(Str);
use aliased 'Pod::Elemental::Node';
use aliased 'Pod::Elemental::Element::Pod5::Command';
use namespace::autoclean -also => 'find_encoding_command';

with 'Pod::Weaver::Role::Finalizer';

=head1 SYNOPSIS

In your weaver.ini:

  [-Encoding]

or

  [-Encoding]
  encoding = koi8-r

=head1 DESCRIPTION

This section will add an C<=encoding> command like

  =encoding UTF-8

to your POD.

=attr encoding

The encoding to declare in the C<=encoding> command. Defaults to
C<UTF-8>.

=cut

has encoding => (
    is      => 'ro',
    isa     => Str,
    default => 'UTF-8',
);

=method finalize_document

This method prepends an C<=encoding> command with the content of the
C<encoding> attribute's value to the document's children.

Does nothing if the document already has an C<=encoding> command.

=cut

sub finalize_document {
    my ($self, $document) = @_;

    return if find_encoding_command($document->children);

    unshift @{ $document->children },
        Command->new({
            command => 'encoding',
            content => $self->encoding,
        }),
}

sub find_encoding_command {
    my ($children) = @_;
    return any {
        ($_->isa(Command) && $_->command eq 'encoding')
        || ($_->does(Node) && find_encoding_command($_->children));
    } @$children;
}

=head1 SEE ALSO

L<Pod::Weaver::Section::Encoding> is very similar to this module, but
expects the encoding to be specified in a special comment within the
document that's being woven.

L<Pod::Weaver::Plugin::SingleEncoding> can be considered the successor to this
module, and is a core part of L<Pod::Weaver> version 4. It is contained within
L<[@Default]|Pod::Weaver::PluginBundle::Default>, and you should be using
that plugin rather than this one.

=cut

__PACKAGE__->meta->make_immutable;

1;
