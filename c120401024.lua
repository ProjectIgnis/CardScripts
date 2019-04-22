--幻獣覇者カルカダン
--Phantom Beast Master Karkadann
--Scripted by Eerie Code
function c120401024.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,c120401024.matfilter,aux.FilterBoolFunctionEx(Card.IsRace,RACE_BEASTWARRIOR))
	--attack all
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(120401024,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c120401024.condition)
	e1:SetCost(c120401024.cost)
	e1:SetOperation(c120401024.operation)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetTarget(c120401024.rmtg)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c120401024.descon)
	e3:SetTarget(c120401024.destg)
	e3:SetOperation(c120401024.desop)
	c:RegisterEffect(e3)
end
function c120401024.matfilter(c)
	return c:IsLevelAbove(6) and c:IsSetCard(0x1b)
end
function c120401024.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function c120401024.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,1,e:GetHandler()) end
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,e:GetHandler())
	Duel.Release(g,REASON_COST)
end
function c120401024.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,1)
		e2:SetValue(c120401024.aclimit)
		e2:SetCondition(c120401024.actcon)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
function c120401024.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function c120401024.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
function c120401024.rmtg(e,c)
	return not c:IsControler(e:GetHandlerPlayer())
end
function c120401024.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and rp~=tp
end
function c120401024.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,LOCATION_ONFIELD,dg,dg:GetCount(),0,0)
end
function c120401024.rmfilter(c)
	return c:IsSetCard(0x1b) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function c120401024.spfilter(c,e,tp)
	return c:IsSetCard(0x1b) and c:IsLevelAbove(6) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c120401024.desop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if Duel.Destroy(dg,REASON_EFFECT)==0 then return end
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c120401024.rmfilter),tp,LOCATION_GRAVE,0,c)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=bit.bor(loc,LOCATION_DECK) end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=bit.bor(loc,LOCATION_EXTRA) end
	if loc==0 then return end
	local sg=Duel.GetMatchingGroup(c120401024.spfilter,tp,loc,0,nil,e,tp)
	if c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove()
		and rg:GetCount()>=2 and sg:GetCode()>0
		and Duel.SelectYesNo(tp,aux.Stringid(120401024,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg2=rg:Select(tp,2,2,nil)
		rg2:AddCard(c)
		Duel.Remove(rg2,POS_FACEUP,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg2=sg:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg2,0,tp,tp,true,false,POS_FACEUP)
	end
end
