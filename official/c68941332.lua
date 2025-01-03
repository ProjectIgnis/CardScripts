--六花の薄氷
--Rikka Sheet
--scripted by Naim, updated by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Prevent the target's effects from being activated and gain control if a Plant is tributed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT>0)
end
function s.cfilter(c,tp)
	return c:IsRikkaReleasable(tp) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		and Duel.IsExistingTarget(aux.AND(s.filter,Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,c,true)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil)
	local b=Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,tp)
	if chk==0 then return a or b end
	if b and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp)
		Duel.Release(g,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	if e:GetLabel()==1 then
		local g=Duel.SelectTarget(tp,aux.AND(s.filter,Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,1,nil,true)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
		local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local c=e:GetHandler()
		--Target cannot activate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Gain control of the target
		if e:GetLabel()==1 and tc:IsControlerCanBeChanged() and tc:IsControler(1-tp) then
			Duel.BreakEffect()
			Duel.GetControl(tc,tp,PHASE_END,1)
			if tc:IsControler(1-tp) then return end
			--Target becomes a Plant monster
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetValue(RACE_PLANT)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end