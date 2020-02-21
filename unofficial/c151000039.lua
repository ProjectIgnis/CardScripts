--クイズ・フロンティア
--Quiz Quest
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
--150000086,
150000052,
150000053,
150000054,
150000055,
150000056,
150000057,
150000058,
150000059
}