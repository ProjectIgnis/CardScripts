--極東秘泉郷
--Hidden Springs of the Far East
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--Recover/Effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(s.reccon)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPhase(PHASE_MAIN2)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=Duel.GetTurnPlayer()
	if Duel.Recover(p,500,REASON_EFFECT)~=0 then
		--Prevent negation of Normal/Special Summons
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
		e1:SetRange(LOCATION_FZONE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,p)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
		Duel.RegisterEffect(e2,p)
		--Cannot negate activation of Spell/Trap/Monster effects to SS a monster
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_INACTIVATE)
		e3:SetRange(LOCATION_FZONE)
		e3:SetValue(s.efilter)
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,p)
		--Set Spell/Traps cannot be destroyed or targeted 
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e4:SetRange(LOCATION_FZONE)
		e4:SetTargetRange(LOCATION_SZONE,0)
		e4:SetTarget(aux.TargetBoolFunction(Card.IsPosition,POS_FACEDOWN))
		e4:SetReset(RESET_PHASE|PHASE_END)
		e4:SetValue(s.tgvalue)
		Duel.RegisterEffect(e4,p)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		Duel.RegisterEffect(e5,p)
	end
end
function s.efilter(e,ct)
	local p=Duel.GetTurnPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and te:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
end
function s.tgvalue(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end