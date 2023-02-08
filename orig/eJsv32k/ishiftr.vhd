-- megafunction wizard: %LPM_CLSHIFT%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: lpm_clshift 

-- ============================================================
-- File Name: ishiftr.vhd
-- Megafunction Name(s):
-- 			lpm_clshift
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 6.0 Build 178 04/27/2006 SJ Full Version
-- ************************************************************


--Copyright (C) 1991-2006 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

ENTITY ishiftr IS
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		distance		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END ishiftr;


ARCHITECTURE SYN OF ishiftr IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC ;



	COMPONENT lpm_clshift
	GENERIC (
		lpm_shifttype		: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL;
		lpm_widthdist		: NATURAL
	);
	PORT (
			distance	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			direction	: IN STD_LOGIC ;
			data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	sub_wire1    <= '1';
	result    <= sub_wire0(31 DOWNTO 0);

	lpm_clshift_component : lpm_clshift
	GENERIC MAP (
		lpm_shifttype => "ARITHMETIC",
		lpm_type => "LPM_CLSHIFT",
		lpm_width => 32,
		lpm_widthdist => 5
	)
	PORT MAP (
		distance => distance,
		direction => sub_wire1,
		data => data,
		result => sub_wire0
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: LPM_SHIFTTYPE NUMERIC "1"
-- Retrieval info: PRIVATE: LPM_WIDTH NUMERIC "32"
-- Retrieval info: PRIVATE: lpm_width_varies NUMERIC "0"
-- Retrieval info: PRIVATE: lpm_widthdist NUMERIC "5"
-- Retrieval info: PRIVATE: lpm_widthdist_style NUMERIC "0"
-- Retrieval info: PRIVATE: port_direction NUMERIC "1"
-- Retrieval info: CONSTANT: LPM_SHIFTTYPE STRING "ARITHMETIC"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_CLSHIFT"
-- Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "32"
-- Retrieval info: CONSTANT: LPM_WIDTHDIST NUMERIC "5"
-- Retrieval info: USED_PORT: data 0 0 32 0 INPUT NODEFVAL data[31..0]
-- Retrieval info: USED_PORT: distance 0 0 5 0 INPUT NODEFVAL distance[4..0]
-- Retrieval info: USED_PORT: result 0 0 32 0 OUTPUT NODEFVAL result[31..0]
-- Retrieval info: CONNECT: @distance 0 0 5 0 distance 0 0 5 0
-- Retrieval info: CONNECT: @data 0 0 32 0 data 0 0 32 0
-- Retrieval info: CONNECT: result 0 0 32 0 @result 0 0 32 0
-- Retrieval info: CONNECT: @direction 0 0 0 0 VCC 0 0 0 0
-- Retrieval info: LIBRARY: lpm lpm.lpm_components.all
-- Retrieval info: GEN_FILE: TYPE_NORMAL ishiftr.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ishiftr.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ishiftr.cmp TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ishiftr.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ishiftr_inst.vhd TRUE
