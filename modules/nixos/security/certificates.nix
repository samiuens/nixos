{
  config,
  lib,
  ...
}:

let
  cfg = config.smi.security;
  caBundle = "/etc/ssl/certs/ca-certificates.crt";
in
{
  config = lib.mkIf cfg.enable {
    # Bun, uv and certifi trust their bundled roots unless pointed at the system store,
    # so they miss distrusts in security.pki (e.g. the eMudhra compromise, CVE-2026-111943).
    environment.sessionVariables = {
      SSL_CERT_FILE = caBundle;
      NIX_SSL_CERT_FILE = caBundle;
    };
  };
}
