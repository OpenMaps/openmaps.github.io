/**
Example cases discussed here are:

    CASE 1: A Stored Procedure that Accept No Parameters
    CASE 2: A Stored Procedure that Accept Parameters (IN, OUT, INOUT)
    CASE 3: A Stored Procedure that Accept Parameters, Return ResultSet
    CASE 4: A Stored Function that Accept No Parameters
    CASE 5: A Stored Function that Accept Parameters
**/
    DROP TABLE IF EXISTS emp;

    CREATE TABLE emp(
		`first_name` VARCHAR(20), 
		id INT PRIMARY KEY
	);

    insert into emp values('HJK', 1);

    insert into emp values('ABC', 2);

    insert into emp values('DEF', 3);
	
	select * from emp;
	
/**CASE 1: A Stored Procedure that Accept No Parameters**/
    DELIMITER |

    CREATE PROCEDURE sample_no_param ()

    BEGIN

    UPDATE emp SET `first_name`= 'ChangedHJK' where id = 1;

    END

    |

    DELIMITER ;
/**Execute and Verify Commands**/
    CALL sample_no_param;

    select * from emp;
/**CASE 2: A Stored Procedure that Accept Parameters (IN, OUT, INOUT)**/
    DELIMITER |

    CREATE PROCEDURE sample_with_params (
		IN empId INT UNSIGNED, 
		OUT oldName VARCHAR(20), 
		INOUT newName VARCHAR(20)
	)

    BEGIN

    SELECT `first_name` into oldName FROM emp where id = empId;

    UPDATE emp SET `first_name`= newName where id = empId;

    END

    |

    DELIMITER ;
/**Execute and Verify Commands**/
    set @inout='updatedHJK';
    CALL sample_with_params(1,@out,@inout);

    select @out,@inout;

    select * from emp;
/**CASE 3: A Stored Procedure that Accept Parameters, Return ResultSet**/
    DELIMITER |

    CREATE PROCEDURE sample_with_params_resultset (
		IN empId INT UNSIGNED, 
		OUT oldName VARCHAR(20), 
		INOUT newName VARCHAR(20))

    BEGIN

    SELECT `first_name` into oldName FROM emp where id = empId;

    UPDATE emp SET `first_name`= newName where id = empId;

    select * from emp;

    END

    |

    DELIMITER ;
/**Execute and Verify Commands**/
    set @inout='updatedHJKS';

    CALL sample_sp_with_params_resultset (1,@out,@inout);
/**You can verify the values of OUT and INOUT parameters as:**/
select @out,@inout;
/**CASE 4: A Stored Function that Accept No Parameters**/
    DELIMITER |

    CREATE FUNCTION sample_fn_no_param ()

    RETURNS INT

    BEGIN

    DECLARE count INT;

    SELECT COUNT(*) INTO count FROM emp;

    RETURN count;

    END

    |

    DELIMITER ;
/**Execute and verify commands**/
select sample_fn_no_param();

/**CASE 5: A Stored Function that Accept Parameters**/
    DELIMITER |

    CREATE FUNCTION sample_fn_with_params (empId INT UNSIGNED, newName VARCHAR(20))

    RETURNS VARCHAR(20)

    BEGIN

    DECLARE oldName VARCHAR(20);

    SELECT `first_name` into oldName FROM emp where id = empId;

    UPDATE emp SET `first_name`= newName where id = empId;

    RETURN oldName;

    END

    |

    DELIMITER ;
/**Execute and verify commands**/
select sample_fn_with_params(2,'UpdatedABC');

/**Drop commands***/
    DROP  PROCEDURE IF EXISTS sample_sp_no_param;

    DROP PROCEDURE IF EXISTS sample_sp_with_params;

    DROP PROCEDURE IF EXISTS sample_sp_with_params_resultset;

    DROP FUNCTION IF EXISTS sample_fn_no_param;

    DROP FUNCTION IF EXISTS sample_fn_with_params;
