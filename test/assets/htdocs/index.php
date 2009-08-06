<html>
  <head>
    <title>
Hello
    </title>
  </head>
  <body>
    <h1>Get Params</h1>
    <table id="get">
<?php
      foreach($_GET as $key => $val) {
?>
      <tr>
        <td><?php echo $key; ?></td>
        <td><?php echo $val; ?></td>
      </tr>
<?php
      }
?>
    </table>
  </body>
</html>
