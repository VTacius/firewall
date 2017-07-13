function ["FindProxyForURL"](url,host)
    if (
        dnsDomainIs(host, "mh.gob.sv") ||
        dnsDomainIs(host, "salud.gob.sv") ||
        isInNet(host, "10.20.20.0", "255.255.255.0") || 
        isInNet(host, "10.30.20.0", "255.255.255.0")) { 
        return "DIRECT";
    }else if (url.substring(0, 5) == "http:") {
        return "PROXY 10.20.20.1:3128";
    }else if (url.substring(0, 6) == "https:") {
        return "PROXY 10.20.20.1:3128";
    }
}
