<?php
error_reporting(E_ERROR | E_PARSE);
ini_set('display_errors', '1');
//include('config.php');

$variables = file('/etc/openvpn/login/config.sh', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

foreach ($variables as $config){
  list($key, $value) = explode('=', $config, 2);
  if ($value != null){
    $key = trim($key);
    $value = trim($value);
    $$key = strval(str_replace("'", "", $value));
  }
}

$DB_host = $HOST;
$DB_user = $USER;
$DB_pass = $PASS;
$DB_name = $DB;


$mysqli = new MySQLi($DB_host,$DB_user,$DB_pass,$DB_name);
if ($mysqli->connect_error) {
    die('Error : ('. $mysqli->connect_errno .') '. $mysqli->connect_error);
}

function encrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $encryptedPassword=encryptPaswd($paswd,$mykey);
	  return $encryptedPassword;
	}
	 
	function decrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $decryptedPassword=decryptPaswd($paswd,$mykey);
	  return $decryptedPassword;
	}
	 
	function getEncryptKey()
	{
		$secret_key = md5('firenet');
		$secret_iv = md5('philippines');
		$keys = $secret_key . $secret_iv;
		return encryptor('encrypt', $keys);
	}
	function encryptPaswd($string, $key)
	{
	  $result = '';
	  for($i=0; $i<strlen ($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)+ord($keychar));
		$result.=$char;
	  }
		return base64_encode($result);
	}
	 
	function decryptPaswd($string, $key)
	{
	  $result = '';
	  $string = base64_decode($string);
	  for($i=0; $i<strlen($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)-ord($keychar));
		$result.=$char;
	  }
	 
		return $result;
	}
	
	function encryptor($action, $string) {
		$output = false;

		$encrypt_method = "AES-256-CBC";
		
		$secret_key = md5('firenet philippines');
		$secret_iv = md5('philippines firenet');

		
		$key = hash('sha256', $secret_key);
		
		
		$iv = substr(hash('sha256', $secret_iv), 0, 16);

		
		if( $action == 'encrypt' ) {
			$output = openssl_encrypt($string, $encrypt_method, $key, 0, $iv);
			$output = base64_encode($output);
		}
		else if( $action == 'decrypt' ){
			
			$output = openssl_decrypt(base64_decode($string), $encrypt_method, $key, 0, $iv);
		}

		return $output;
	}



$data = '';
$uuid = '';
$premium_active = "status='live' AND is_validated=1 AND is_freeze=0 AND is_ban=0 AND duration > 0";
$vip_active = "status='live' AND is_validated=1 AND is_freeze=0 AND is_ban=0 AND vip_duration > 0";
$private_active = "status='live' AND is_validated=1 AND is_freeze=0 AND is_ban=0 AND private_duration > 0";
$query = $mysqli->query("SELECT * FROM users WHERE ".$premium_active." OR ".$vip_active." OR ".$private_active." ORDER by user_id DESC");
if($query->num_rows > 0)
{
	while($row = $query->fetch_assoc())
	{
		$data .= '';
		$username = $row['user_name'];
		$password = decrypt_key($row['user_pass']);
		$password = encryptor('decrypt',$password);		
		$data .= 'id ' . $username . ' &>/dev/null && echo ' . $username . ':' . $password . ' | chpasswd || useradd -p $(openssl passwd -1 ' . $password . ') -M -s /sbin/nologin ' . $username . PHP_EOL;

		$uuid .= '';
		$v2ray_id = $row['v2ray_id'];
    if($v2ray_id != '')
    {
     $uuid .= ''.$v2ray_id.''.PHP_EOL;
    }
		
	}
}
$location = '/etc/authorization/scriptsrelease/active.sh';
$fp = fopen($location, 'w');
fwrite($fp, $data) or die("Unable to open file!");
fclose($fp);

#In-Active and Invalid Accounts
$data2 = '';
$premium_deactived = "is_validated=0 OR is_freeze=1 OR is_ban=1 OR duration <= 0";
$vip_deactived = "is_validated=0 OR is_freeze=1 OR is_ban=1 OR vip_duration <= 0";
$private_deactived = "is_validated=0 OR is_freeze=1 OR is_ban=1 OR private_duration <= 0";
$all_deactivated = "is_validated=0 OR is_freeze=1 OR is_ban=1 OR (duration <= 0 and vip_duration <= 0 and private_duration <= 0)";

$query2 = $mysqli->query("SELECT * FROM users WHERE is_validated=0 OR is_freeze=1 OR is_ban=1 OR (duration <= 0 AND vip_duration <= 0 AND private_duration <= 0)");
if($query2->num_rows > 0)
{
	while($row2 = $query2->fetch_assoc())
	{
		$data2 .= '';
		$toadd = $row2['user_name'];	
		$data2 .= 'userdel '.$toadd.''.PHP_EOL;
	}
}
$location2 = '/etc/authorization/scriptsrelease/not-active.sh';
$fp = fopen($location2, 'w');
fwrite($fp, $data2) or die("Unable to open file!");
fclose($fp);

$mysqli->close();
?>
Execution Completed! Success without any error
