--波導刀鬼丸クニツナ
--Surging-Wave Swordsman Onimaru Kunituna
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Face-up Fish monsters you control cannot be destroyed by your opponent's effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
end
function s.indtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end