CREATE TABLE `item` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `category` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `feature` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `item_id` INT(10) UNSIGNED DEFAULT NULL,
  `category_id` INT(10) UNSIGNED DEFAULT NULL,
  `start_date` DATE DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `tbl_feature_id_item_id_foreign` (`item_id`),
  KEY `tbl_feature_id_category_id_foreign` (`category_id`),
  CONSTRAINT `tbl_feature_id_item_id_foreign` FOREIGN KEY (`item_id`) REFERENCES `item` (`id`),
  CONSTRAINT `tbl_feature_id_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `item` (`id`) VALUES (1);

INSERT INTO `category` (`id`, `name`, `created_at`, `updated_at`)
  VALUES
    (1, 'a', '2016-12-02 22:49:46', NULL),
    (2, 'b', '2016-12-02 22:49:48', NULL),
    (3, 'b', '2016-12-02 22:49:48', NULL)
;

INSERT INTO `feature` (`id`, `item_id`, `category_id`, `start_date`, `created_at`, `updated_at`)
    VALUES
        (1,  1, 1, '2016-01-01', NOW(), NOW()),
        (2,  1, 2, '2016-02-01', NOW(), NOW()),
        (3,  1, 2, '2016-02-02', NOW(), NOW()),
        (4,  1, 3, '2016-03-01', NOW(), NOW())
;

ALTER TABLE feature 
  ADD INDEX item_startdate_category (item_id, start_date, category_id)
;

-- http://dba.stackexchange.com/questions/24014/how-do-i-get-the-current-and-next-greater-value-in-one-select 
-- Answer FROM ElBigNigga

-- Get the Most Recent Feature incl. start/end date
-- EXPLAIN 
SELECT 1
    , i.id
    , f1.category_id 
    , f1.start_date  AS "start_date"
    , f3.start_date  AS "end_date"
    , 1 
FROM item i 
    LEFT JOIN feature f1 ON (
        f1.item_id = i.id
    ) 
    LEFT JOIN feature f2 ON (
            f1.item_id = f2.item_id 
        AND f1.start_date < f2.start_date
        AND f2.category_id = 1
    )
    LEFT JOIN feature f3 ON (
            f3.item_id = i.id
        AND f3.start_date > f1.start_date
    ) 
    LEFT JOIN feature f4 ON (
            f3.item_id = f4.item_id  
        AND f3.start_date > f4.start_date 
        AND f3.start_date < f4.start_date
    )
WHERE 1
    AND i.id = 1
    AND f2.item_id IS NULL
    AND f4.item_id IS NULL
ORDER BY i.id DESC 
LIMIT 0
    , 1
;

SELECT 1
    , i.id
    , f1.category_id 
    , f1.start_date  AS "start_date"
    , f3.start_date  AS "end_date"
    , 1 
FROM item i 
    LEFT JOIN feature f1 ON (
        f1.item_id = i.id
    ) 
    LEFT JOIN feature f2 ON (
            f1.item_id = f2.item_id 
        AND f1.start_date < f2.start_date
        AND f2.category_id = 1
    )
    LEFT JOIN feature f3 ON (
            f3.item_id = i.id
        AND f3.start_date > f1.start_date
        AND f3.start_date < f2.start_date
    ) 
WHERE 1
    AND i.id = 1
    AND f2.item_id IS NULL
    AND f4.item_id IS NULL
ORDER BY i.id DESC 
LIMIT 0
    , 1
;
