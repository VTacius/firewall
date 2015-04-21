{% assign items = (site.instalacion | sort: 'orden') %}
{% for album in items %}
    <li>
        {% assign direccion =  {{album.url}} | prepend:{{site.baseurl}} | remove: "index.html" %}
        <a href="{{ direccion }}">{{ album.title }}</a>
    </li>
{% endfor %}
</ul>


