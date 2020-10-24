# nm_gql_go_link

A Flutter plugin for a terminating a [package:gql_link][] `Link` with a Go endpoint.

[package:gql_link]: https://pub.dev/packages/gql_link

This is not an officially supported Google product.

## Building

1.  Install [Go][].
1.  `cd nm_gql_go_link`.
1.  Compile the Go code for your target platform. Any combination of:
    *   `go generate -tags android`
    *   `go generate -tags ios`.
    *   `go generate -tags macos`.

After GraphQL schema changes,

1.  `cd nm_gql_go_link`
1.  `flutter pub run build_runner build`

[Go]: https://golang.org
