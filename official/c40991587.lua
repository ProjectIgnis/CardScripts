--ワイト夫人
--The Lady in Wight
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Skull Servant" while in GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(CARD_SKULL_SERVANT)
	c:RegisterEffect(e1)
	--Other level 3 or lower zombie monsters cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.etarget)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Other level 3 or lower zombie monsters are unaffected by spells/traps
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.etarget)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_SKULL_SERVANT}
function s.etarget(e,c)
	return c:GetCode()~=id and c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(3)
end
function s.efilter(e,te)
	return te:IsSpellTrapEffect() and not te:GetHandler():IsCode(4064256)
end