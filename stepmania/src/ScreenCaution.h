#ifndef SCREENCAUTION_H
#define SCREENCAUTION_H 1

/*
-----------------------------------------------------------------------------
 Class: ScreenCaution

 Desc: Screen that displays while SelectSong is being loaded.

 Copyright (c) 2001-2002 by the person(s) listed below.  All rights reserved.
	Chris Danford
-----------------------------------------------------------------------------
*/


#include "Screen.h"
#include "TransitionFade.h"
#include "TransitionFadeWipe.h"
#include "RandomSample.h"
#include "BGAnimation.h"


class ScreenCaution : public Screen
{
public:
	ScreenCaution();

	virtual void Input( const DeviceInput& DeviceI, const InputEventType type, const GameInput &GameI, const MenuInput &MenuI, const StyleInput &StyleI );
	virtual void HandleScreenMessage( const ScreenMessage SM );

protected:
	void MenuStart( PlayerNumber pn );
	void MenuBack(	PlayerNumber pn );
	BGAnimation m_Background;
	TransitionFade		m_Wipe;
	TransitionFadeWipe	m_FadeWipe;
};

#endif
