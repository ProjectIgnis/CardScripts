--アクション・キッチン
--Chaos Kitchen
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
150000004,
150000031,
150000045,
150000064,
150000023,
150000070
}