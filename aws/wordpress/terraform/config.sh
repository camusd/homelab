#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y php56 httpd24 php56-opcache php56-mysqlnd php56-pecl-redis git varnish

sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
echo 'DAEMON_OPTS="-a :80 \
             -T localhost:6082 \
             -b localhost:8080 \
             -f /etc/varnish/default.vcl \
             -u varnish -g varnish \
             -S /etc/varnish/secret \
             -s file,/var/lib/varnish/varnish_storage.bin,1G"' | sudo tee -a /etc/sysconfig/varnish

echo '

acl purge {

  "localhost";

  "&lt;server ip address or hostname&gt;";

}

sub vcl_recv {
  set req.http.cookie = regsuball(req.http.cookie, "wp-settings-\d+=[^;]+(; )?", "");

  set req.http.cookie = regsuball(req.http.cookie, "wp-settings-time-\d+=[^;]+(; )?", "");

  set req.http.cookie = regsuball(req.http.cookie, "wordpress_test_cookie=[^;]+(; )?", "");

  ampif (req.http.cookie == "") {

    unset req.http.cookie;

  }

  if (req.restarts == 0) {
    if (req.http.x-forwarded-for) {
      set req.http.X-Forwarded-For =
      req.http.X-Forwarded-For + ", " + client.ip;
 	} else {
 	  set req.http.X-Forwarded-For = client.ip;
 	}
  }
  if (req.request != "GET" &&
      req.request != "HEAD" &&
      req.request != "PUT" &&
      req.request != "POST" &&
      req.request != "TRACE" &&
      req.request != "OPTIONS" &&
      req.request != "DELETE") {

    /* Non-RFC2616 or CONNECT which is weird. */
    return (pipe);
  }
  if (req.request != "GET" && req.request != "HEAD") {
    /* We only deal with GET and HEAD by default */
    return (pass);
  }
  if (req.http.Authorization || req.http.Cookie) {
    /* Not cacheable by default */
    return (pass);
  }
  return (lookup);
}

if (req.url ~ "wp-admin|wp-login") {

  return (pass);

}

sub vcl_backend_response {
  if (beresp.ttl == 120s) {
    set beresp.ttl = 1h;
  }
}

if (req.method == "PURGE") {

  if (client.ip !~ purge) {

    return (synth(405));

  }

  if (req.http.X-Purge-Method == "regex") {

    ban("req.url ~ " + req.url + " && req.http.host ~ " + req.http.host);

    return (synth(200, "Banned."));

  } else {

    return (purge);

  }
}' | sudo tee -a /etc/varnish/default.vcl

sudo chkconfig httpd on
sudo chkconfig varnish on
sudo service httpd start
sudo service varnish start
