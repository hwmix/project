<?php
include 'db_config.php';
$result = $conn->query("SELECT * FROM devices");

$devices = [];
while ($row = $result->fetch_assoc()) {
    $devices[] = $row;
}
echo json_encode($devices);
$conn->close();
?>
