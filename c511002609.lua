--Eruption of Fire
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={19384334}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.filter(c,tp)
	return c:IsCode(19384334) and c:GetActivateEffect():IsActivatable(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.tgfilter(c)
	return c:GetSequence()<5 and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		local fchk=fc and fc:IsFaceup()
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_SZONE,0,e:GetHandler())
		if fchk and #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(2843014,0)) then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
			local tg=g:Select(1-tp,1,1,nil)
			Duel.SendtoGrave(tg,REASON_EFFECT)
			local dg=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
			if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(28553439,0)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local des=dg:Select(tp,1,1,nil)
				Duel.HintSelection(des)
				Duel.BreakEffect()
				Duel.Destroy(des,REASON_EFFECT)
			end
		end
		Duel.RaiseEvent(tc,EVENT_CHAIN_SOLVED,tc:GetActivateEffect(),0,tp,tp,Duel.GetCurrentChain())
	end
end
