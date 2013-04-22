-- parser produced by Happy Version 1.8

data Statement  = Instr Instr
                | Label String
                | Directive

data HappyAbsSyn 
	= HappyTerminal Token
	| HappyErrorToken Int
	| HappyAbsSyn4 (Parser ClassFile)
	| HappyAbsSyn5 (String)
	| HappyAbsSyn6 (Parser JavaType)
	| HappyAbsSyn9 (Parser ())
	| HappyAbsSyn10 (Parser (Bool,Class,{Modifier}))
	| HappyAbsSyn11 (Parser Class)
	| HappyAbsSyn12 (Parser {Modifier})
	| HappyAbsSyn14 (Parser [Modifier])
	| HappyAbsSyn15 (Parser Modifier)
	| HappyAbsSyn16 (Parser (Maybe Class))
	| HappyAbsSyn17 (Parser {Class})
	| HappyAbsSyn18 (Parser [Class])
	| HappyAbsSyn20 (Parser (FieldTab,[CSig]))
	| HappyAbsSyn21 (Parser ([(CNm,FDec)],[CSig]))
	| HappyAbsSyn22 (Parser ((FNm,FDec),CSig))
	| HappyAbsSyn23 (Parser (Maybe Val))
	| HappyAbsSyn24 (Parser (MethTab,[CSig]))
	| HappyAbsSyn25 (Parser ([(MSig,MDec)],[CSig]))
	| HappyAbsSyn26 (Parser ((MSig,MDec),CSig))
	| HappyAbsSyn27 (Parser ({Modifier},MSig,JavaType,MRefSig))
	| HappyAbsSyn29 (Parser [Statement])
	| HappyAbsSyn30 (Parser Statement)
	| HappyAbsSyn32 (Parser String)
	| HappyAbsSyn39 (Parser Pc)
	| HappyAbsSyn40 (Parser Instr)
	| HappyAbsSyn45 (Parser [(Int,Pc)])
	| HappyAbsSyn46 (Parser (Int,Pc))
	| HappyAbsSyn47 (Parser (Pc))
	| HappyAbsSyn49 (Parser (Int,Int))
	| HappyAbsSyn50 (Parser [Int])
	| HappyAbsSyn52 (Parser Int)
	| HappyAbsSyn53 (Int)
	| HappyAbsSyn55 (Instr)
	| HappyAbsSyn56 (String -> Parser Instr)
	| HappyAbsSyn57 (Int -> Parser Instr)
	| HappyAbsSyn58 (JavaType -> Parser Instr)
	| HappyAbsSyn60 (Int -> Int -> Parser Instr)
	| HappyAbsSyn61 (JavaType -> Int -> Parser Instr)
	| HappyAbsSyn62 (String -> String -> Parser Instr)
	| HappyAbsSyn63 (String -> Int -> Parser Instr)
	| HappyAbsSyn64 (Val)

type HappyReduction = 
	   Int 
	-> (Token)
	-> HappyState (Token) ([HappyAbsSyn] -> [(Token)] -> Parser ClassFile)
	-> [HappyState (Token) ([HappyAbsSyn] -> [(Token)] -> Parser ClassFile)] 
	-> [HappyAbsSyn] 
	-> [(Token)] -> Parser ClassFile

action_0,
 action_1,
 action_2,
 action_3,
 action_4,
 action_5,
 action_6,
 action_7,
 action_8,
 action_9,
 action_10,
 action_11,
 action_12,
 action_13,
 action_14,
 action_15,
 action_16,
 action_17,
 action_18,
 action_19,
 action_20,
 action_21,
 action_22,
 action_23,
 action_24,
 action_25,
 action_26,
 action_27,
 action_28,
 action_29,
 action_30,
 action_31,
 action_32,
 action_33,
 action_34,
 action_35,
 action_36,
 action_37,
 action_38,
 action_39,
 action_40,
 action_41,
 action_42,
 action_43,
 action_44,
 action_45,
 action_46,
 action_47,
 action_48,
 action_49,
 action_50,
 action_51,
 action_52,
 action_53,
 action_54,
 action_55,
 action_56,
 action_57,
 action_58,
 action_59,
 action_60,
 action_61,
 action_62,
 action_63,
 action_64,
 action_65,
 action_66,
 action_67,
 action_68,
 action_69,
 action_70,
 action_71,
 action_72,
 action_73,
 action_74,
 action_75,
 action_76,
 action_77,
 action_78,
 action_79,
 action_80,
 action_81,
 action_82,
 action_83,
 action_84,
 action_85,
 action_86,
 action_87,
 action_88,
 action_89,
 action_90,
 action_91,
 action_92,
 action_93,
 action_94,
 action_95,
 action_96,
 action_97,
 action_98,
 action_99,
 action_100,
 action_101,
 action_102,
 action_103,
 action_104,
 action_105,
 action_106,
 action_107,
 action_108,
 action_109,
 action_110,
 action_111,
 action_112,
 action_113,
 action_114,
 action_115,
 action_116,
 action_117,
 action_118,
 action_119,
 action_120,
 action_121,
 action_122,
 action_123,
 action_124,
 action_125,
 action_126,
 action_127,
 action_128,
 action_129,
 action_130,
 action_131,
 action_132,
 action_133,
 action_134,
 action_135,
 action_136,
 action_137,
 action_138,
 action_139,
 action_140,
 action_141,
 action_142,
 action_143,
 action_144,
 action_145,
 action_146,
 action_147,
 action_148,
 action_149,
 action_150,
 action_151,
 action_152,
 action_153,
 action_154,
 action_155,
 action_156,
 action_157,
 action_158,
 action_159,
 action_160,
 action_161,
 action_162,
 action_163,
 action_164,
 action_165,
 action_166,
 action_167,
 action_168,
 action_169,
 action_170,
 action_171,
 action_172,
 action_173,
 action_174,
 action_175,
 action_176,
 action_177,
 action_178,
 action_179,
 action_180,
 action_181,
 action_182,
 action_183,
 action_184,
 action_185,
 action_186,
 action_187 :: Int -> HappyReduction

happyReduce_1,
 happyReduce_2,
 happyReduce_3,
 happyReduce_4,
 happyReduce_5,
 happyReduce_6,
 happyReduce_7,
 happyReduce_8,
 happyReduce_9,
 happyReduce_10,
 happyReduce_11,
 happyReduce_12,
 happyReduce_13,
 happyReduce_14,
 happyReduce_15,
 happyReduce_16,
 happyReduce_17,
 happyReduce_18,
 happyReduce_19,
 happyReduce_20,
 happyReduce_21,
 happyReduce_22,
 happyReduce_23,
 happyReduce_24,
 happyReduce_25,
 happyReduce_26,
 happyReduce_27,
 happyReduce_28,
 happyReduce_29,
 happyReduce_30,
 happyReduce_31,
 happyReduce_32,
 happyReduce_33,
 happyReduce_34,
 happyReduce_35,
 happyReduce_36,
 happyReduce_37,
 happyReduce_38,
 happyReduce_39,
 happyReduce_40,
 happyReduce_41,
 happyReduce_42,
 happyReduce_43,
 happyReduce_44,
 happyReduce_45,
 happyReduce_46,
 happyReduce_47,
 happyReduce_48,
 happyReduce_49,
 happyReduce_50,
 happyReduce_51,
 happyReduce_52,
 happyReduce_53,
 happyReduce_54,
 happyReduce_55,
 happyReduce_56,
 happyReduce_57,
 happyReduce_58,
 happyReduce_59,
 happyReduce_60,
 happyReduce_61,
 happyReduce_62,
 happyReduce_63,
 happyReduce_64,
 happyReduce_65,
 happyReduce_66,
 happyReduce_67,
 happyReduce_68,
 happyReduce_69,
 happyReduce_70,
 happyReduce_71,
 happyReduce_72,
 happyReduce_73,
 happyReduce_74,
 happyReduce_75,
 happyReduce_76,
 happyReduce_77,
 happyReduce_78,
 happyReduce_79,
 happyReduce_80,
 happyReduce_81,
 happyReduce_82,
 happyReduce_83,
 happyReduce_84,
 happyReduce_85,
 happyReduce_86,
 happyReduce_87,
 happyReduce_88,
 happyReduce_89,
 happyReduce_90,
 happyReduce_91,
 happyReduce_92,
 happyReduce_93,
 happyReduce_94,
 happyReduce_95,
 happyReduce_96,
 happyReduce_97,
 happyReduce_98,
 happyReduce_99,
 happyReduce_100,
 happyReduce_101,
 happyReduce_102,
 happyReduce_103,
 happyReduce_104,
 happyReduce_105,
 happyReduce_106,
 happyReduce_107,
 happyReduce_108,
 happyReduce_109,
 happyReduce_110,
 happyReduce_111,
 happyReduce_112 :: HappyReduction

action_0 (75) = happyShift action_4
action_0 (100) = happyShift action_5
action_0 (4) = happyGoto action_1
action_0 (9) = happyGoto action_2
action_0 (66) = happyGoto action_3
action_0 _ = happyReduce_8

