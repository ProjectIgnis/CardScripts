--剣の墓場
--Sword's Cemetery
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
s.af="a"
s.tableAction = {
150000024,
150000042,
150000025,150000025,150000025,
150000048,150000048
}