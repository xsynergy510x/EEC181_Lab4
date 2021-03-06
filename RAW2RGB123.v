// --------------------------------------------------------------------
// Copyright (c) 20057 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	RAW2RGB
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| 		Changes Made:
//   V1.0 :| Johnny Fan        :| 07/08/01  :|      Initial Revision
// --------------------------------------------------------------------

module RAW2RGB(	oRed,
				oGreen,
				oBlue,
				oDVAL,
				iX_Cont,
				iY_Cont,
				iDATA,
				iDVAL,
				iCLK,
				iRST,
				rotate
				);

input [2:0] rotate;
input	[10:0]	iX_Cont;
input	[10:0]	iY_Cont;
input	[11:0]	iDATA;
input			iDVAL;
input			iCLK;
input			iRST;
output	[11:0]	oRed;
output	[11:0]	oGreen;
output	[11:0]	oBlue;
output			oDVAL;
wire	[11:0]	mDATA_0;
wire	[11:0]	mDATA_1;
wire	[11:0]	mDATA_2;
reg		[11:0]	mDATAd_0;
reg		[11:0]	mDATAd_1;
reg		[11:0]	mDATAd_2;

//addictional reg needed to store previous value
reg		[11:0]	mDATAe_0;
reg		[11:0]	mDATAe_1;
reg		[11:0]	mDATAe_2;

reg		[11:0]	mCCD_R;
reg		[12:0]	mCCD_G;
reg		[11:0]	mCCD_B;
reg				mDVAL;

assign	oRed	=	mCCD_R[11:0];
assign	oGreen	=	mCCD_G[12:1];
assign	oBlue	=	mCCD_B[11:0];
assign	oDVAL	=	mDVAL;

Line_Buffer1 	u0	(	.clken(iDVAL),
						.clock(iCLK),
						.shiftin(iDATA),
						.taps0x(mDATA_1),
						.taps1x(mDATA_0));
