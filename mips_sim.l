%{
	#include<stdio.h>
	#include "directives.h"

	int reg_no;
	int int_val;
	int str_val;

	int symbol_table[26];
	int mips_reg[32];

	int tok;

%}

delim		[ \t\n]
ws			{delim}+
letter		[a-zA-Z]
digit		[0-9]

id			{letter}({letter}|{digit})*
int_num 	[+-]?{digit}+

%%

{ws}		{}

".data"		{ return T_DATA_DIRECTIVE;}
".byte"		{ return T_BYTE_DIRECTIVE;}
".half"		{ return T_HALF_DIRECTIVE;}
".word"		{ return T_WORD_DIRECTIVE;}
".text"		{ return T_TEXT_DIRECTIVE;}
".globl"	{ return T_GLOBL_DIRECTIVE;}
".end"		{ return T_END_DIRECTIVE;}

"$zero"		{ reg_no = 0; return T_REG;}
"$at"		{ reg_no = 1; return T_REG;}
"$v0"		{ reg_no = 2; return T_REG;}
"$v1"		{ reg_no = 3; return T_REG;}

"$a0"		{ reg_no = 4; return T_REG;}
"$a1"		{ reg_no = 5; return T_REG;}
"$a2"		{ reg_no = 6; return T_REG;}
"$a3"		{ reg_no = 7; return T_REG;}

"$t0"		{ reg_no = 8; return T_REG;}
"$t1"		{ reg_no = 9; return T_REG;}
"$t2"		{ reg_no = 10; return T_REG;}
"$t3"		{ reg_no = 11; return T_REG;}
"$t4"		{ reg_no = 12; return T_REG;}
"$t5"		{ reg_no = 13; return T_REG;}
"$t6"		{ reg_no = 14; return T_REG;}
"$t7"		{ reg_no = 15; return T_REG;}

"$s0"		{ reg_no = 16; return T_REG;}
"$s1"		{ reg_no = 17; return T_REG;}
"$s2"		{ reg_no = 18; return T_REG;}
"$s3"		{ reg_no = 19; return T_REG;}
"$s4"		{ reg_no = 20; return T_REG;}
"$s5"		{ reg_no = 21; return T_REG;}
"$s6"		{ reg_no = 22; return T_REG;}
"$s7"		{ reg_no = 23; return T_REG;}

"$t8"		{ reg_no = 24; return T_REG;}
"$t9"		{ reg_no = 25; return T_REG;}

"$k0"		{ reg_no = 26; return T_REG;}
"$k1"		{ reg_no = 27; return T_REG;}

"$gp"		{ reg_no = 28; return T_REG;}
"$sp"		{ reg_no = 29; return T_REG;}
"$fp"		{ reg_no = 30; return T_REG;}
"$ra"		{ reg_no = 31; return T_REG;}

":"			{ return T_COLON;}
","			{ return T_COMMA;}
"("			{ return T_LB;}
")"			{ return T_RB;}

"add"		{ return T_ADD;}
"addu"		{ return T_ADDU;}
"subu"		{ return T_SUBU;}
"li"		{ return T_LOAD_IMMEDIATE;}
"lw"		{ return T_LOAD_WORD;}
"sw"		{ return T_STORE_WORD;}
"syscall"	{ return T_SYSCALL;}
"j"			{ return T_JUMP;}

{int_num}	{int_val = strtol(yytext, NULL, 10); return T_INT_NUM;}
{id}		{str_val = yytext[0]; return T_ID;}

%%

void handleAdd();
void handleSub();
void handleDataDirective();
void handleLoadWord();
void handleStoreWord();
void handleTextDirective();

int yywrap()
{
	return 1;
}

int main()
{
	printf("\n%s\n",__FUNCTION__);
	tok = yylex();
	while(tok != T_END_DIRECTIVE)
	{
		switch(tok)
		{
			case T_DATA_DIRECTIVE:
				tok = yylex();
				handleDataDirective();
				break;

			case T_TEXT_DIRECTIVE:
				tok = yylex();
				handleTextDirective();
				break;

			defult:
				printf("ERROR!");
				break;
		}
	}
}

