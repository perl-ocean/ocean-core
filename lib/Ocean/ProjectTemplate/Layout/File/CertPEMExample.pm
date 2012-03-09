package Ocean::ProjectTemplate::Layout::File::CertPEMExample;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'cert.pem'       }

1;

__DATA__
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            a5:c2:7b:d1:a2:e7:e6:a2
        Signature Algorithm: md5WithRSAEncryption
        Issuer: C=JP, ST=Tokyo, L=Setagaya, O=lyokato.net, OU=lyokato.net, CN=Lyo Kato
        Validity
            Not Before: Apr 23 03:08:37 2010 GMT
            Not After : Apr 23 03:08:37 2011 GMT
        Subject: C=JP, ST=Tokyo, L=Setagaya, O=lyokato.net, OU=lyokato.net, CN=Lyo Kato
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
            RSA Public Key: (1024 bit)
                Modulus (1024 bit):
                    00:cf:ca:df:ef:e3:5d:31:39:6f:01:95:f3:75:c1:
                    d1:3b:67:6d:cb:27:90:42:bf:34:4a:02:10:af:b2:
                    ba:84:7e:8c:4d:15:e5:ab:60:7c:3e:82:17:bf:98:
                    6c:86:e9:01:b8:7b:04:c4:a1:20:75:90:76:9a:56:
                    dd:07:29:33:c5:8d:b4:58:e9:8d:c3:12:87:4f:d2:
                    f8:b0:fc:cb:98:f7:92:18:e4:9d:db:9c:04:06:94:
                    b9:1a:cc:70:33:17:f0:f6:77:e3:98:3e:85:df:b9:
                    6f:f8:05:31:c2:08:b8:39:4e:54:12:e8:c7:dc:9e:
                    52:9c:03:53:d1:35:4d:49:79
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                53:90:4B:7A:EE:7D:2F:FA:DD:98:31:73:EF:1F:D5:01:7A:13:74:DE
            X509v3 Authority Key Identifier: 
                keyid:64:36:CA:1E:23:50:74:C9:34:E9:01:77:89:F4:D9:52:C3:4B:45:17
                DirName:/C=JP/ST=Tokyo/L=Setagaya/O=lyokato.net/OU=lyokato.net/CN=Lyo Kato
                serial:A5:C2:7B:D1:A2:E7:E6:A1

    Signature Algorithm: md5WithRSAEncryption
        80:9a:0e:2d:16:55:3b:07:6e:76:6f:57:b2:8c:b7:65:86:ae:
        cf:31:18:40:e1:b1:ac:ae:d8:a4:f4:eb:8a:63:14:61:2a:5d:
        8c:55:ec:e9:5b:ec:d7:cb:43:4b:84:6a:84:5f:ba:8b:fe:76:
        96:be:d0:e0:79:1e:f2:e4:e3:f4:f1:0a:a4:cb:6c:d8:08:b0:
        f1:68:d2:c2:6f:2b:ec:e1:b9:01:a4:e1:5e:f1:c5:21:75:7c:
        f2:dc:01:f1:d7:58:37:01:1d:41:73:dc:1b:3e:39:ec:29:75:
        69:02:cf:a9:25:70:83:f5:4d:0b:99:d2:2f:26:09:14:a1:4e:
        6b:ee
-----BEGIN CERTIFICATE-----
MIIDXDCCAsWgAwIBAgIJAKXCe9Gi5+aiMA0GCSqGSIb3DQEBBAUAMG8xCzAJBgNV
BAYTAkpQMQ4wDAYDVQQIEwVUb2t5bzERMA8GA1UEBxMIU2V0YWdheWExFDASBgNV
BAoTC2x5b2thdG8ubmV0MRQwEgYDVQQLEwtseW9rYXRvLm5ldDERMA8GA1UEAxMI
THlvIEthdG8wHhcNMTAwNDIzMDMwODM3WhcNMTEwNDIzMDMwODM3WjBvMQswCQYD
VQQGEwJKUDEOMAwGA1UECBMFVG9reW8xETAPBgNVBAcTCFNldGFnYXlhMRQwEgYD
VQQKEwtseW9rYXRvLm5ldDEUMBIGA1UECxMLbHlva2F0by5uZXQxETAPBgNVBAMT
CEx5byBLYXRvMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDPyt/v410xOW8B
lfN1wdE7Z23LJ5BCvzRKAhCvsrqEfoxNFeWrYHw+ghe/mGyG6QG4ewTEoSB1kHaa
Vt0HKTPFjbRY6Y3DEodP0viw/MuY95IY5J3bnAQGlLkazHAzF/D2d+OYPoXfuW/4
BTHCCLg5TlQS6MfcnlKcA1PRNU1JeQIDAQABo4H/MIH8MAkGA1UdEwQCMAAwLAYJ
YIZIAYb4QgENBB8WHU9wZW5TU0wgR2VuZXJhdGVkIENlcnRpZmljYXRlMB0GA1Ud
DgQWBBRTkEt67n0v+t2YMXPvH9UBehN03jCBoQYDVR0jBIGZMIGWgBRkNsoeI1B0
yTTpAXeJ9NlSw0tFF6FzpHEwbzELMAkGA1UEBhMCSlAxDjAMBgNVBAgTBVRva3lv
MREwDwYDVQQHEwhTZXRhZ2F5YTEUMBIGA1UEChMLbHlva2F0by5uZXQxFDASBgNV
BAsTC2x5b2thdG8ubmV0MREwDwYDVQQDEwhMeW8gS2F0b4IJAKXCe9Gi5+ahMA0G
CSqGSIb3DQEBBAUAA4GBAICaDi0WVTsHbnZvV7KMt2WGrs8xGEDhsayu2KT064pj
FGEqXYxV7Olb7NfLQ0uEaoRfuov+dpa+0OB5HvLk4/TxCqTLbNgIsPFo0sJvK+zh
uQGk4V7xxSF1fPLcAfHXWDcBHUFz3Bs+OewpdWkCz6klcIP1TQuZ0i8mCRShTmvu
-----END CERTIFICATE-----
