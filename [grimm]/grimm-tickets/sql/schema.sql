CREATE TABLE IF NOT EXISTS `grimm_tickets` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `ticket_id` VARCHAR(10) NOT NULL UNIQUE,
    `citizen_id` VARCHAR(50) NOT NULL,
    `player_name` VARCHAR(100) NOT NULL,
    `discord_thread_id` VARCHAR(50) DEFAULT NULL,
    `status` ENUM('open', 'closed') DEFAULT 'open',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `closed_at` TIMESTAMP NULL,
    `closed_by` VARCHAR(100) DEFAULT NULL,
    INDEX `idx_citizen` (`citizen_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_thread` (`discord_thread_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `grimm_ticket_messages` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `ticket_id` VARCHAR(10) NOT NULL,
    `sender_type` ENUM('player', 'staff') NOT NULL,
    `sender_name` VARCHAR(100) NOT NULL,
    `message` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ticket_id`) REFERENCES `grimm_tickets`(`ticket_id`) ON DELETE CASCADE,
    INDEX `idx_ticket` (`ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
