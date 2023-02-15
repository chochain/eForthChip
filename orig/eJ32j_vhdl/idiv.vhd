-- megafunction wizard: %LPM_DIVIDE%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: lpm_divide 

-- ============================================================
-- File Name: idiv.vhd
-- Megafunction Name(s):
-- 			lpm_divide
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

ENTITY idiv IS
	PORT
	(
		denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		quotient		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		remain		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END idiv;


ARCHITECTURE SYN OF idiv IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC_VECTOR (31 DOWNTO 0);



	COMPONENT lpm_divide
	GENERIC (
		lpm_drepresentation		: STRING;
		lpm_hint		: STRING;
		lpm_nrepresentation		: STRING;
		lpm_type		: STRING;
		lpm_widthd		: NATURAL;
		lpm_widthn		: NATURAL
	);
	PORT (
			denom	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			quotient	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			remain	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			numer	: IN STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	quotient    <= sub_wire0(31 DOWNTO 0);
	remain    <= sub_wire1(31 DOWNTO 0);

	lpm_divide_component : lpm_divide
	GENERIC MAP (
		lpm_drepresentation => "SIGNED",
		lpm_hint => "LPM_REMAINDERPOSITIVE=FALSE",
		lpm_nrepresentation => "SIGNED",
		lpm_type => "LPM_DIVIDE",
		lpm_widthd => 32,
		lpm_widthn => 32
	)
	PORT MAP (
		denom => denom,
		numer => numer,
		quotient => sub_wire0,
		remain => sub_wire1
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: PRIVATE_LPM_REMAINDERPOSITIVE STRING "FALSE"
-- Retrieval info: PRIVATE: PRIVATE_MAXIMIZE_SPEED NUMERIC "-1"
-- Retrieval info: PRIVATE: USING_PIPELINE NUMERIC "0"
-- Retrieval info: PRIVATE: VERSION_NUMBER NUMERIC "2"
-- Retrieval info: CONSTANT: LPM_DREPRESENTATION STRING "SIGNED"
-- Retrieval info: CONSTANT: LPM_HINT STRING "LPM_REMAINDERPOSITIVE=FALSE"
-- Retrieval info: CONSTANT: LPM_NREPRESENTATION STRING "SIGNED"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_DIVIDE"
-- Retrieval info: CONSTANT: LPM_WIDTHD NUMERIC "32"
-- Retrieval info: CONSTANT: LPM_WIDTHN NUMERIC "32"
-- Retrieval info: USED_PORT: denom 0 0 32 0 INPUT NODEFVAL denom[31..0]
-- Retrieval info: USED_PORT: numer 0 0 32 0 INPUT NODEFVAL numer[31..0]
-- Retrieval info: USED_PORT: quotient 0 0 32 0 OUTPUT NODEFVAL quotient[31..0]
-- Retrieval info: USED_PORT: remain 0 0 32 0 OUTPUT NODEFVAL remain[31..0]
-- Retrieval info: CONNECT: @numer 0 0 32 0 numer 0 0 32 0
-- Retrieval info: CONNECT: @denom 0 0 32 0 denom 0 0 32 0
-- Retrieval info: CONNECT: quotient 0 0 32 0 @quotient 0 0 32 0
-- Retrieval info: CONNECT: remain 0 0 32 0 @remain 0 0 32 0
-- Retrieval info: LIBRARY: lpm lpm.lpm_components.all
-- Retrieval info: GEN_FILE: TYPE_NORMAL idiv.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL idiv.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL idiv.cmp TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL idiv.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL idiv_inst.vhd TRUE