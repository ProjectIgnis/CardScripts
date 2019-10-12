--虚無
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(511001283)
	c:RegisterEffect(e2)
end
s.listed_names={id+1}
function s.cfilter(c)
	return not c:IsHasEffect(511001283) and s.filter(c)
end
function s.filter(c,minseq,maxseq)
	local seq=c:GetSequence()
	return c:IsFacedown() and c:CheckActivateEffect(true,true,false)~=nil and c:GetSequence()<5 
		and (not minseq or (seq>minseq and seq<maxseq))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
end
function s.allfilter(c)
	return c:IsFaceup() and c:IsCode(id+1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.RegisterFlagEffect(tp,100000590,RESET_CHAIN,0,1)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,c) then return end
	local sg
	local g=Duel.GetMatchingGroup(s.allfilter,tp,LOCATION_SZONE,0,nil)
	if #g>0 then
		local minseq=c:GetSequence()
		local maxseq
		g:ForEach(function(tc)
			local seq=tc:GetSequence()
			if not maxseq then
				maxseq=seq
				if minseq>maxseq then
					minseq,maxseq=maxseq,minseq
				end
			end
			if seq<minseq then
				minseq=seq
			end
			if seq>maxseq then
				maxseq=seq
			end
		end)
		sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,0,c,minseq,maxseq)
	else
		sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,0,c):RandomSelect(tp,1)
	end
	Duel.ChangePosition(sg,POS_FACEUP)
	local tc=sg:GetFirst()
	while tc do
		local tpe=tc:GetType()
		local te=tc:GetActivateEffect()
		local tg=te:GetTarget()
		local co=te:GetCost()
		local op=te:GetOperation()
		e:SetCategory(te:GetCategory())
		e:SetProperty(te:GetProperty())
		Duel.ClearTargetCard()
		if tpe&TYPE_FIELD~=0 then
			local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
			if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
				if fc then Duel.Destroy(fc,REASON_RULE) end
				fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
				if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			else
				fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
				if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			end
		end
		Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
		tc:CreateEffectRelation(te)
		if tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
			tc:CancelToGrave(false)
		end
		if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
		if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g then
			local etc=g:GetFirst()
			while etc do
				etc:CreateEffectRelation(te)
				etc=g:GetNext()
			end
		end
		if op then op(te,tp,eg,ep,ev,re,r,rp) end
		tc:ReleaseEffectRelation(te)
		if etc then	
			etc=g:GetFirst()
			while etc do
				etc:ReleaseEffectRelation(te)
				etc=g:GetNext()
			end
		end
		tc=sg:GetNext()
	end
end
