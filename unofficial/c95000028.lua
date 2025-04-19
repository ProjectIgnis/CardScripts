--ドン・サウザンド／罠Ｂ
--Don Thousand/Trap B
--Numeron Spell Revision
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.mark=3
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=1 and Duel.IsChainNegatable(ev)
end
function s.filter(c,tp,eg,ep,ev,re,r,rp)
	local te=c:GetActivateEffect()
	if not te then return false end
	local condition=te:GetCondition()
	local cost=te:GetCost()
	local target=te:GetTarget()
	return (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 or c:IsType(TYPE_FIELD)) and c:IsSpell()
		and (not condition or condition(te,1-tp,eg,ep,ev,re,r,rp)) and (not cost or cost(te,1-tp,eg,ep,ev,re,r,rp,0))
		and (not target or target(te,1-tp,eg,ep,ev,re,r,rp,0))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		local sg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_DECK,nil,tp,eg,ep,ev,re,r,rp)
		if #sg<=0 then return end
		Duel.ConfirmCards(tp,sg)
		local g=sg:Select(tp,1,1,nil)
		if #g then
			local tc=g:GetFirst()
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			local opt=0
			if te then
				local con=te:GetCondition()
				local co=te:GetCost()
				local tg=te:GetTarget()
				local op=te:GetOperation()
				Duel.ClearTargetCard()
				e:SetCategory(te:GetCategory())
				e:SetProperty(te:GetProperty())
				local loc=LOCATION_SZONE
				if (tpe&TYPE_FIELD)~=0 then
					loc=LOCATION_FZONE
					local of=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
					if of and Duel.Destroy(of,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				end
				Duel.MoveToField(tc,tp,1-tp,loc,POS_FACEUP,true)
				Duel.Hint(HINT_CARD,0,tc:GetCode())
				tc:CreateEffectRelation(te)
				if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
					tc:CancelToGrave(false)
				end
				if co then co(te,1-tp,eg,ep,ev,re,r,rp,1) end
				if tg then tg(te,1-tp,eg,ep,ev,re,r,rp,1) end
				local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				if g then
					for etc in aux.Next(g) do
						etc:CreateEffectRelation(te)
					end
				end
				Duel.BreakEffect()
				if op then op(te,1-tp,eg,ep,ev,re,r,rp) end
				tc:ReleaseEffectRelation(te)
				if etc then
					etc=g:GetFirst()
					while etc do
						etc:ReleaseEffectRelation(te)
						etc=g:GetNext()
					end
				end
			end
		end
	end
end