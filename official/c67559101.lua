--先史遺産マッドゴーレム・シャコウキ
--Chronomaly Mud Golem
local s,id=GetID()
function s.initial_effect(c)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CHRONOMALY}
function s.target(e,c)
	return c:IsSetCard(SET_CHRONOMALY)
end