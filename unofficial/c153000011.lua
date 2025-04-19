--速攻の黒い忍者 (Deck Master)
--Strike Ninja (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dme1:SetCode(EVENT_FREE_CHAIN)
	dme1:SetCondition(s.dmcon)
	dme1:SetOperation(s.dmop)
	local dme2=dme1:Clone()
	dme2:SetCode(EVENT_CHAIN_END)
	DeckMaster.RegisterAbilities(c,dme1,dme2)
	--Remove
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,2,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,2,2,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function s.filter(c,p)
	return c:IsFacedown() and (c:IsControler(p) or (c:IsLocation(LOCATION_FZONE) or Duel.GetLocationCount(p,LOCATION_SZONE)>0))
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler(),tp)
		and Duel.IsDeckMaster(tp,id)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) or Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)~=2 then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler(),tp):GetFirst()
	if tc then
		Duel.HintSelection(Group.FromCards(tc))
		Duel.ConfirmCards(tp,tc)
		local te,teg,tep,tev,tre,tr,trp=tc:CheckActivateEffect(true,true,true)
		if te then
			local con=te:GetCondition()
			local tg=te:GetTarget()
			local co=te:GetCost()
			if (not con or con(te,tp,teg,tep,tev,tre,tr,trp))
				and (not co or co(te,tp,teg,tep,tev,tre,tr,trp,0))
				and (not tg or tg(te,tp,teg,tep,tev,tre,tr,trp,0))
				and (tc:IsControler(tp) or Duel.MoveToField(tc,tp,tp,tc:IsType(TYPE_FIELD) and LOCATION_FZONE or LOCATION_SZONE,POS_FACEDOWN,true)) then
				if te:IsActivatable(tp) then
					Duel.Activate(te)
				elseif not tc:IsControler(tp) then
					Duel.MoveToField(tc,tp,1-tp,tc:GetPreviousLocation(),tc:GetPreviousPosition(),true,2^tc:GetPreviousSequence())
				end
			end
		end
	end
end