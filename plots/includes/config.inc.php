<?php 
$config['rewrite_short_tags'] = FALSE;
$live = FALSE;
$email = 'joshuairungu12@gmail.com';
function my_error_handler($e_number, $e_message, $e_file,$e_line, $e_vars) {
	global $live, $email;
	$message = "An error occurred in script '$e_file' on line $e_line:\n<br />$e_message\n<br />";
	$message .= "Date/Time: " . date('n-j-Y H:i:s') . "\n<br />";
	$message .= "<pre>" . print_r($e_vars, 1) . "</pre>\n<br />";
	if ($live) {error_log ($message, 1, $email);
		  if ($e_number != E_NOTICE) {
				echo '<div id="Error">A system error occurred. We apologize for the inconvenience.</div><br />';
		  }
	} else {
		echo '<div id="Error">' .$message . '</div><br />';
	}
}
set_error_handler ('my_error_handler');
?>






