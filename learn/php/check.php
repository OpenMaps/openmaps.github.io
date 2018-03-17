<?php
$search=$_REQUEST['search']
$sql = "SELECT ID FROM posts WHERE username LIKE %$search% OR subject LIKE %$search% OR content LIKE %$search%;" $dblink = mysql_connect("localhost", "mysql_user", "mysql_password"); mysql_select_db("DB1", $dblink); $result = mysql_query($sql, $dblink); while ($row = mysql_fetch_assoc($result)) {
} ?>

<div class="container">
  <h2>Bootstrap Mixed Form <p class="lead">with horizontal and inline fields</p></h2>
  <form role="form" class="form-horizontal">
    <div class="form-group">
      <label class="col-sm-1" for="inputEmail1">Email</label>
      <div class="col-sm-5"><input class="form-control" id="inputEmail1" placeholder="Email" type="email"></div>
    </div>
    <div class="form-group">
      <label class="col-sm-1" for="inputPassword1">Password</label>
      <div class="col-sm-5"><input class="form-control" id="inputPassword1" placeholder="Password" type="password"></div>
    </div>
    <div class="form-group">
      <label class="col-sm-12" for="TextArea">Textarea</label>
      <div class="col-sm-6"><textarea class="form-control" id="TextArea"></textarea></div>
    </div>
    <div class="form-group">
      <div class="col-sm-3"><label>First name</label><input class="form-control" placeholder="First" type="text"></div>
      <div class="col-sm-3"><label>Last name</label><input class="form-control" placeholder="Last" type="text"></div>
    </div>
    <div class="form-group">
      <label class="col-sm-12">Phone number</label>
      <div class="col-sm-1"><input class="form-control" placeholder="000" type="text"><div class="help">area</div></div>
      <div class="col-sm-1"><input class="form-control" placeholder="000" type="text"><div class="help">local</div></div>
      <div class="col-sm-2"><input class="form-control" placeholder="1111" type="text"><div class="help">number</div></div>
      <div class="col-sm-2"><input class="form-control" placeholder="123" type="text"><div class="help">ext</div></div>
    </div>
    <div class="form-group">
      <label class="col-sm-1">Options</label>
      <div class="col-sm-2"><input class="form-control" placeholder="Option 1" type="text"></div>
      <div class="col-sm-3"><input class="form-control" placeholder="Option 2" type="text"></div>
    </div>
    <div class="form-group">
      <div class="col-sm-6">
        <button type="submit" class="btn btn-info pull-right">Submit</button>
      </div>
    </div>
  </form>
  <hr>
</div>

<form method="post" action="/search-results/">
<select id="roomtypesel" name="cat[]">
<option value="">Room type</option>
{exp:channel:categories channel="products" category_group="1" style="linear"}
<option value="{category_id}">{category_name}</option>
{/exp:channel:categories}
</select>
<select id="flooringtype" name="cat[]">
<option value="">Flooring type</option>
{exp:channel:categories channel="products" category_group="2" style="linear"}
<option value="{category_id}">{category_name}</option>
{/exp:channel:categories}
</select>
<select id="colourtype" name="cat[]">
<option value="">Colour type</option>
{exp:channel:categories channel="products" category_group="3" style="linear"}
<option value="{category_id}">{category_name}</option>
{/exp:channel:categories}
</select>
<input type="submit" value="Find products" />
</form>

<?php
// Grab the categories selected from the $_POST
// join them with an ampersand - we are searching for AND matches
$cats = "";
foreach($_POST['cat'] as $cat){
// check we are working with a number
if(is_numeric($cat)){
$cats .= $cat."&";
}
}
// strip the last & off the category string
$cats = substr($cats,0,-1);
?>

{exp:channel:entries channel="products" dynamic="on" category="<?php echo($cats);?>" orderby="price" sort="asc"}