action_1 (119) = happyAccept
action_1 _ = happyFail

action_2 (68) = happyShift action_10
action_2 (79) = happyShift action_11
action_2 (10) = happyGoto action_9
action_2 _ = happyFail

action_3 (75) = happyShift action_4
action_3 (100) = happyShift action_5
action_3 (4) = happyGoto action_8
action_3 (9) = happyGoto action_2
action_3 (66) = happyGoto action_3
action_3 _ = happyReduce_8

action_4 (102) = happyShift action_7
action_4 (5) = happyGoto action_6
action_4 _ = happyFail

action_5 _ = happyReduce_112

action_6 (100) = happyShift action_5
action_6 (66) = happyGoto action_29
action_6 _ = happyFail

action_7 _ = happyReduce_3

action_8 _ = happyReduce_2

action_9 (74) = happyShift action_28
action_9 (16) = happyGoto action_27
action_9 _ = happyReduce_28

action_10 (85) = happyShift action_16
action_10 (86) = happyShift action_17
action_10 (88) = happyShift action_18
action_10 (89) = happyShift action_19
action_10 (90) = happyShift action_20
action_10 (91) = happyShift action_21
action_10 (92) = happyShift action_22
action_10 (93) = happyShift action_23
action_10 (94) = happyShift action_24
action_10 (95) = happyShift action_25
action_10 (12) = happyGoto action_26
action_10 (13) = happyGoto action_13
action_10 (14) = happyGoto action_14
action_10 (15) = happyGoto action_15
action_10 _ = happyReduce_14

action_11 (85) = happyShift action_16
action_11 (86) = happyShift action_17
action_11 (88) = happyShift action_18
action_11 (89) = happyShift action_19
action_11 (90) = happyShift action_20
action_11 (91) = happyShift action_21
action_11 (92) = happyShift action_22
action_11 (93) = happyShift action_23
action_11 (94) = happyShift action_24
action_11 (95) = happyShift action_25
action_11 (12) = happyGoto action_12
action_11 (13) = happyGoto action_13
action_11 (14) = happyGoto action_14
action_11 (15) = happyGoto action_15
action_11 _ = happyReduce_14

action_12 (102) = happyShift action_7
action_12 (5) = happyGoto action_30
action_12 (11) = happyGoto action_38
action_12 _ = happyFail

action_13 _ = happyReduce_12

action_14 (85) = happyShift action_16
action_14 (86) = happyShift action_17
action_14 (88) = happyShift action_18
action_14 (89) = happyShift action_19
action_14 (90) = happyShift action_20
action_14 (91) = happyShift action_21
action_14 (92) = happyShift action_22
action_14 (93) = happyShift action_23
action_14 (94) = happyShift action_24
action_14 (95) = happyShift action_25
action_14 (15) = happyGoto action_37
action_14 _ = happyReduce_13

action_15 _ = happyReduce_16

action_16 _ = happyReduce_26

action_17 _ = happyReduce_21

action_18 _ = happyReduce_25

action_19 _ = happyReduce_18

action_20 _ = happyReduce_19

action_21 _ = happyReduce_17

action_22 _ = happyReduce_20

action_23 _ = happyReduce_22

action_24 _ = happyReduce_24

action_25 _ = happyReduce_23

action_26 (102) = happyShift action_7
action_26 (5) = happyGoto action_30
action_26 (11) = happyGoto action_36
action_26 _ = happyFail

action_27 (78) = happyShift action_35
action_27 (17) = happyGoto action_32
action_27 (18) = happyGoto action_33
action_27 (19) = happyGoto action_34
action_27 _ = happyReduce_30

action_28 (102) = happyShift action_7
action_28 (5) = happyGoto action_30
action_28 (11) = happyGoto action_31
action_28 _ = happyFail

action_29 _ = happyReduce_7

action_30 _ = happyReduce_11

action_31 (100) = happyShift action_5
action_31 (66) = happyGoto action_47
action_31 _ = happyFail

action_32 (70) = happyShift action_46
action_32 (20) = happyGoto action_43
action_32 (21) = happyGoto action_44
action_32 (22) = happyGoto action_45
action_32 _ = happyReduce_35

action_33 (78) = happyShift action_35
action_33 (19) = happyGoto action_42
action_33 _ = happyReduce_29

action_34 _ = happyReduce_32

action_35 (102) = happyShift action_7
action_35 (5) = happyGoto action_30
action_35 (11) = happyGoto action_41
action_35 _ = happyFail

action_36 (100) = happyShift action_5
action_36 (66) = happyGoto action_40
action_36 _ = happyFail

action_37 _ = happyReduce_15

action_38 (100) = happyShift action_5
action_38 (66) = happyGoto action_39
action_38 _ = happyFail

action_39 _ = happyReduce_10

action_40 _ = happyReduce_9

action_41 (100) = happyShift action_5
action_41 (66) = happyGoto action_55
action_41 _ = happyFail

action_42 _ = happyReduce_31

action_43 (73) = happyShift action_54
action_43 (24) = happyGoto action_50
action_43 (25) = happyGoto action_51
action_43 (26) = happyGoto action_52
action_43 (27) = happyGoto action_53
action_43 _ = happyReduce_42

action_44 (70) = happyShift action_46
action_44 (22) = happyGoto action_49
action_44 _ = happyReduce_34

action_45 _ = happyReduce_37

action_46 (85) = happyShift action_16
action_46 (86) = happyShift action_17
action_46 (88) = happyShift action_18
action_46 (89) = happyShift action_19
action_46 (90) = happyShift action_20
action_46 (91) = happyShift action_21
action_46 (92) = happyShift action_22
action_46 (93) = happyShift action_23
action_46 (94) = happyShift action_24
action_46 (95) = happyShift action_25
action_46 (12) = happyGoto action_48
action_46 (13) = happyGoto action_13
action_46 (14) = happyGoto action_14
action_46 (15) = happyGoto action_15
action_46 _ = happyReduce_14

action_47 _ = happyReduce_27

action_48 (102) = happyShift action_7
action_48 (5) = happyGoto action_96
action_48 _ = happyFail

action_49 _ = happyReduce_36

action_50 _ = happyReduce_1

action_51 (73) = happyShift action_54
action_51 (26) = happyGoto action_95
action_51 (27) = happyGoto action_53
action_51 _ = happyReduce_41

action_52 _ = happyReduce_44

action_53 (67) = happyShift action_76
action_53 (69) = happyShift action_77
action_53 (71) = happyShift action_78
action_53 (72) = happyShift action_79
action_53 (76) = happyShift action_80
action_53 (77) = happyShift action_81
action_53 (96) = happyShift action_82
action_53 (97) = happyShift action_83
action_53 (102) = happyShift action_7
action_53 (106) = happyShift action_84
action_53 (107) = happyShift action_85
action_53 (108) = happyShift action_86
action_53 (109) = happyShift action_87
action_53 (110) = happyShift action_88
action_53 (111) = happyShift action_89
action_53 (112) = happyShift action_90
action_53 (113) = happyShift action_91
action_53 (114) = happyShift action_92
action_53 (115) = happyShift action_93
action_53 (116) = happyShift action_94
action_53 (5) = happyGoto action_57
action_53 (28) = happyGoto action_58
action_53 (29) = happyGoto action_59
action_53 (30) = happyGoto action_60
action_53 (31) = happyGoto action_61
action_53 (32) = happyGoto action_62
action_53 (33) = happyGoto action_63
action_53 (40) = happyGoto action_64
action_53 (41) = happyGoto action_65
action_53 (42) = happyGoto action_66
action_53 (55) = happyGoto action_67
action_53 (56) = happyGoto action_68
action_53 (57) = happyGoto action_69
action_53 (58) = happyGoto action_70
action_53 (59) = happyGoto action_71
action_53 (60) = happyGoto action_72
action_53 (61) = happyGoto action_73
action_53 (62) = happyGoto action_74
action_53 (63) = happyGoto action_75
action_53 _ = happyFail

action_54 (85) = happyShift action_16
action_54 (86) = happyShift action_17
action_54 (88) = happyShift action_18
action_54 (89) = happyShift action_19
action_54 (90) = happyShift action_20
action_54 (91) = happyShift action_21
action_54 (92) = happyShift action_22
action_54 (93) = happyShift action_23
action_54 (94) = happyShift action_24
action_54 (95) = happyShift action_25
action_54 (12) = happyGoto action_56
action_54 (13) = happyGoto action_13
action_54 (14) = happyGoto action_14
action_54 (15) = happyGoto action_15
action_54 _ = happyReduce_14

action_55 _ = happyReduce_33

action_56 (102) = happyShift action_7
action_56 (5) = happyGoto action_139
action_56 _ = happyFail

action_57 (101) = happyShift action_138
action_57 _ = happyFail

action_58 _ = happyReduce_46

