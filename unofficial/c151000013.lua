--クロス・オーバー・アクセル
--Crossover Acceleration
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
end
s.af="at"
s.tableAction = {
150000001,
150000005,
150000020,
150000021,
150000022,
150000024,
150000068
}