--アーティファクト・ムーブメント
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--skip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={0x97}
function s.filter(c)
	return c:IsSetCard(0x97) and c:IsType(TYPE_MONSTER) and c:IsSSetable(true)
end
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.desfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetSequence()<5
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then
		if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) then return false end
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
		if ft<0 then return false
		elseif ft>0 then
			return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		else
			return Duel.IsExistingTarget(s.desfilter2,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		end
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	if ft>0 then
		g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	else
		g=Duel.SelectTarget(tp,s.desfilter2,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and e:GetHandler():IsPreviousControler(tp)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	if Duel.GetTurnPlayer()~=tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)
end
function s.skipcon(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end
