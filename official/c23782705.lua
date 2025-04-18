--マシンナーズ・スナイパー
--Machina Sniper
local s,id=GetID()
function s.initial_effect(c)
	--atk limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.tg)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MACHINA}
function s.tg(e,c)
	return c:IsSetCard(SET_MACHINA) and c:GetCode()~=id
end