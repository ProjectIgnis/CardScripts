--手中掌握
--Hand Control
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_SPELL,OPCODE_ISTYPE}
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	e:GetHandler():SetHint(CHINT_CARD,ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND,nil,ac)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		if te then
			local tpe,con,co,tg,op=tc:GetType(),te:GetCondition(),te:GetCost(),te:GetTarget(),te:GetOperation()
			if (con and not con(te,1-tp,eg,ep,ev,re,r,rp)) or (co and not co(te,1-tp,eg,ep,ev,re,r,rp,0)) or (tg and not tg(te,1-tp,eg,ep,ev,re,r,rp,0))
				or (not tc:IsType(TYPE_FIELD) and Duel.GetLocationCount(1-tp,LOCATION_SZONE)<=0) then return end
			Duel.ClearTargetCard()
			local loc=LOCATION_SZONE
			if (tpe&TYPE_FIELD)~=0 then
				loc=LOCATION_FZONE
				local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
				if Duel.IsDuelType(DUEL_1_FIELD) then
					if fc then Duel.Destroy(fc,REASON_RULE) end
					fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				else
					Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
					if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				end
			end
			Duel.MoveToField(tc,1-tp,1-tp,loc,POS_FACEUP,true)
			Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
			tc:CreateEffectRelation(te)
			if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
				tc:CancelToGrave(false)
			end
			if co then co(te,1-tp,eg,ep,ev,re,r,rp,1) end
			if tg then tg(te,1-tp,eg,ep,ev,re,r,rp,1) end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				local etc=g:GetFirst()
				while etc do
					etc:CreateEffectRelation(te)
					etc=g:GetNext()
				end
			end
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