--エテルナム・ヴォイドヴェルグ・レクイエム
--Eternum Voidvelg Requiem
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.matfilter,1,99,160010025)
	--Spells/Traps cannot be returned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_DECK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcond)
	e1:SetTarget(s.indtg2)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e2)
	--spsummon success
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.sucop)
	c:RegisterEffect(e3)
end
s.named_material={160015003}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,scard,sumtype,tp) and c:IsRace(RACE_GALAXY,scard,sumtype,tp)
end
function s.indcond(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end
function s.indtg2(e,c)
	return c==e:GetHandler()
end
function s.value(e,re,rp)
	return nil~=re and re:GetHandler():IsMonster()
end
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetMaterialCount()>=3 then
		--Cannot be destroyed
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3001)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end