//		.taps2x(mDATA_0));
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		mCCD_R	<=	0;
		mCCD_G	<=	0;
		mCCD_B	<=	0;
		mDATAd_0<=	0;
		mDATAd_1<=	0;
		mDATAd_2<=  0;
		mDATAe_0<=	0;
		mDATAe_1<=	0;
		mDATAe_2<=  0;
		mDVAL	<=	0;
	end
	else if(rotate == 3'b000)
	begin
		
		mDATAd_0	<=	mDATA_0; //store current value to previous value reg
		mDATAd_1	<=	mDATA_1;
		mDATAd_2 <=	mDATA_2;
		
		mDATAe_0 <= mDATAd_0; //store previous value to another previous value reg
		mDATAe_1 <= mDATAd_1;
		mDATAe_2 <= mDATAd_2;
		
		mDVAL		<=	{iY_Cont[0]|iX_Cont[0]}	?	1'b0	:	iDVAL;
		if({iY_Cont[0],iX_Cont[0]}==2'b10) //10
		begin
			//mCCD_R	<=	mDATAd_1;
			//mCCD_G	<=	mDATA_1+mDATAd_0+mDATAd_2+mDATAe_1;
			//mCCD_B	<=	mDATA_0+mDATA_2+mDATAe_0+mDATAe_2;
			mCCD_R	<=	mDATA_1+mDATAe_1;
			mCCD_G	<=	mDATA_0+mDATA_2+mDATAd_1+mDATAe_0+mDATAe_2;
			mCCD_B	<=	mDATAd_0+mDATAd_2;
		end	
		else if({iY_Cont[0],iX_Cont[0]}==2'b11)//11
		begin
			//mCCD_R	<=	mDATAd_0+mDATAd_2;
			//mCCD_G	<=	mDATA_1+mDATA_2+mDATAd_1+mDATAe_0+mDATAe_2;
			//mCCD_B	<=	mDATA_1+mDATAe_1;
			
			mCCD_R	<=	mDATAd_1;
			mCCD_G	<=	mDATA_1+mDATAd_0+mDATAd_2+mDATAe_1;
			mCCD_B	<=	mDATA_0+mDATA_2+mDATAe_0+mDATAe_2;
			
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b00)//00
		begin
			//mCCD_R	<= mDATA_1+mDATAe_1;
			//mCCD_G	<=	mDATA_1+mDATA_2+mDATAd_1+mDATAe_0+mDATAe_2;
			//mCCD_B	<=	mDATAd_0+mDATAd_2;
			
			mCCD_R	<=	mDATA_0+mDATA_2+mDATAe_0+mDATAe_2;
			mCCD_G	<=	mDATA_1+mDATAd_0+mDATAd_2+mDATAe_1;
			mCCD_B	<=	mDATAd_1;
			
			
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b01)//01
		begin
			//mCCD_R	<=	mDATA_0+mDATA_2+mDATAe_0+mDATAe_2;
			//mCCD_G	<=	mDATA_1+mDATAd_0+mDATAd_2+mDATAe_1;
			//mCCD_B	<=	mDATAd_1;
			
			mCCD_R	<=	mDATAd_0+mDATAd_2;
			mCCD_G	<=	mDATA_0+mDATA_2+mDATAd_1+mDATAe_0+mDATAe_2;
			mCCD_B	<= mDATA_1+mDATAe_1;
			
		end
		
		
		
		
		
		
		
		//if({iY_Cont[0],iX_Cont[0]}==2'b10) //10
		//begin
		//	mCCD_R	<=	mDATAd_1;
		//	mCCD_G	<=	mDATA_1+mDATAd_0+mDATAd_2+mDATAe_1;
		//	mCCD_B	<=	mDATA_0+mDATA_2+mDATAe_0+mDATAe_2;
//
		//end	
		//else if({iY_Cont[0],iX_Cont[0]}==2'b11)//11
		//begin
		//	mCCD_R	<=	mDATAd_0+mDATAd_2;
		//	mCCD_G	<=	mDATA_1+mDATA_2+mDATAd_1+mDATAe_0+mDATAe_2;
		//	mCCD_B	<=	mDATA_1+mDATAe_1;
		//end
		//else if({iY_Cont[0],iX_Cont[0]}==2'b00)//00
		//begin
		//	mCCD_R	<= mDATA_1+mDATAe_1;
		//	mCCD_G	<=	mDATA_1+mDATA_2+mDATAd_1+mDATAe_0+mDATAe_2;
		//	mCCD_B	<=	mDATAd_0+mDATAd_2;
		//end
		//else if({iY_Cont[0],iX_Cont[0]}==2'b01)//01
		//begin
		//	mCCD_R	<=	mDATA_0+mDATA_2+mDATAe_0+mDATAe_2;
		//	mCCD_G	<=	mDATA_1+mDATAd_0+mDATAd_2+mDATAe_1;
		//	mCCD_B	<=	mDATAd_1;
		//end
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	end
	else if(rotate == 3'b010) //rotate by 180 degree
	begin
		mDATAd_0	<=	mDATA_0;
		mDATAd_1	<=	mDATA_1;
		mDVAL		<=	{iY_Cont[0]|iX_Cont[0]}	?	1'b0	:	iDVAL;
		if({iY_Cont[0],iX_Cont[0]}==2'b01) //10
		begin
			mCCD_R	<=	mDATA_0;
			mCCD_G	<=	mDATAd_0+mDATA_1;
			mCCD_B	<=	mDATAd_1;
		end	
		else if({iY_Cont[0],iX_Cont[0]}==2'b00)//11
		begin
			mCCD_R	<=	mDATAd_0;
			mCCD_G	<=	mDATA_0+mDATAd_1;
			mCCD_B	<=	mDATA_1;
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b11)//00
		begin
			mCCD_R	<=	mDATA_1;
			mCCD_G	<=	mDATA_0+mDATAd_1;
			mCCD_B	<=	mDATAd_0;
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b10)//01
		begin
			mCCD_R	<=	mDATAd_1;
			mCCD_G	<=	mDATAd_0+mDATA_1;
			mCCD_B	<=	mDATA_0;
		end
	end
	
end

endmodule


