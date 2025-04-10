--メンタル・チューナー
--Mental Tuner
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Change this card's level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
end
function s.rmfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
		and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c,true))
end
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsCanBeEffectTarget(e)
end
function s.attrescon(sg)
	return sg:GetClassCount(Card.GetAttribute)==#sg
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rmg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE,0,c)
	local tgg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return c:HasLevel() and (#rmg>0 or #tgg>0) end
	e:SetCategory(0)
	e:SetProperty(0)
	local op=Duel.SelectEffect(tp,
		{#rmg>0,aux.Stringid(id,1)},
		{#tgg>0,aux.Stringid(id,2)})
	if op==1 then
		local rg=aux.SelectUnselectGroup(rmg,e,tp,1,2,s.attrescon,1,tp,HINTMSG_REMOVE)
		Duel.Remove(rg,POS_FACEUP,REASON_COST)
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		e:SetLabel(op,ct)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOGRAVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local tg=aux.SelectUnselectGroup(tgg,e,tp,1,2,s.attrescon,1,tp,HINTMSG_TOGRAVE)
		Duel.SetTargetCard(tg)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,#tg,0,0)
		e:SetLabel(2)
	end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local op,ct=e:GetLabel()
	if op==2 then
		local tg=Duel.GetTargetCards(e)
		if #tg>0 then
			ct=Duel.SendtoGrave(tg,REASON_EFFECT|REASON_RETURN)
		end
	elseif op~=1 then return end
	if not ct or ct==0 then return end
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup() and c:HasLevel()) then return end
	local b1=c:IsLevelAbove(ct+1)
	local b2=true
	local lvop=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)})
	if lvop then
		c:UpdateLevel(lvop==1 and ct or -ct,RESETS_STANDARD_DISABLE_PHASE_END)
	end
end