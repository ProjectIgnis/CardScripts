--タキオン・ギャラクシースパイラル
--Tachyon Spiral Galaxy
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 Dragon "Galaxy" monster unaffected by other card effects and prevent battle destruction
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_BATTLE_START|TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GALAXY,SET_GALAXY_EYES_TACHYON_DRAGON}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GALAXY) and c:IsRace(RACE_DRAGON)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Unaffected by other card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3100)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Cannot be destroyed by battle
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3000)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function s.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
function s.hfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GALAXY_EYES_TACHYON_DRAGON)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.hfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end