action_59 (67) = happyShift action_76
action_59 (69) = happyShift action_77
action_59 (71) = happyShift action_78
action_59 (72) = happyShift action_79
action_59 (76) = happyShift action_80
action_59 (77) = happyShift action_81
action_59 (96) = happyShift action_82
action_59 (97) = happyShift action_83
action_59 (102) = happyShift action_7
action_59 (106) = happyShift action_84
action_59 (107) = happyShift action_85
action_59 (108) = happyShift action_86
action_59 (109) = happyShift action_87
action_59 (110) = happyShift action_88
action_59 (111) = happyShift action_89
action_59 (112) = happyShift action_90
action_59 (113) = happyShift action_91
action_59 (114) = happyShift action_92
action_59 (115) = happyShift action_93
action_59 (116) = happyShift action_94
action_59 (5) = happyGoto action_57
action_59 (28) = happyGoto action_136
action_59 (30) = happyGoto action_137
action_59 (31) = happyGoto action_61
action_59 (32) = happyGoto action_62
action_59 (33) = happyGoto action_63
action_59 (40) = happyGoto action_64
action_59 (41) = happyGoto action_65
action_59 (42) = happyGoto action_66
action_59 (55) = happyGoto action_67
action_59 (56) = happyGoto action_68
action_59 (57) = happyGoto action_69
action_59 (58) = happyGoto action_70
action_59 (59) = happyGoto action_71
action_59 (60) = happyGoto action_72
action_59 (61) = happyGoto action_73
action_59 (62) = happyGoto action_74
action_59 (63) = happyGoto action_75
action_59 _ = happyFail

action_60 _ = happyReduce_50

action_61 (100) = happyShift action_5
action_61 (66) = happyGoto action_135
action_61 _ = happyFail

action_62 _ = happyReduce_54

action_63 _ = happyReduce_53

action_64 _ = happyReduce_52

action_65 _ = happyReduce_68

action_66 _ = happyReduce_69

action_67 _ = happyReduce_70

action_68 (102) = happyShift action_7
action_68 (5) = happyGoto action_134
action_68 _ = happyFail

action_69 (103) = happyShift action_109
action_69 (53) = happyGoto action_133
action_69 _ = happyFail

action_70 (102) = happyShift action_132
action_70 (7) = happyGoto action_131
action_70 _ = happyFail

action_71 (102) = happyShift action_130
action_71 (6) = happyGoto action_129
action_71 _ = happyFail

action_72 (103) = happyShift action_109
action_72 (53) = happyGoto action_128
action_72 _ = happyFail

action_73 (102) = happyShift action_127
action_73 (8) = happyGoto action_126
action_73 _ = happyFail

action_74 (102) = happyShift action_7
action_74 (5) = happyGoto action_125
action_74 _ = happyFail

action_75 (102) = happyShift action_7
action_75 (5) = happyGoto action_124
action_75 _ = happyFail

action_76 (102) = happyShift action_7
action_76 (5) = happyGoto action_30
action_76 (11) = happyGoto action_122
action_76 (38) = happyGoto action_123
action_76 _ = happyFail

action_77 (84) = happyShift action_121
action_77 _ = happyFail

action_78 (102) = happyShift action_7
action_78 (5) = happyGoto action_119
action_78 (35) = happyGoto action_120
action_78 _ = happyFail

action_79 (103) = happyShift action_109
action_79 (36) = happyGoto action_117
action_79 (53) = happyGoto action_118
action_79 _ = happyFail

action_80 (102) = happyShift action_7
action_80 (5) = happyGoto action_30
action_80 (11) = happyGoto action_115
action_80 (37) = happyGoto action_116
action_80 _ = happyFail

action_81 (103) = happyShift action_109
action_81 (34) = happyGoto action_113
action_81 (53) = happyGoto action_114
action_81 _ = happyFail

action_82 (100) = happyShift action_5
action_82 (43) = happyGoto action_110
action_82 (44) = happyGoto action_111
action_82 (66) = happyGoto action_112
action_82 _ = happyFail

action_83 (103) = happyShift action_109
action_83 (48) = happyGoto action_106
action_83 (49) = happyGoto action_107
action_83 (53) = happyGoto action_108
action_83 _ = happyFail

action_84 _ = happyReduce_99

action_85 _ = happyReduce_100

action_86 _ = happyReduce_102

action_87 _ = happyReduce_103

action_88 _ = happyReduce_101

action_89 _ = happyReduce_104

action_90 _ = happyReduce_106

action_91 _ = happyReduce_107

action_92 _ = happyReduce_105

action_93 (103) = happyShift action_103
action_93 (104) = happyShift action_104
action_93 (105) = happyShift action_105
action_93 (54) = happyGoto action_101
action_93 (64) = happyGoto action_102
action_93 _ = happyFail

action_94 (103) = happyShift action_99
action_94 (104) = happyShift action_100
action_94 (65) = happyGoto action_98
action_94 _ = happyFail

action_95 _ = happyReduce_43

action_96 (102) = happyShift action_7
action_96 (5) = happyGoto action_97
action_96 _ = happyFail

action_97 (99) = happyShift action_159
action_97 (23) = happyGoto action_158
action_97 _ = happyReduce_40

action_98 _ = happyReduce_72

action_99 _ = happyReduce_110

action_100 _ = happyReduce_111

action_101 _ = happyReduce_73

action_102 _ = happyReduce_71

action_103 _ = happyReduce_108

action_104 _ = happyReduce_109

action_105 _ = happyReduce_98

action_106 _ = happyReduce_83

action_107 (102) = happyShift action_7
action_107 (5) = happyGoto action_154
action_107 (39) = happyGoto action_155
action_107 (50) = happyGoto action_156
action_107 (51) = happyGoto action_157
action_107 _ = happyFail

action_108 (100) = happyShift action_5
action_108 (103) = happyShift action_109
action_108 (53) = happyGoto action_152
action_108 (66) = happyGoto action_153
action_108 _ = happyFail

action_109 _ = happyReduce_97

action_110 _ = happyReduce_82

action_111 (103) = happyShift action_109
action_111 (45) = happyGoto action_149
action_111 (46) = happyGoto action_150
action_111 (53) = happyGoto action_151
action_111 _ = happyFail

action_112 _ = happyReduce_85

action_113 _ = happyReduce_56

action_114 (82) = happyShift action_148
action_114 _ = happyFail

action_115 _ = happyReduce_65

action_116 _ = happyReduce_59

action_117 _ = happyReduce_58

action_118 _ = happyReduce_64

action_119 (103) = happyShift action_109
action_119 (53) = happyGoto action_147
action_119 _ = happyFail

action_120 _ = happyReduce_57

action_121 (100) = happyShift action_5
action_121 (66) = happyGoto action_146
action_121 _ = happyFail

action_122 (83) = happyShift action_145
action_122 _ = happyFail

action_123 _ = happyReduce_60

action_124 (103) = happyShift action_109
action_124 (53) = happyGoto action_144
action_124 _ = happyFail

action_125 (102) = happyShift action_7
action_125 (5) = happyGoto action_143
action_125 _ = happyFail

action_126 (103) = happyShift action_109
action_126 (53) = happyGoto action_142
action_126 _ = happyFail

action_127 _ = happyReduce_6

action_128 (103) = happyShift action_109
action_128 (53) = happyGoto action_141
action_128 _ = happyFail

action_129 _ = happyReduce_77

action_130 _ = happyReduce_4

action_131 _ = happyReduce_78

action_132 _ = happyReduce_5

action_133 _ = happyReduce_76

action_134 _ = happyReduce_79

action_135 _ = happyReduce_51

action_136 _ = happyReduce_45

action_137 _ = happyReduce_49

action_138 _ = happyReduce_55

action_139 (100) = happyShift action_5
action_139 (66) = happyGoto action_140
action_139 _ = happyFail

action_140 _ = happyReduce_47

action_141 _ = happyReduce_74

action_142 _ = happyReduce_75

action_143 _ = happyReduce_81

action_144 _ = happyReduce_80

action_145 (102) = happyShift action_7
action_145 (5) = happyGoto action_154
action_145 (39) = happyGoto action_172
action_145 _ = happyFail

action_146 _ = happyReduce_48

action_147 _ = happyReduce_63

action_148 (102) = happyShift action_7
action_148 (5) = happyGoto action_171
action_148 _ = happyFail

action_149 (98) = happyShift action_170
action_149 (103) = happyShift action_109
action_149 (46) = happyGoto action_168
action_149 (47) = happyGoto action_169
action_149 (53) = happyGoto action_151
action_149 _ = happyFail

action_150 _ = happyReduce_87

action_151 (101) = happyShift action_167
action_151 _ = happyFail

action_152 (100) = happyShift action_5
action_152 (66) = happyGoto action_166
action_152 _ = happyFail

action_153 _ = happyReduce_91

action_154 _ = happyReduce_67

action_155 (100) = happyShift action_5
action_155 (66) = happyGoto action_165
action_155 _ = happyFail

action_156 (98) = happyShift action_164
action_156 (102) = happyShift action_7
action_156 (5) = happyGoto action_154
action_156 (39) = happyGoto action_155
action_156 (51) = happyGoto action_162
action_156 (52) = happyGoto action_163
action_156 _ = happyFail

