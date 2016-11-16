-- Get INNODB Status
SHOW ENGINE INNODB STATUS;

SHOW GLOBAL STATUS LIKE "Innodb%"; -- See all

SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_pages_data';  -- IBPDataPages
SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_pages_total'; -- IBPTotalPages
SHOW GLOBAL STATUS LIKE 'Innodb_page_size';               -- IPS

-- Is the performance scheme turned on
SHOW VARIABLES LIKE 'performance_schema';

-- SET GLOBAL userstat=1;

-- FLUSH TABLE_STATISTICS  -- MariaDB 5.2
-- FLUSH INDEX_STATISTICS  -- MariaDB 5.2
-- FLUSH USER_STATISTICS   -- MariaDB 5.2
-- FLUSH CLIENT_STATISTICS -- MariaDB 5.2

SHOW CLIENT_STATISTICS -- MariaDB 5.2
SHOW USER_STATISTICS   -- MariaDB 5.2
SHOW INDEX_STATISTICS  -- MariaDB 5.2
SHOW TABLE_STATISTICS  -- MariaDB 5.2

-- Are slow queries turned on?
SHOW GLOBAL VARIABLES LIKE '%SLOW_QUERY%'
;
-- SET GLOBAL SLOW_QUERY_LOG=1;

SHOW GLOBAL VARIABLES LIKE '%LONG_QUERY%'
;
-- SET GLOBAL LONG_QUERY_TIME=1;

-- innodb_buffer_pool - Caches data and index pages from InnoDB tables accessed

    -- To see the Buffer Pool size IN GB run this:
    SELECT FORMAT(BufferPoolPages*PageSize/POWER(1024,3),2) BufferPoolDataGB FROM
    (SELECT variable_value BufferPoolPages FROM information_schema.global_status
     WHERE variable_name = 'Innodb_buffer_pool_pages_total') A,
    (SELECT variable_value PageSize FROM information_schema.global_status
     WHERE variable_name = 'Innodb_page_size') B
     ;

    -- Actual GB of MEMORY IS IN USE BY INNODB DATA
    SELECT (
        PagesData*PageSize)/POWER(1024,3) DataGB FROM
            (SELECT variable_value PagesData
             FROM information_schema.global_status
             WHERE variable_name='Innodb_buffer_pool_pages_data') A,
            (SELECT variable_value PageSize
             FROM information_schema.global_status
             WHERE variable_name='Innodb_page_size') B
    ;

    -- To see the amount of DATA IN the Buffer Pool size IN GB run this:
    SELECT FORMAT(BufferPoolPages*PageSize/POWER(1024,3),2) BufferPoolDataGB FROM
    (SELECT variable_value BufferPoolPages FROM information_schema.global_status
     WHERE variable_name = 'Innodb_buffer_pool_pages_data') A,
    (SELECT variable_value PageSize FROM information_schema.global_status
     WHERE variable_name = 'Innodb_page_size') B;  

    -- To see the percentage of the Buffer Pool IN USE, run this:
    SELECT CONCAT(FORMAT(DataPages*100.0/TotalPages,2),' %') BufferPoolDataPercentage FROM
    (SELECT variable_value DataPages FROM information_schema.global_status
     WHERE variable_name = 'Innodb_buffer_pool_pages_data') A,
    (SELECT variable_value TotalPages FROM information_schema.global_status
     WHERE variable_name = 'Innodb_buffer_pool_pages_total') B;

    -- To see the Space Taken Up BY Dirty Pages, run this:
    SELECT FORMAT(DirtyPages*PageSize/POWER(1024,3),2) BufferPoolDirtyGB FROM
    (SELECT variable_value DirtyPages FROM information_schema.global_status
     WHERE variable_name = 'Innodb_buffer_pool_pages_dirty') A,
    (SELECT variable_value PageSize FROM information_schema.global_status
     WHERE variable_name = 'Innodb_page_size') B;

    -- To see the Percentage of Dirty Pages, run this:
    SELECT CONCAT(FORMAT(DirtyPages*100.0/TotalPages,2),' %') BufferPoolDirtyPercentage FROM
    (SELECT variable_value DirtyPages FROM information_schema.global_status
     WHERE variable_name = 'Innodb_buffer_pool_pages_dirty') A,
    (SELECT variable_value TotalPages FROM information_schema.global_status
     WHERE variable_name = 'Innodb_buffer_pool_pages_total') B;

    -- If larger than 95%, set innodb_buffer_pool_size to 75% of the DB Server's RAM.
    SET @IBPDataPages  = (SELECT VARIABLE_VALUE FROM information_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_data');  -- SELECT @IBPDataPages;
    SET @IBPTotalPages = (SELECT VARIABLE_VALUE FROM information_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_total'); -- SELECT @IBPTotalPages;
    SET @IBPPctFull    = CAST(@IBPDataPages * 100.0 / @IBPTotalPages AS DECIMAL(5,2));
    SELECT @IBPPctFull;

    -- If the above returns less than 95%, then the following number for IBPSize (in GB) fits more closely to your actual working dataset.
    SET @IBPSize      = (SELECT VARIABLE_VALUE FROM information_schema.global_status WHERE VARIABLE_NAME = 'Innodb_page_size'); -- SELECT @IBPSize;
    SET @IBPDataPages = (SELECT VARIABLE_VALUE FROM information_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_data'); -- SELECT @IBPDataPages;
    SET @IBPSize      = concat(ROUND(@IBPSize * @IBPDataPages / (1024*1024*1024) * 1.05, 2), ' GB' );
    SELECT @IBPSize;

    -- Recommended InnoDB Buffer Pool Size based on all InnoDB Data and Indexes with an additional 10%, and a 25% growth
    SELECT CONCAT(CEILING(RIBPS/POWER(1024,pw)),SUBSTR(' KMGT',pw+1,1))
    Recommended_InnoDB_Buffer_Pool_Size FROM
    (
        SELECT RIBPS,FLOOR(LOG(RIBPS)/LOG(1024)) pw
        FROM
        (
            SELECT SUM(data_length+index_length)*1.1*growth RIBPS
            FROM information_schema.tables AAA,
            (SELECT 1.25 growth) BBB
            WHERE ENGINE='InnoDB'
        ) AA
    ) A;

-- sort_merge_passes

    -- If you see many Sort_merge_passes per second in SHOW GLOBAL STATUS output, you can consider increasing the
    -- sort_buffer_size value to speed up ORDER BY or GROUP BY operations that cannot be improved with query optimization
    -- or improved indexing

    -- to check how many Sort_merge_passes happened in the last 5 minutes. It also computes the Sort_merge_passes per hour.
    SET @SleepTime = 300;
    SELECT variable_value INTO @SMP1
    FROM information_schema.global_status WHERE variable_name = 'Sort_merge_passes';
    SELECT SLEEP(@SleepTime) INTO @x;
    SELECT variable_value INTO @SMP2
    FROM information_schema.global_status WHERE variable_name = 'Sort_merge_passes';
    SET @SMP = @SMP2 - @SMP1;
    SET @SMP_RATE = @SMP * 3600 / @SleepTime;
    SELECT @SMP,@SMP_RATE;


