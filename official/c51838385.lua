--ナイトメアテーベ
--Theban Nightmare
local s,id=GetID()
function s.initial_effect(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(1500)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:GetSequence()<5
end
function s.atkcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)+Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_SZONE,0,nil)==0
end