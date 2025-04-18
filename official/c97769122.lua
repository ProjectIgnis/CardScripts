--バリアンズ・カオス・ドロー
--Barian's Chaos Draw
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NUMBER,SET_SEVENTH}
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsPhase(PHASE_DRAW) and c:IsReason(REASON_RULE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_MAIN1)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_MAIN1,EFFECT_FLAG_CLIENT_HINT,1,0,66)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPhase(PHASE_MAIN1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)~=0 end
end
function s.copfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(SET_SEVENTH) and c:IsNormalSpell()
		and c:CheckActivateEffect(true,true,false)~=nil 
end
function s.xyzfilter(c,tp,sg,g)
	return c:IsSetCard(SET_NUMBER) and c:IsXyzSummonable(sg,sg+g)
		and Duel.GetLocationCountFromEx(tp,tp,sg+g,c)>0
end
function s.rescon(sg,e,tp,mg)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,tp,sg,g)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	e:SetCategory(0)
	local mg=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_DECK,0,nil,e,0,tp,false,false)
	local b1=e:GetLabel()==100 and Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK,0,1,nil)
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft>0 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local b2=Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and ft>0 and #mg>0 and aux.SelectUnselectGroup(mg,e,tp,1,ft,s.rescon,0)
	if chk==0 then
		local res=b1 or b2
		e:SetLabel(0)
		return res
	end
	e:SetLabel(0)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.copfilter,tp,LOCATION_DECK,0,1,1,nil)
		if not Duel.SendtoGrave(g,REASON_COST) then return end
		local te=g:GetFirst():CheckActivateEffect(true,true,false)
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		local tg=te:GetTarget()
		if tg then
			tg(e,tp,eg,ep,ev,re,r,rp,1)
		end
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
		e:SetLabelObject(te)
		Duel.ClearOperationInfo(0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
	e:SetLabel(op)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local te=e:GetLabelObject()
		if te then
			e:SetLabel(te:GetLabel())
			e:SetLabelObject(te:GetLabelObject())
			local op=te:GetOperation()
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
			te:SetLabel(e:GetLabel())
			te:SetLabelObject(e:GetLabelObject())
		end
	elseif op==2 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
		local mg=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_DECK,0,nil,e,0,tp,false,false)
		if #mg==0 then return end
		local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
		if ft>0 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local sg=aux.SelectUnselectGroup(mg,e,tp,1,ft,s.rescon,1,tp,HINTMSG_SPSUMMON,s.rescon)
		if #sg==0 then return end
		for tc in aux.Next(sg) do
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				--Negate their effects
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				tc:RegisterEffect(e2)
			end
		end
		Duel.SpecialSummonComplete()
		local fg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyzg=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp,sg,fg)
		if #xyzg>0 then
			Duel.XyzSummon(tp,xyzg:GetFirst(),sg)
		end
	end
end