action_157 _ = happyReduce_94

action_158 (100) = happyShift action_5
action_158 (66) = happyGoto action_161
action_158 _ = happyFail

action_159 (103) = happyShift action_103
action_159 (104) = happyShift action_104
action_159 (64) = happyGoto action_160
action_159 _ = happyFail

action_160 _ = happyReduce_39

action_161 _ = happyReduce_38

action_162 _ = happyReduce_93

action_163 _ = happyReduce_90

action_164 (101) = happyShift action_177
action_164 _ = happyFail

action_165 _ = happyReduce_95

action_166 _ = happyReduce_92

action_167 (102) = happyShift action_7
action_167 (5) = happyGoto action_154
action_167 (39) = happyGoto action_176
action_167 _ = happyFail

action_168 _ = happyReduce_86

action_169 _ = happyReduce_84

action_170 (101) = happyShift action_175
action_170 _ = happyFail

action_171 (102) = happyShift action_7
action_171 (5) = happyGoto action_174
action_171 _ = happyFail

action_172 (80) = happyShift action_173
action_172 _ = happyFail

action_173 (102) = happyShift action_7
action_173 (5) = happyGoto action_154
action_173 (39) = happyGoto action_182
action_173 _ = happyFail

action_174 (83) = happyShift action_181
action_174 _ = happyReduce_62

action_175 (102) = happyShift action_7
action_175 (5) = happyGoto action_154
action_175 (39) = happyGoto action_180
action_175 _ = happyFail

action_176 (100) = happyShift action_5
action_176 (66) = happyGoto action_179
action_176 _ = happyFail

action_177 (102) = happyShift action_7
action_177 (5) = happyGoto action_154
action_177 (39) = happyGoto action_178
action_177 _ = happyFail

action_178 _ = happyReduce_96

action_179 _ = happyReduce_88

action_180 _ = happyReduce_89

action_181 (102) = happyShift action_7
action_181 (5) = happyGoto action_184
action_181 _ = happyFail

action_182 (81) = happyShift action_183
action_182 _ = happyFail

action_183 (102) = happyShift action_7
action_183 (5) = happyGoto action_154
action_183 (39) = happyGoto action_186
action_183 _ = happyFail

action_184 (80) = happyShift action_185
action_184 _ = happyFail

action_185 (102) = happyShift action_7
action_185 (5) = happyGoto action_187
action_185 _ = happyFail

action_186 _ = happyReduce_66

action_187 _ = happyReduce_61

happyReduce_1 = happyReduce 6 4 happyReduction_1
happyReduction_1 ((HappyAbsSyn24  happy_var_6) :
	(HappyAbsSyn20  happy_var_5) :
	(HappyAbsSyn17  happy_var_4) :
	(HappyAbsSyn16  happy_var_3) :
	(HappyAbsSyn10  happy_var_2) :
	(HappyAbsSyn9  happy_var_1) :
	happyRest)
	 = HappyAbsSyn4
		 (do { happy_var_1;
            (isInterface,cname,ar)  <- happy_var_2;
            sname  <- happy_var_3;
            impls  <- happy_var_4;
            (fields, fsigs) <- happy_var_5;
            (meths, msigs)  <- happy_var_6;
            let { initsig = ("<clinit>",[]);
                  initdec = MDec({Static}, TJVoid, [Return MTvoid], [], (0,0));
                  sigs    = setmap fst meths;
                  csigs   = fsigs ++ msigs;
                  (meths1,csigs1) = if initsig `elem` sigs
				    then (meths,csigs)
				    else ({ (initsig,initdec) } `union` meths,
                                          csigs);
                  (meths2,csigs2) = if ("<init>",[]) `elem` sigs && 
                              Static `notElem` ar &&
                              Abstract `notElem` ar &&
                              ("<newInstance>",[]) `notElem` sigs
                            then ({ newInstanceCode cname } `union`
				  meths1,
                                  ("<newInstance>()",
                                    ("Ljava/lang/Object;",{})) : csigs1)
                            else (meths1,csigs1);};
            result (CFile(cname, isInterface, ar, sname, (mapping csigs2,([],[])), impls, fields, meths2))
	  }
	) : happyRest
happyReduction_1 _ = notHappyAtAll 

