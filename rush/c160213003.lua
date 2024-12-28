--真紅眼の極炎竜［Ｒ］
--Red-Eyes Maxi-Flare Dragon [R]
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Spells/Traps cannot be returned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_DECK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcond)
	e1:SetTarget(s.indtg)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e2)
	c:AddSideMaximumHandler(e2)
	--Change name
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ADD_CODE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(CARD_REDEYES_B_DRAGON)
	e3:SetOperation(s.chngcon)
	c:RegisterEffect(e3)
	c:AddSideMaximumHandler(e3)
end
s.MaximumSide="Right"
function s.indcond(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end
function s.indtg(e,c)
	return c:IsSpellTrap()
end
function s.value(e,re,rp)
	return nil~=re
end
function s.chngcon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0 or (sumtype&SUMMON_TYPE_FUSION)~=0
end