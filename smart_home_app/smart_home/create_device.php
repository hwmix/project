<?php
include 'db_config.php';
$data = json_decode(file_get_contents("php://input"), true);

$name = $data['name'];
$type = $data['type'];
$status = $data['status'];

$sql = "INSERT INTO devices (name, type, status) VALUES ('$name', '$type', '$status')";
if ($conn->query($sql) === TRUE) {
    echo json_encode(["message" => "Device added successfully"]);
} else {
    echo json_encode(["message" => "Error: " . $conn->error]);
}
$conn->close();
?>
