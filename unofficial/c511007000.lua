--coded by Lyris
--DDアーク
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--When this card is in a Pendulum Zone, and there is a card in the other Pendulum Zone, you may ignore the Pendulum Summons scale.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(id)
	c:RegisterEffect(e1)
end
