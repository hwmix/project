<?php
include 'db_config.php';

$data = json_decode(file_get_contents("php://input"), true);

$id = $data['id'] ?? null;
$name = $data['name'] ?? null;
$type = $data['type'] ?? null;
$status = $data['status'] ?? null;

if (!$id) {
    echo json_encode(["message" => "Error: ID is required"]);
    exit;
}

// ใช้ Prepared Statement ป้องกัน SQL Injection
if ($name !== null && $type !== null && $status !== null) {
    $sql = "UPDATE devices SET name=?, type=?, status=? WHERE id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssi", $name, $type, $status, $id);
} elseif ($status !== null) {
    $sql = "UPDATE devices SET status=? WHERE id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("si", $status, $id);
} else {
    echo json_encode(["message" => "Error: Invalid data"]);
    exit;
}

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Updated successfully", "updated_status" => $status]);
} else {
    echo json_encode(["message" => "Error: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