void handleDataDirective()
{
	printf("\n%s\n",__FUNCTION__);

	char label;

	while(tok == T_ID)
	{
		label = str_val;
		
		tok = yylex();
		if(tok == T_COLON)
		{
			tok = yylex();
			if(tok == T_WORD_DIRECTIVE)
			{
				tok = yylex();
				if(tok == T_INT_NUM)
				{
					symbol_table[label - 'a'] = int_val;
				}
			}
		}
		tok = yylex();
	}
}

void handleTextDirective()
{
	printf("\n%s\n",__FUNCTION__);

	if(tok == T_GLOBL_DIRECTIVE)
	{
		tok = yylex();
		if(tok == T_ID)
		{
			tok = yylex();
			if(tok == T_ID)
			{
				tok = yylex();
				if(tok == T_COLON)
				{
					tok = yylex();
					while(tok != T_END_DIRECTIVE)
					{
						switch(tok)
						{
							case T_LOAD_WORD:
								handleLoadWord();
								break;

							case T_STORE_WORD:
								handleStoreWord();
								break;

							case T_ADD:
								handleAdd();
								break;

							case T_SUB:
								handleSub();
								break;
						}
						tok = yylex();
					}
				}
			}
		}
	}
}

void handleLoadWord()
{
	printf("\n%s\n",__FUNCTION__);
	
	char reg[5], label;

	tok = yylex();
	if(tok == T_REG)
	{
		strcpy(reg, yytext);
		
		tok = yylex();
		if(tok == T_COMMA)
		{		
			tok = yylex();
			if(tok = T_ID)
			{
				label = str_val;
				mips_reg[reg_no] = symbol_table[label - 'a'];
			}
		}
	}
	printf("%c = %d, %s = %d \n", label, symbol_table[label - 'a'], reg, mips_reg[reg_no]);
}

void handleStoreWord()
{
	printf("\n%s\n",__FUNCTION__);

	char label;

	tok = yylex();
	if(tok == T_REG)
	{
		tok = yylex();
		if(tok == T_COMMA)
		{
			tok = yylex();
			if(tok == T_ID)
			{
				label = str_val;
				symbol_table[label - 'a'] = mips_reg[reg_no];
			}
		}
	}
	printf("%c = %d \n", label, symbol_table[label - 'a']);
}

void handleAdd()
{
	printf("\n%s\n",__FUNCTION__);

	char reg[3][5];
	int value[3];
	int regno[3];

	tok = yylex();
	if(tok == T_REG)
	{
		strcpy(reg[0], yytext);
		value[0] = mips_reg[reg_no];
		regno[0] = reg_no;
		
		tok = yylex();
		if(tok == T_COMMA)
		{
			tok = yylex();
			if(tok == T_REG)
			{
				strcpy(reg[1], yytext);
				value[1] = mips_reg[reg_no];
				regno[1] = reg_no;

				tok = yylex();
				if(tok == T_COMMA)
				{
					tok = yylex();
					if(tok == T_REG)
					{
						strcpy(reg[2], yytext);
						value[2] = mips_reg[reg_no];
						regno[2] = reg_no;
					}
				}
			}
		}
	}
	mips_reg[regno[2]] = mips_reg[regno[0]] + mips_reg[regno[1]];
	value[2] = mips_reg[regno[2]];
	printf("%s = %d, %s = %d, %s = %d;\n", reg[0], value[0], reg[1], value[1], reg[2], value[2]);
}

void handleSub()
{
	printf("\n%s\n",__FUNCTION__);

	char reg[3][5];
	int value[3];
	int regno[3];

	tok = yylex();
	if(tok == T_REG)
	{
		strcpy(reg[0], yytext);
		value[0] = mips_reg[reg_no];
		regno[0] = reg_no;
		
		tok = yylex();
		if(tok == T_COMMA)
		{
			tok = yylex();
			if(tok == T_REG)
			{
				strcpy(reg[1], yytext);
				value[1] = mips_reg[reg_no];
				regno[1] = reg_no;

				tok = yylex();
				if(tok == T_COMMA)
				{
					tok = yylex();
					if(tok == T_REG)
					{
						strcpy(reg[2], yytext);
						value[2] = mips_reg[reg_no];
						regno[2] = reg_no;
					}
				}
			}
		}
	}
	mips_reg[regno[2]] = mips_reg[regno[0]] - mips_reg[regno[1]];
	value[2] = mips_reg[regno[2]];
	printf("%s = %d, %s = %d, %s = %d;\n", reg[0], value[0], reg[1], value[1], reg[2], value[2]);
}