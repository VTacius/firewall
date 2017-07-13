<?php
	include_once('categorias.php');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">    
 	<title>Contenido Bloqueado</title>
    <link href="http://<<ipaddresslan>>/script/default.css" rel="stylesheet" type="text/css"></script>  
    <link rel="shortcut icon" href="http://<<ipaddresslan>>/favicon.ico" />
</head>
	<body>
	<center>
  	<table summary="" cellpadding="0" cellspacing="0">
	    <tbody>
        <tr>
            <td class="fieldset_nw"></td>	
            <td class="headlineerror" nowrap="nowrap"><img src="http://<<ipaddresslan>>/img/warning.png" class="warning" align="left">Contenido Bloqueado</td>
            <td class="fieldset_ne"></td>
        </tr>
        <tr>
            <td class="fieldset_w"><img src="http://<<ipaddresslan>>/img/blank1x1.gif" alt="" height="1" width="1"></td>
            <td class="fieldset_c">
                <table class="table" valign="top" cellpadding="8" cellspacing="0" border="0" summary="">
                    <tbody>
                        <tr>
	                        <td colspan = "2" align="center"><div><img src="http://<<ipaddresslan>>/img/logo.jpg" alt="<<MarcadorInstitucion>>"><div></td>   
                        </tr> 
                        <tr>
                            <td class="table_key">Mientras se intentaba acceder a:</td>
                            <td class="table_value"><b><?php print $_GET['purl'] ?></b></td>
                        </tr>
                        <tr>
                            <td class="table_key">El contenido se ha bloqueado por la siguiente razón</td>
                            <td class="table_value">El sitio pertenece a la categoría <b><?php print $categorias[$_GET['razon']]?></b></td>
                        </tr>
                        <tr>
                            <td class="table_key">Institución :</td>
                            <td class="table_value"><div class="table_value"><<MarcadorInstitucion>></div></td>
                        </tr>   
                    </tbody>
                    </table>
            </td>
			<td class="fieldset_e"><img src="http://<<ipaddresslan>>/img/blank1x1.gif" alt="" height="1" width="1"></td>
        </tr>
        <tr>
            <td class="fieldset_sw"><img src="http://<<ipaddresslan>>/img/blank1x1.gif" alt="" height="1" width="1"></td>
            <td class="fieldset_sc"><img src="http://<<ipaddresslan>>/img/blank1x1.gif" alt="" height="1" width="1"></td>
            <td class="fieldset_se"><img src="http://<<ipaddresslan>>/img/blank1x1.gif" alt="" height="1" width="1"></td>
        </tr>
        <tr>
            <td colspan="3">
                <table summary="" cellpadding="0" cellspacing="0" class="footer">
                    <tbody>
                    <tr>
                        <td class="footer_w"><img src="http://<<ipaddresslan>>/img/blank1x1.gif" alt="" height="1" width="1"></td>
                        <td class="footer_c"><img src="http://<<ipaddresslan>>/img/blank1x1.gif" alt="" height="1" width="1"></td>
                        <td class="footer_e"><div class="subheadline" style="font-size:8pt;margin: 15px 20px;">DTIC</div><img src="http://<<ipaddresslan>>/img/blank1x1.gif" alt="" height="1" width="1"></td>
                    </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        </tbody>
    </table>
    </center>
    </body>
</html>
