import ./make-test.nix (
  { pkgs, ... }:
    let
      runWithOpenSSL = file: cmd: pkgs.runCommand file {
        buildInputs = [ pkgs.openssl ];
      } cmd;

      key = runWithOpenSSL "key.pem" ''
        openssl genrsa -out $out 2048
      '';
      csr = runWithOpenSSL "csr.csr" ''
        openssl req -new -sha256 -key ${key} -out $out -subj "/CN=localhost"
      '';
      cert = runWithOpenSSL "cert.pem" ''
        openssl req -x509 -sha256 -days 365 -key ${key} -in ${csr} -out $out
      '';
    in
      {
        name = "nginx";
        nodes.default = {
          kampka.services.nginx = {
            enable = true;
            dhParamBytes = 128; # probably unwise in production, but faster in tests
          };
          services.nginx.virtualHosts.default = {
            default = true;
            forceSSL = true;

            sslCertificate = cert;
            sslCertificateKey = key;
          };
        };

        testScript =
          ''
            default.wait_for_unit("nginx.service")
            default.wait_for_open_port(80)
            default.wait_for_open_port(443)
          '';
      }
)
