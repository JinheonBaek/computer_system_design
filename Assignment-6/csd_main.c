
#pragma GCC target ("thumb")

void thumb_C_test()
{
	int indata[32];		// init indata variable
	indata[0] = 2; indata[1] = 0; indata[2] = -7; indata[3] = -1; indata[4] = 3; indata[5] = 8; indata[6] = -4; indata[7] = 10;
	indata[8] = -9; indata[9] = -16; indata[10] = 15; indata[11] = 13; indata[12] = 1; indata[13] = 4; indata[14] = -3; indata[15] = 14;
	indata[16] = -8; indata[17] = -10; indata[18] = -15; indata[19] = 6; indata[20] = -13; indata[21] = -5; indata[22] = 9; indata[23] = 12;
	indata[24] = -11; indata[25] = -14; indata[26] = -6; indata[27] = 11; indata[28] = 5; indata[29] = 7; indata[30] = -2; indata[31] = -12;

	int outdata[32];	// init outdata variable

	int temp;			// temp variable to swap in sorting algorithm

	// Sort Using Bubble Sort
	for (int i = 0; i < 32; i++)
	{
		for (int j = 0; j < 31 - i; j++)
		{
			if (indata[j] > indata[j+1])
			{
				// If order is not increment, swap
				temp = indata[j];
				indata[j] = indata[j+1];
				indata[j+1] = temp;
			}
		}
	}

	// Data save to outdata from indata (that is already sorted)
	for (int i = 0; i < 32; i++)
		outdata[i] = indata[i];

	return;
}


#pragma GCC target ("arm")

void arm_C_test()
{
	int indata[32];		// init indata variable
	indata[0] = 2; indata[1] = 0; indata[2] = -7; indata[3] = -1; indata[4] = 3; indata[5] = 8; indata[6] = -4; indata[7] = 10;
	indata[8] = -9; indata[9] = -16; indata[10] = 15; indata[11] = 13; indata[12] = 1; indata[13] = 4; indata[14] = -3; indata[15] = 14;
	indata[16] = -8; indata[17] = -10; indata[18] = -15; indata[19] = 6; indata[20] = -13; indata[21] = -5; indata[22] = 9; indata[23] = 12;
	indata[24] = -11; indata[25] = -14; indata[26] = -6; indata[27] = 11; indata[28] = 5; indata[29] = 7; indata[30] = -2; indata[31] = -12;

	int outdata[32];	// init outdata variable

	int temp;			// temp variable to swap in sorting algorithm

	// Sort Using Bubble Sort
	for (int i = 0; i < 32; i++)
	{
		for (int j = 0; j < 31 - i; j++)
		{
			if (indata[j] > indata[j+1])
			{
				// If order is not increment, swap
				temp = indata[j];
				indata[j] = indata[j+1];
				indata[j+1] = temp;
			}
		}
	}

	// Data save to outdata from indata (that is already sorted)
	for (int i = 0; i < 32; i++)
		outdata[i] = indata[i];

	return;
}
