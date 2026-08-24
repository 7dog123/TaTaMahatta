#include "gdiX.h"
#include "GDIX_I.H"

PUBLIC void GFXHideCursor (void)
{
	ShowCursor (FALSE);
}

PUBLIC void GFXShowCursor (void)
{
	ShowCursor (TRUE);
}
