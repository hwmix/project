<?php
include 'db_config.php';
$data = json_decode(file_get_contents("php://input"), true);

$id = $data['id'];

$sql = "DELETE FROM devices WHERE id=$id";
if ($conn->query($sql) === TRUE) {
    echo json_encode(["message" => "Deleted successfully"]);
} else {
    echo json_encode(["message" => "Error: " . $conn->error]);
}
$conn->close();
?>