happyReduce_2 = happySpecReduce_2 4 happyReduction_2
happyReduction_2 (HappyAbsSyn4  happy_var_2)
	(HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn4
		 (do happy_var_1; happy_var_2
	)
happyReduction_2 _ _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_1 5 happyReduction_3
happyReduction_3 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (strOfTok happy_var_1
	)
happyReduction_3 _  = notHappyAtAll 

happyReduce_4 = happySpecReduce_1 6 happyReduction_4
happyReduction_4 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn6
		 (case strOfTok happy_var_1 of {
            "int"    -> result TJInt;
            "byte"   -> result TJByte;
            "short"  -> result TJShort;
            "char"   -> result TJChar;
            "long"   -> result TJLong;
            "double" -> result TJDouble;
            "float"  -> result TJFloat;
            x        -> raiseErrorInLine (x ++ " is not a basic type")
          }
	)
happyReduction_4 _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_1 7 happyReduction_5
happyReduction_5 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn6
		 (str2atyp(strOfTok happy_var_1)
	)
happyReduction_5 _  = notHappyAtAll 

happyReduce_6 = happySpecReduce_1 8 happyReduction_6
happyReduction_6 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn6
		 (do { t <- str2typ (strOfTok happy_var_1);
               case t of {
                 TJArray(t') -> result(t');
                 _   -> raiseErrorInLine ("invalid type " ++ show t) 
               }
             }
	)
happyReduction_6 _  = notHappyAtAll 

happyReduce_7 = happySpecReduce_3 9 happyReduction_7
happyReduction_7 (HappyAbsSyn9  happy_var_3)
	_
	_
	 =  HappyAbsSyn9
		 (do happy_var_3
	)
happyReduction_7 _ _ _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_0 9 happyReduction_8
happyReduction_8  =  HappyAbsSyn9
		 (result ()
	)

happyReduce_9 = happyReduce 4 10 happyReduction_9
happyReduction_9 ((HappyAbsSyn9  happy_var_4) :
	(HappyAbsSyn11  happy_var_3) :
	(HappyAbsSyn12  happy_var_2) :
	_ :
	happyRest)
	 = HappyAbsSyn10
		 (do { happy_var_4; 
             ar <- happy_var_2;
             cname <- happy_var_3;
             result (False,cname,ar)
	   }
	) : happyRest
happyReduction_9 _ = notHappyAtAll 

happyReduce_10 = happyReduce 4 10 happyReduction_10
happyReduction_10 ((HappyAbsSyn9  happy_var_4) :
	(HappyAbsSyn11  happy_var_3) :
	(HappyAbsSyn12  happy_var_2) :
	_ :
	happyRest)
	 = HappyAbsSyn10
		 (do { happy_var_4; 
             ar <- happy_var_2;
             cname <- happy_var_3;
             result (True,cname,ar)
	   }
	) : happyRest
happyReduction_10 _ = notHappyAtAll 

happyReduce_11 = happySpecReduce_1 11 happyReduction_11
happyReduction_11 (HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn11
		 (do l <- getClassLoader; result (l,happy_var_1)
	)
happyReduction_11 _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_1 12 happyReduction_12
happyReduction_12 (HappyAbsSyn12  happy_var_1)
	 =  HappyAbsSyn12
		 (happy_var_1
	)
happyReduction_12 _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_1 13 happyReduction_13
happyReduction_13 (HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn12
		 (map mkSet happy_var_1
	)
happyReduction_13 _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_0 13 happyReduction_14
happyReduction_14  =  HappyAbsSyn12
		 (result {}
	)

happyReduce_15 = happySpecReduce_2 14 happyReduction_15
happyReduction_15 (HappyAbsSyn15  happy_var_2)
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn14
		 (do as <- happy_var_1; a <- happy_var_2; result (a:as)
	)
happyReduction_15 _ _  = notHappyAtAll 

happyReduce_16 = happySpecReduce_1 14 happyReduction_16
happyReduction_16 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn14
		 (map (\a -> [a]) happy_var_1
	)
happyReduction_16 _  = notHappyAtAll 

happyReduce_17 = happySpecReduce_1 15 happyReduction_17
happyReduction_17 _
	 =  HappyAbsSyn15
		 (result Public
	)

happyReduce_18 = happySpecReduce_1 15 happyReduction_18
happyReduction_18 _
	 =  HappyAbsSyn15
		 (result Private
	)

happyReduce_19 = happySpecReduce_1 15 happyReduction_19
happyReduction_19 _
	 =  HappyAbsSyn15
		 (result Protected
	)

happyReduce_20 = happySpecReduce_1 15 happyReduction_20
happyReduction_20 _
	 =  HappyAbsSyn15
		 (result Static
	)

happyReduce_21 = happySpecReduce_1 15 happyReduction_21
happyReduction_21 _
	 =  HappyAbsSyn15
		 (result Final
	)

happyReduce_22 = happySpecReduce_1 15 happyReduction_22
happyReduction_22 _
	 =  HappyAbsSyn15
		 (result Synchronized
	)

happyReduce_23 = happySpecReduce_1 15 happyReduction_23
happyReduction_23 _
	 =  HappyAbsSyn15
		 (result Volatile
	)

happyReduce_24 = happySpecReduce_1 15 happyReduction_24
happyReduction_24 _
	 =  HappyAbsSyn15
		 (result Transient
	)

happyReduce_25 = happySpecReduce_1 15 happyReduction_25
happyReduction_25 _
	 =  HappyAbsSyn15
		 (result Native
	)

happyReduce_26 = happySpecReduce_1 15 happyReduction_26
happyReduction_26 _
	 =  HappyAbsSyn15
		 (result Abstract
	)

happyReduce_27 = happySpecReduce_3 16 happyReduction_27
happyReduction_27 (HappyAbsSyn9  happy_var_3)
	(HappyAbsSyn11  happy_var_2)
	_
	 =  HappyAbsSyn16
		 (do happy_var_3; map Just happy_var_2
	)
happyReduction_27 _ _ _  = notHappyAtAll 

happyReduce_28 = happySpecReduce_0 16 happyReduction_28
happyReduction_28  =  HappyAbsSyn16
		 (result Nothing
	)

happyReduce_29 = happySpecReduce_1 17 happyReduction_29
happyReduction_29 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn17
		 (map mkSet happy_var_1
	)
happyReduction_29 _  = notHappyAtAll 

happyReduce_30 = happySpecReduce_0 17 happyReduction_30
happyReduction_30  =  HappyAbsSyn17
		 (result {}
	)

happyReduce_31 = happySpecReduce_2 18 happyReduction_31
happyReduction_31 (HappyAbsSyn11  happy_var_2)
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (do is <- happy_var_1; i <- happy_var_2; result (i : is)
	)
happyReduction_31 _ _  = notHappyAtAll 

happyReduce_32 = happySpecReduce_1 18 happyReduction_32
happyReduction_32 (HappyAbsSyn11  happy_var_1)
	 =  HappyAbsSyn18
		 (map (\a -> [a]) happy_var_1
	)
happyReduction_32 _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_3 19 happyReduction_33
happyReduction_33 (HappyAbsSyn9  happy_var_3)
	(HappyAbsSyn11  happy_var_2)
	_
	 =  HappyAbsSyn11
		 (do happy_var_3; happy_var_2
	)
happyReduction_33 _ _ _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_1 20 happyReduction_34
happyReduction_34 (HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn20
		 (do (fs,fsigs) <- happy_var_1; result(mkSet(fs),fsigs)
	)
happyReduction_34 _  = notHappyAtAll 

happyReduce_35 = happySpecReduce_0 20 happyReduction_35
happyReduction_35  =  HappyAbsSyn20
		 (result ({},[])
	)

happyReduce_36 = happySpecReduce_2 21 happyReduction_36
happyReduction_36 (HappyAbsSyn22  happy_var_2)
	(HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn21
		 (do (fs,fsigs) <- happy_var_1; (f,fsig) <- happy_var_2; result (f : fs,fsig:fsigs)
	)
happyReduction_36 _ _  = notHappyAtAll 

happyReduce_37 = happySpecReduce_1 21 happyReduction_37
happyReduction_37 (HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn21
		 (do (f,fsig) <- happy_var_1; result ([f],[fsig])
	)
happyReduction_37 _  = notHappyAtAll 

happyReduce_38 = happyReduce 6 22 happyReduction_38
happyReduction_38 ((HappyAbsSyn9  happy_var_6) :
	_ :
	(HappyAbsSyn5  happy_var_4) :
	(HappyAbsSyn5  happy_var_3) :
	(HappyAbsSyn12  happy_var_2) :
	_ :
	happyRest)
	 = HappyAbsSyn22
		 (do { happy_var_6; 
           ar <- happy_var_2;
           let { fname = happy_var_3 };
           typ <- str2typ happy_var_4;
           result ((fname,FDec(ar, typ)),(fname,(happy_var_4,ar)))
         }
	) : happyRest
happyReduction_38 _ = notHappyAtAll 

happyReduce_39 = happySpecReduce_2 23 happyReduction_39
happyReduction_39 (HappyAbsSyn64  happy_var_2)
	_
	 =  HappyAbsSyn23
		 (result (Just happy_var_2)
	)
happyReduction_39 _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_0 23 happyReduction_40
happyReduction_40  =  HappyAbsSyn23
		 (result Nothing
	)

happyReduce_41 = happySpecReduce_1 24 happyReduction_41
happyReduction_41 (HappyAbsSyn25  happy_var_1)
	 =  HappyAbsSyn24
		 (do (ms,msigs) <- happy_var_1; result (mkSet ms,msigs)
	)
happyReduction_41 _  = notHappyAtAll 

happyReduce_42 = happySpecReduce_0 24 happyReduction_42
happyReduction_42  =  HappyAbsSyn24
		 (result ({},[])
	)

happyReduce_43 = happySpecReduce_2 25 happyReduction_43
happyReduction_43 (HappyAbsSyn26  happy_var_2)
	(HappyAbsSyn25  happy_var_1)
	 =  HappyAbsSyn25
		 (do (ms,msigs) <- happy_var_1; (m,msig) <- happy_var_2; result (m : ms,msig:msigs)
	)
happyReduction_43 _ _  = notHappyAtAll 

happyReduce_44 = happySpecReduce_1 25 happyReduction_44
happyReduction_44 (HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn25
		 (do (m,msig) <- happy_var_1; result ([m],[msig])
	)
happyReduction_44 _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_3 26 happyReduction_45
happyReduction_45 _
	(HappyAbsSyn29  happy_var_2)
	(HappyAbsSyn27  happy_var_1)
	 =  HappyAbsSyn26
		 (do { (ar,msig,rsig,(msigJ,msigT)) <- happy_var_1; 
             ss <- map reverse happy_var_2;
             let { f (Instr _) = True;
                   f _         = False;
                   g (Instr i) = i
		 };
             (max,excs) <- getExcAndMax; 
             result ((msig,MDec(ar, rsig, 
				(map g (filter f ss)), excs, max)),
                      (msigJ,(msigT,ar)))
           }
	)
happyReduction_45 _ _ _  = notHappyAtAll 

happyReduce_46 = happySpecReduce_2 26 happyReduction_46
happyReduction_46 _
	(HappyAbsSyn27  happy_var_1)
	 =  HappyAbsSyn26
		 (do { (ar,msig,rsig,(msigJ,msigT)) <- happy_var_1; 
              result ((msig,MDec(ar, rsig, [], [], (0,0))),
                      (msigJ,(msigT,ar)))
           }
	)
happyReduction_46 _ _  = notHappyAtAll 

happyReduce_47 = happyReduce 4 27 happyReduction_47
happyReduction_47 ((HappyAbsSyn9  happy_var_4) :
	(HappyAbsSyn5  happy_var_3) :
	(HappyAbsSyn12  happy_var_2) :
	_ :
	happyRest)
	 = HappyAbsSyn27
		 (do { happy_var_4; 
            ar <- happy_var_2; 
            setMethodName happy_var_3;
            ((_ :/ (mn,asig)),rType,msig) <- str2mref True happy_var_3;
            result (ar,(mn,asig),rType,msig)
          }
	) : happyRest
happyReduction_47 _ = notHappyAtAll 

happyReduce_48 = happySpecReduce_3 28 happyReduction_48
happyReduction_48 (HappyAbsSyn9  happy_var_3)
	_
	_
	 =  HappyAbsSyn9
		 (do happy_var_3; result ()
	)
happyReduction_48 _ _ _  = notHappyAtAll 

happyReduce_49 = happySpecReduce_2 29 happyReduction_49
happyReduction_49 (HappyAbsSyn30  happy_var_2)
	(HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn29
		 (do ss <- happy_var_1; s <- happy_var_2; result (s : ss)
	)
happyReduction_49 _ _  = notHappyAtAll 

happyReduce_50 = happySpecReduce_1 29 happyReduction_50
happyReduction_50 (HappyAbsSyn30  happy_var_1)
	 =  HappyAbsSyn29
		 (map (\a -> [a]) happy_var_1
	)
happyReduction_50 _  = notHappyAtAll 

happyReduce_51 = happySpecReduce_2 30 happyReduction_51
happyReduction_51 (HappyAbsSyn9  happy_var_2)
	(HappyAbsSyn30  happy_var_1)
	 =  HappyAbsSyn30
		 (do happy_var_2; happy_var_1
	)
happyReduction_51 _ _  = notHappyAtAll 

happyReduce_52 = happySpecReduce_1 31 happyReduction_52
happyReduction_52 (HappyAbsSyn40  happy_var_1)
	 =  HappyAbsSyn30
		 (map Instr happy_var_1
	)
happyReduction_52 _  = notHappyAtAll 

happyReduce_53 = happySpecReduce_1 31 happyReduction_53
happyReduction_53 (HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn30
		 (do happy_var_1; result Directive
	)
happyReduction_53 _  = notHappyAtAll 

happyReduce_54 = happySpecReduce_1 31 happyReduction_54
happyReduction_54 (HappyAbsSyn32  happy_var_1)
	 =  HappyAbsSyn30
		 (map Label happy_var_1
	)
happyReduction_54 _  = notHappyAtAll 

happyReduce_55 = happySpecReduce_2 32 happyReduction_55
happyReduction_55 _
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn32
		 (result happy_var_1
	)
happyReduction_55 _ _  = notHappyAtAll 

happyReduce_56 = happySpecReduce_2 33 happyReduction_56
happyReduction_56 (HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (happy_var_2
	)
happyReduction_56 _ _  = notHappyAtAll 

happyReduce_57 = happySpecReduce_2 33 happyReduction_57
happyReduction_57 (HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (happy_var_2
	)
happyReduction_57 _ _  = notHappyAtAll 

happyReduce_58 = happySpecReduce_2 33 happyReduction_58
happyReduction_58 (HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (happy_var_2
	)
happyReduction_58 _ _  = notHappyAtAll 

happyReduce_59 = happySpecReduce_2 33 happyReduction_59
happyReduction_59 (HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (happy_var_2
	)
happyReduction_59 _ _  = notHappyAtAll 

happyReduce_60 = happySpecReduce_2 33 happyReduction_60
happyReduction_60 (HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (happy_var_2
	)
happyReduction_60 _ _  = notHappyAtAll 

happyReduce_61 = happyReduce 8 34 happyReduction_61
happyReduction_61 (_ :
	_ :
	_ :
	_ :
	_ :
	_ :
	_ :
	_ :
	happyRest)
	 = HappyAbsSyn9
		 (result ()
	) : happyRest
happyReduction_61 _ = notHappyAtAll 

happyReduce_62 = happyReduce 4 34 happyReduction_62
happyReduction_62 (_ :
	_ :
	_ :
	_ :
	happyRest)
	 = HappyAbsSyn9
		 (result ()
	) : happyRest
happyReduction_62 _ = notHappyAtAll 

happyReduce_63 = happySpecReduce_2 35 happyReduction_63
happyReduction_63 (HappyAbsSyn53  happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn9
		 (do { let { s = happy_var_1 };
            if (s == "locals" || s == "vars")
             then setMaxReg happy_var_2
             else if (s == "stack")
                  then setMaxOpd happy_var_2
                  else raiseErrorInLine 
                         (".limit expected \"stack\" or \"locals\", but got "
                          ++ s)
	  }
	)
happyReduction_63 _ _  = notHappyAtAll 

happyReduce_64 = happySpecReduce_1 36 happyReduction_64
happyReduction_64 _
	 =  HappyAbsSyn9
		 (result ()
	)

happyReduce_65 = happySpecReduce_1 37 happyReduction_65
happyReduction_65 _
	 =  HappyAbsSyn9
		 (result ()
	)

happyReduce_66 = happyReduce 7 38 happyReduction_66
happyReduction_66 ((HappyAbsSyn39  happy_var_7) :
	_ :
	(HappyAbsSyn39  happy_var_5) :
	_ :
	(HappyAbsSyn39  happy_var_3) :
	_ :
	(HappyAbsSyn11  happy_var_1) :
	happyRest)
	 = HappyAbsSyn9
		 (do { lfrom   <- happy_var_3;
            lto     <- happy_var_5;
            lhandle <- happy_var_7;
            cname   <- happy_var_1;
            case snd cname of {
             "all" -> insertExc (Exc(lfrom, lto, lhandle, (sysLd,"java/lang/Throwable")));
             _     -> insertExc (Exc(lfrom, lto, lhandle, cname))
	    }
          }
	) : happyRest
happyReduction_66 _ = notHappyAtAll 

happyReduce_67 = happySpecReduce_1 39 happyReduction_67
happyReduction_67 (HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn39
		 (getLabelOffset happy_var_1
	)
happyReduction_67 _  = notHappyAtAll 

happyReduce_68 = happySpecReduce_1 40 happyReduction_68
happyReduction_68 (HappyAbsSyn40  happy_var_1)
	 =  HappyAbsSyn40
		 (happy_var_1
	)
happyReduction_68 _  = notHappyAtAll 

happyReduce_69 = happySpecReduce_1 40 happyReduction_69
happyReduction_69 (HappyAbsSyn40  happy_var_1)
	 =  HappyAbsSyn40
		 (happy_var_1
	)
happyReduction_69 _  = notHappyAtAll 

happyReduce_70 = happySpecReduce_1 41 happyReduction_70
happyReduction_70 (HappyAbsSyn55  happy_var_1)
	 =  HappyAbsSyn40
		 (result happy_var_1
	)
happyReduction_70 _  = notHappyAtAll 

happyReduce_71 = happySpecReduce_2 41 happyReduction_71
happyReduction_71 (HappyAbsSyn64  happy_var_2)
	_
	 =  HappyAbsSyn40
		 (result (Prim (PrimLdc happy_var_2))
	)
happyReduction_71 _ _  = notHappyAtAll 

happyReduce_72 = happySpecReduce_2 41 happyReduction_72
happyReduction_72 (HappyAbsSyn64  happy_var_2)
	_
	 =  HappyAbsSyn40
		 (result (Prim (PrimLdc happy_var_2))
	)
happyReduction_72 _ _  = notHappyAtAll 

happyReduce_73 = happySpecReduce_2 41 happyReduction_73
happyReduction_73 (HappyAbsSyn5  happy_var_2)
	_
	 =  HappyAbsSyn40
		 (result (LoadString happy_var_2)
	)
happyReduction_73 _ _  = notHappyAtAll 

happyReduce_74 = happySpecReduce_3 41 happyReduction_74
happyReduction_74 (HappyAbsSyn53  happy_var_3)
	(HappyAbsSyn53  happy_var_2)
	(HappyAbsSyn60  happy_var_1)
	 =  HappyAbsSyn40
		 (happy_var_1 happy_var_2 happy_var_3
	)
happyReduction_74 _ _ _  = notHappyAtAll 

happyReduce_75 = happySpecReduce_3 41 happyReduction_75
happyReduction_75 (HappyAbsSyn53  happy_var_3)
	(HappyAbsSyn6  happy_var_2)
	(HappyAbsSyn61  happy_var_1)
	 =  HappyAbsSyn40
		 (do ts <- happy_var_2; happy_var_1 ts happy_var_3
	)
happyReduction_75 _ _ _  = notHappyAtAll 

happyReduce_76 = happySpecReduce_2 41 happyReduction_76
happyReduction_76 (HappyAbsSyn53  happy_var_2)
	(HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn40
		 (happy_var_1 happy_var_2
	)
happyReduction_76 _ _  = notHappyAtAll 

happyReduce_77 = happySpecReduce_2 41 happyReduction_77
happyReduction_77 (HappyAbsSyn6  happy_var_2)
	(HappyAbsSyn58  happy_var_1)
	 =  HappyAbsSyn40
		 (do t <- happy_var_2; happy_var_1 t
	)
happyReduction_77 _ _  = notHappyAtAll 

happyReduce_78 = happySpecReduce_2 41 happyReduction_78
happyReduction_78 (HappyAbsSyn6  happy_var_2)
	(HappyAbsSyn58  happy_var_1)
	 =  HappyAbsSyn40
		 (do ts <- happy_var_2; happy_var_1 ts
	)
happyReduction_78 _ _  = notHappyAtAll 

happyReduce_79 = happySpecReduce_2 41 happyReduction_79
happyReduction_79 (HappyAbsSyn5  happy_var_2)
	(HappyAbsSyn56  happy_var_1)
	 =  HappyAbsSyn40
		 (happy_var_1 happy_var_2
	)
happyReduction_79 _ _  = notHappyAtAll 

happyReduce_80 = happySpecReduce_3 41 happyReduction_80
happyReduction_80 (HappyAbsSyn53  happy_var_3)
	(HappyAbsSyn5  happy_var_2)
	(HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn40
		 (happy_var_1 happy_var_2 happy_var_3
	)
happyReduction_80 _ _ _  = notHappyAtAll 

happyReduce_81 = happySpecReduce_3 41 happyReduction_81
happyReduction_81 (HappyAbsSyn5  happy_var_3)
	(HappyAbsSyn5  happy_var_2)
	(HappyAbsSyn62  happy_var_1)
	 =  HappyAbsSyn40
		 (happy_var_1 happy_var_2 happy_var_3
	)
happyReduction_81 _ _ _  = notHappyAtAll 

happyReduce_82 = happySpecReduce_2 42 happyReduction_82
happyReduction_82 (HappyAbsSyn40  happy_var_2)
	_
	 =  HappyAbsSyn40
		 (happy_var_2
	)
happyReduction_82 _ _  = notHappyAtAll 

happyReduce_83 = happySpecReduce_2 42 happyReduction_83
happyReduction_83 (HappyAbsSyn40  happy_var_2)
	_
	 =  HappyAbsSyn40
		 (happy_var_2
	)
happyReduction_83 _ _  = notHappyAtAll 

happyReduce_84 = happySpecReduce_3 43 happyReduction_84
happyReduction_84 (HappyAbsSyn47  happy_var_3)
	(HappyAbsSyn45  happy_var_2)
	(HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn40
		 (do happy_var_1; es <- happy_var_2; dflt <- happy_var_3; result (LookupSwitch dflt (reverse es))
	)
happyReduction_84 _ _ _  = notHappyAtAll 

happyReduce_85 = happySpecReduce_1 44 happyReduction_85
happyReduction_85 (HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn9
		 (happy_var_1
	)
happyReduction_85 _  = notHappyAtAll 

happyReduce_86 = happySpecReduce_2 45 happyReduction_86
happyReduction_86 (HappyAbsSyn46  happy_var_2)
	(HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn45
		 (do es <- happy_var_1; e <- happy_var_2; result (e:es)
	)
happyReduction_86 _ _  = notHappyAtAll 

happyReduce_87 = happySpecReduce_1 45 happyReduction_87
happyReduction_87 (HappyAbsSyn46  happy_var_1)
	 =  HappyAbsSyn45
		 (do e <- happy_var_1; result [e]
	)
happyReduction_87 _  = notHappyAtAll 

happyReduce_88 = happyReduce 4 46 happyReduction_88
happyReduction_88 ((HappyAbsSyn9  happy_var_4) :
	(HappyAbsSyn39  happy_var_3) :
	_ :
	(HappyAbsSyn53  happy_var_1) :
	happyRest)
	 = HappyAbsSyn46
		 (do happy_var_4; o <- happy_var_3; result (happy_var_1,o)
	) : happyRest
happyReduction_88 _ = notHappyAtAll 

happyReduce_89 = happySpecReduce_3 47 happyReduction_89
happyReduction_89 (HappyAbsSyn39  happy_var_3)
	_
	_
	 =  HappyAbsSyn47
		 (do o <- happy_var_3; result o
	)
happyReduction_89 _ _ _  = notHappyAtAll 

happyReduce_90 = happySpecReduce_3 48 happyReduction_90
happyReduction_90 (HappyAbsSyn52  happy_var_3)
	(HappyAbsSyn50  happy_var_2)
	(HappyAbsSyn49  happy_var_1)
	 =  HappyAbsSyn40
		 (do (low,_) <- happy_var_1; ts <- happy_var_2; dflt <- happy_var_3; result (TableSwitch (low,low+length ts - 1) dflt (reverse ts))
	)
happyReduction_90 _ _ _  = notHappyAtAll 

happyReduce_91 = happySpecReduce_2 49 happyReduction_91
happyReduction_91 (HappyAbsSyn9  happy_var_2)
	(HappyAbsSyn53  happy_var_1)
	 =  HappyAbsSyn49
		 (do happy_var_2; result (happy_var_1,happy_var_1)
	)
happyReduction_91 _ _  = notHappyAtAll 

happyReduce_92 = happySpecReduce_3 49 happyReduction_92
happyReduction_92 (HappyAbsSyn9  happy_var_3)
	(HappyAbsSyn53  happy_var_2)
	(HappyAbsSyn53  happy_var_1)
	 =  HappyAbsSyn49
		 (do happy_var_3; result (happy_var_1,happy_var_2)
	)
happyReduction_92 _ _ _  = notHappyAtAll 

happyReduce_93 = happySpecReduce_2 50 happyReduction_93
happyReduction_93 (HappyAbsSyn39  happy_var_2)
	(HappyAbsSyn50  happy_var_1)
	 =  HappyAbsSyn50
		 (do ts <- happy_var_1; t <- happy_var_2; result (t:ts)
	)
happyReduction_93 _ _  = notHappyAtAll 

happyReduce_94 = happySpecReduce_1 50 happyReduction_94
happyReduction_94 (HappyAbsSyn39  happy_var_1)
	 =  HappyAbsSyn50
		 (do t <- happy_var_1; result [t]
	)
happyReduction_94 _  = notHappyAtAll 

happyReduce_95 = happySpecReduce_2 51 happyReduction_95
happyReduction_95 (HappyAbsSyn9  happy_var_2)
	(HappyAbsSyn39  happy_var_1)
	 =  HappyAbsSyn39
		 (do happy_var_2; o <- happy_var_1; result o
	)
happyReduction_95 _ _  = notHappyAtAll 

happyReduce_96 = happySpecReduce_3 52 happyReduction_96
happyReduction_96 (HappyAbsSyn39  happy_var_3)
	_
	_
	 =  HappyAbsSyn52
		 (do o <- happy_var_3; result o
	)
happyReduction_96 _ _ _  = notHappyAtAll 

happyReduce_97 = happySpecReduce_1 53 happyReduction_97
happyReduction_97 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn53
		 (conv (valueOfTok happy_var_1)
	)
happyReduction_97 _  = notHappyAtAll 

happyReduce_98 = happySpecReduce_1 54 happyReduction_98
happyReduction_98 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (strOfTok happy_var_1
	)
happyReduction_98 _  = notHappyAtAll 

happyReduce_99 = happySpecReduce_1 55 happyReduction_99
happyReduction_99 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn55
		 (case snd happy_var_1 of { JTInstr0 f -> f;
                       x          -> error (show x) }
	)
happyReduction_99 _  = notHappyAtAll 

happyReduce_100 = happySpecReduce_1 56 happyReduction_100
happyReduction_100 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn56
		 (case snd happy_var_1 of { JTInstr1w f -> f;
                       x           -> error (show x) }
	)
happyReduction_100 _  = notHappyAtAll 

happyReduce_101 = happySpecReduce_1 57 happyReduction_101
happyReduction_101 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn57
		 (case snd happy_var_1 of { JTInstr1i f -> f;
                       x           -> error (show x) }
	)
happyReduction_101 _  = notHappyAtAll 

happyReduce_102 = happySpecReduce_1 58 happyReduction_102
happyReduction_102 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn58
		 (case snd happy_var_1 of { JTInstr1at f -> f;
                       x            -> error (show x) }
	)
happyReduction_102 _  = notHappyAtAll 

happyReduce_103 = happySpecReduce_1 59 happyReduction_103
happyReduction_103 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn58
		 (case snd happy_var_1 of { JTInstr1bt f -> f;
                       x            -> error (show x) }
	)
happyReduction_103 _  = notHappyAtAll 

happyReduce_104 = happySpecReduce_1 60 happyReduction_104
happyReduction_104 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn60
		 (case snd happy_var_1 of { JTInstr2ii f -> f;
                       x            -> error (show x) }
	)
happyReduction_104 _  = notHappyAtAll 

happyReduce_105 = happySpecReduce_1 61 happyReduction_105
happyReduction_105 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn61
		 (case snd happy_var_1 of { JTInstr2ti f -> f;
                       x            -> error (show x) }
	)
happyReduction_105 _  = notHappyAtAll 

happyReduce_106 = happySpecReduce_1 62 happyReduction_106
happyReduction_106 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn62
		 (case snd happy_var_1 of { JTInstr2ww f -> f;
                       x            -> error (show x) }
	)
happyReduction_106 _  = notHappyAtAll 

happyReduce_107 = happySpecReduce_1 63 happyReduction_107
happyReduction_107 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn63
		 (case snd happy_var_1 of { JTInstr2wi f -> f;
                       x            -> error (show x) }
	)
happyReduction_107 _  = notHappyAtAll 

happyReduce_108 = happySpecReduce_1 64 happyReduction_108
happyReduction_108 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn64
		 (valueOfTok happy_var_1
	)
happyReduction_108 _  = notHappyAtAll 

happyReduce_109 = happySpecReduce_1 64 happyReduction_109
happyReduction_109 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn64
		 (valueOfTok happy_var_1
	)
happyReduction_109 _  = notHappyAtAll 

happyReduce_110 = happySpecReduce_1 65 happyReduction_110
happyReduction_110 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn64
		 (value2OfTok happy_var_1
	)
happyReduction_110 _  = notHappyAtAll 

happyReduce_111 = happySpecReduce_1 65 happyReduction_111
happyReduction_111 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn64
		 (value2OfTok happy_var_1
	)
happyReduction_111 _  = notHappyAtAll 

happyReduce_112 = happySpecReduce_1 66 happyReduction_112
happyReduction_112 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn9
		 (setErrorLine (fst happy_var_1)
	)
happyReduction_112 _  = notHappyAtAll 

happyNewToken action sts stk [] =
	action 119 119 (error "reading EOF!") (HappyState action) sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = action i i tk (HappyState action) sts stk tks in
	case tk of {
	(_, JTDCatch) -> cont 67;
	(_, JTDClass) -> cont 68;
	(_, JTDEnd) -> cont 69;
	(_, JTDField) -> cont 70;
	(_, JTDLimit) -> cont 71;
	(_, JTDLine) -> cont 72;
	(_, JTDMethod) -> cont 73;
	(_, JTDSuper) -> cont 74;
	(_, JTDSource) -> cont 75;
	(_, JTDThrows) -> cont 76;
	(_, JTDVar) -> cont 77;
	(_, JTDImplements) -> cont 78;
	(_, JTDInterface) -> cont 79;
	(_, JTTo) -> cont 80;
	(_, JTUsing) -> cont 81;
	(_, JTIs) -> cont 82;
	(_, JTFrom) -> cont 83;
	(_, JTMethod) -> cont 84;
	(_, JTAbstract) -> cont 85;
	(_, JTFinal) -> cont 86;
	(_, JTInterface) -> cont 87;
	(_, JTNative) -> cont 88;
	(_, JTPrivate) -> cont 89;
	(_, JTProtected) -> cont 90;
	(_, JTPublic) -> cont 91;
	(_, JTStatic) -> cont 92;
	(_, JTSynchronized) -> cont 93;
	(_, JTTransient) -> cont 94;
	(_, JTVolatile) -> cont 95;
	(_, JTLookupSwitch) -> cont 96;
	(_, JTTableSwitch) -> cont 97;
	(_, JTDefault) -> cont 98;
	(_, JTEq) -> cont 99;
	(_, JTSep) -> cont 100;
	(_, JTColon) -> cont 101;
	(_, JTString _) -> cont 102;
	(_, JTValI _) -> cont 103;
	(_, JTValF _) -> cont 104;
	(_, JTQuote _) -> cont 105;
	(_, JTInstr0 _) -> cont 106;
	(_, JTInstr1w _) -> cont 107;
	(_, JTInstr1at _) -> cont 108;
	(_, JTInstr1bt _) -> cont 109;
	(_, JTInstr1i _) -> cont 110;
	(_, JTInstr2ii _) -> cont 111;
	(_, JTInstr2ww _) -> cont 112;
	(_, JTInstr2wi _) -> cont 113;
	(_, JTInstr2ti _) -> cont 114;
	(_, JTInstrLdc) -> cont 115;
	(_, JTInstrLdc2) -> cont 116;
	(_, JTNotSupported _) -> cont 117;
	(_, JTError _) -> cont 118;
	}

happyThen = \m k -> k m
happyReturn = \a tks -> a
happyThen1 = happyThen
happyReturn1 = happyReturn

jasminParser = happyParse

setErrorLine :: Posn -> Parser ()
setErrorLine (Pn _ l _) = setLineNumber l

happyError :: [Token] -> Parser a
happyError [] = mraise "Parse error at end of file"
happyError ((p,x):_) = do setErrorLine p
                          raiseErrorInLine ("unexpected symbol " ++ 
                                            show x)

parse' :: (Ld,String,String) -> Error ClassFile
parse' (ld, filename, str) = 
             let StateM m = jasminParser tokens
             in case concat (map error_msg tokens) of
                 [] -> map snd $ m (mapping labelEnv, (0,0), [], 
                                    ("",1), (ld, filename))
                 xs -> mraise (unlines xs)
   where tokens = jasminLexer str
	 error_msg (Pn _ l _,JTError s)        
                      = ["lexical error " ++ s ++ " in line " ++ show l]
         error_msg (Pn _ l _,JTNotSupported s)
                      = ["use of unsupported instruction " ++ s
                         ++ " in line " ++ show l]
         error_msg _                    = []
         labelEnv :: [((MNm,LabelName), Offset)]
         labelEnv = labelEnv' "" 0 [] (map snd tokens)
         labelEnv' mn off env (JTString l : JTColon : JTSep : xs)
                  = labelEnv' mn off (((mn,l),off) : env) xs
         labelEnv' mn off env (x : xs)
                  | isInstruction x = labelEnv' mn (off+1) env xs
         labelEnv' _ _ env (JTDMethod : JTString s : JTSep : xs)
                  = labelEnv' s 0 env xs
         labelEnv' mn off env (JTDMethod : x : xs)
                  = labelEnv' mn off env (JTDMethod : xs)
         labelEnv' mn off env (x : xs)
                  = labelEnv' mn off env xs
         labelEnv' mn off env [] = env

         isInstruction (JTInstr0 _)   = True
         isInstruction (JTInstr1w _)  = True
         isInstruction (JTInstr1i _)  = True
         isInstruction (JTInstr1bt _) = True
         isInstruction (JTInstr1at _) = True
         isInstruction (JTInstr2ww _) = True
         isInstruction (JTInstr2ii _) = True
         isInstruction (JTInstr2ti _) = True
         isInstruction (JTInstr2wi _) = True
         isInstruction (JTInstrLdc)   = True
         isInstruction (JTInstrLdc2)  = True
         isInstruction (JTTableSwitch) = True
         isInstruction (JTLookupSwitch) = True
         isInstruction _              = False

parse :: String -> (CNm, ClassFile)
parse cn = case parse' (sysLd, filename, openfile filename) of
            Ok cf   -> (cNm(cf),cf)
            Error s -> error ("file: " ++ cn ++ " " ++ s)
     where filename = cn ++ ".j"{-# LINE 1 "GenericTemplate.hs" -}
{-# LINE 1 "GenericTemplate.hs" -}
-- $Id: JasminParser.hs,v 1.18 2001/03/01 12:52:43 jbook Exp $

{-# LINE 15 "GenericTemplate.hs" -}




























































-----------------------------------------------------------------------------
-- starting the parse

happyParse = happyNewToken action_0 [] []

-----------------------------------------------------------------------------
-- Arrays only: do the next action

{-# LINE 123 "GenericTemplate.hs" -}


-----------------------------------------------------------------------------
-- HappyState data type (not arrays)



newtype HappyState b c = HappyState
        (Int ->                    -- token number
         Int ->                    -- token number (yes, again)
         b ->                           -- token semantic value
         HappyState b c ->              -- current state
         [HappyState b c] ->            -- state stack
         c)



-----------------------------------------------------------------------------
-- Accepting the parse

happyAccept j tk st sts [ ans ] = happyReturn1 (case (ans) of {HappyAbsSyn4 z -> z })
happyAccept j tk st sts _       = 

				  notHappyAtAll

-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state (1) tk st sts stk@(x : _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--     trace "shifting the error token" $
     new_state i i tk (HappyState (new_state)) ((st):(sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state ((st):(sts)) ((HappyTerminal (tk)):stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happySpecReduce_0 nt fn j tk st@((HappyState (action))) sts stk
     = action nt j tk st ((st):(sts)) (fn : stk)

happySpecReduce_1 i fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@(((st@(HappyState (action))):(_))) (v1:stk')
     = action nt j tk st sts (fn v1 : stk')
happySpecReduce_1 _ _ _ _ _ _ _
     = notHappyAtAll

happySpecReduce_2 i fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happySpecReduce_2 nt fn j tk _ ((_):(sts@(((st@(HappyState (action))):(_))))) (v1:v2:stk')
     = action nt j tk st sts (fn v1 v2 : stk')
happySpecReduce_2 _ _ _ _ _ _ _
     = notHappyAtAll

happySpecReduce_3 i fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happySpecReduce_3 nt fn j tk _ ((_):(((_):(sts@(((st@(HappyState (action))):(_))))))) (v1:v2:v3:stk')
     = action nt j tk st sts (fn v1 v2 v3 : stk')
happySpecReduce_3 _ _ _ _ _ _ _
     = notHappyAtAll

happyRedcue k i fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happyReduce k nt fn j tk st sts stk = action nt j tk st1 sts1 (fn stk)
       where sts1@(((st1@(HappyState (action))):(_))) = happyDrop k ((st):(sts))

happyMonadReduce k nt fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
        happyThen1 (fn stk) (\r -> action nt j tk st1 sts1 (r : drop_stk))
       where sts1@(((st1@(HappyState (action))):(_))) = happyDrop k ((st):(sts))
             drop_stk = drop (k) stk

happyDrop (0) l = l
happyDrop n ((_):(t)) = happyDrop (n - (1)) t

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction

{-# LINE 214 "GenericTemplate.hs" -}

happyGoto action j tk st = action j j tk (HappyState action)


-----------------------------------------------------------------------------
-- Error recovery ((1) is the error token)

-- parse error if we are in recovery and we fail again
happyFail  (1) tk old_st [] stk =
--	trace "failing" $ 
    	happyError

-- discard a state
happyFail  (1) tk old_st (((HappyState (action))):(sts)) 
						(saved_tok : _ : stk) =
--	trace ("discarding state, depth " ++ show (length stk))  $
	action (1) (1) tk (HappyState (action)) sts ((saved_tok:stk))

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail  i tk (HappyState (action)) sts stk =
--      trace "entering error recovery" $
	action (1) (1) tk (HappyState (action)) sts ( (HappyErrorToken (i)) : stk)

-- Internal happy errors:

notHappyAtAll = error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions







-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.









{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.
