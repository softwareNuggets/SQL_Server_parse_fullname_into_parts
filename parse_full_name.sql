create function fn_split_fullname(@full_name nvarchar(100))
RETURNS @table Table
(
	full_name	nvarchar(100),
	last_name	nvarchar(60),
	suffix		nvarchar(20),
	first_name	nvarchar(60),
	middle_name nvarchar(60)
)
AS
/*
	history
	---------------------	----------------------------------------
	software nuggets		3/11/2023  - split full name into parts

	select * from fn_split_fullname('Doe Jr, John W')
	select * from fn_split_fullname('Doe, John W')
	select * from fn_split_fullname('Doe Joe, John W')
	select * from fn_split_fullname('Doe Joe,         John             W     ')
	select * from fn_split_fullname('Doe          III         ,         John             W     ')
	select * from fn_split_fullname('D,J')
	select * from fn_split_fullname('D, J')
	select * from fn_split_fullname('D iv, J k')
*/
BEGIN
declare @section_1		nvarchar(60),
		@section_2		nvarchar(60),
		@offset			int,
		@last_name		nvarchar(60),
		@first_name		nvarchar(60),
		@middle_name	nvarchar(60),
		@maybe_suffix	nvarchar(30),
		@found_suffix   bit='false',
		@suffix			nvarchar(30);


		set @section_1 = ltrim(rtrim(left(@full_name,charindex(',',@full_name)-1)));

		set @section_2 = ltrim(substring(@full_name, 
						charindex(',',@full_name)+1, len(@full_name)-charindex(',',@full_name)+1));

		set @last_name = @section_1;
		set @offset = charindex(' ',@section_1);
		IF(@offset > 0)
		begin
			set @last_name = ltrim(rtrim(left(@section_1,charindex(' ',@section_1)-1)));
			set @suffix    = ltrim(	substring(	@section_1,
								@offset+1,len(@section_1)-charindex(' ',@section_1)+1));

			IF upper(trim(@suffix)) in ('JR','SR','II','III','IV','V')
			begin
				set @suffix = ltrim(rtrim(@suffix));
			end
			ELSE
			begin
				-- last name may contain two last names like Garcia Gonzalez
				set @last_name = @section_1;
				set @suffix = null;
			end
		end
			
		set @offset = charindex(' ',ltrim(rtrim(@section_2)));
		IF(@offset > 0)
		begin
			set @first_name = left(ltrim(rtrim(@section_2)),@offset)

			set @middle_name = rtrim(ltrim(substring(ltrim(rtrim(@section_2)),@offset,100)))
									
		end
		ELSE
		begin
			set @first_name = ltrim(rtrim(@section_2))
		end

		insert into @table(full_name,last_name, suffix, first_name, middle_name)
		values(@full_name,@last_name,@suffix,@first_name, @middle_name);

	return;

END;
