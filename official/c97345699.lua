--宵星の閃光
--Vesper Girsu
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Your opponent can send any number of monsters they control to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_RECOVER+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)+2 end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,1,1-tp,2000)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
	if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToGrave,1-tp,LOCATION_MZONE,0,1,#g,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT,PLAYER_NONE,1-tp)
		end
	end
	local ct=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MZONE,nil)
	if ct==0 then
		--Halve your LP
		Duel.SetLP(tp,Duel.GetLP(tp)//2)
	elseif ct==1 then
		--Your opponent gains 2000 LP
		Duel.Recover(1-tp,2000,REASON_EFFECT)
	elseif ct==2 then
		--Banish your opponent's hand face-up until the End Phase
		local rmg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
		if #rmg==0 then return end
		aux.RemoveUntil(rmg,POS_FACEUP,REASON_EFFECT,PHASE_END,id,e,tp,function(rg) Duel.SendtoHand(rg,nil,REASON_EFFECT) end)
	elseif ct>=3 then
		--Your opponent cannot activate monster effects this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(function(e,re,rp) return re:IsMonsterEffect() end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end