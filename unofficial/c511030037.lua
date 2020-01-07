--天装騎兵セグメンタタ
--Armatos Legio Segmentata
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--linked check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD_P)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.linkcon)
	e1:SetOperation(s.linkop)
	c:RegisterEffect(e1)
	--return
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.retcost)
	e2:SetCondition(s.retcon)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
function s.linkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsLinked() then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) and Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.PayLPCost(tp,1000)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetLabelObject():GetLabel()==1
end
function s.mgfilter(c,e,tp,linkc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and (c:GetReason()&(REASON_LINK+REASON_MATERIAL))==(REASON_LINK+REASON_MATERIAL) and c:GetReasonCard()==linkc
		and c:IsAbleToDeck()
end
function s.tdfilter(c,tp)
	return (c:IsAbleToDeck() or c:IsAbleToHand())
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	local mg=rc:GetMaterial()
	if chk==0 then
		local tdg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,mg)
		local thg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToHand),tp,LOCATION_GRAVE,0,mg)
		return #mg>0 and mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,rc,mg)==#mg
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,rc:GetLink()+1,mg)
			and #tdg>=rc:GetLink() and #thg>=1
	end
	e:SetLabel(rc:GetLink())
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#mg+rc:GetLink(),0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_GRAVE)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	local mg=rc:GetMaterial()
	local lr=e:GetLabel()
	if not (mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,rc,mg)==#mg) then return end
	if #mg>0 and Duel.SendtoDeck(mg,nil,2,REASON_EFFECT)==#mg then
		local tdg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,mg)
		if #tdg<lr then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=tdg:Select(tp,lr,lr,mg)
		if #g<=0 then return end
		Duel.BreakEffect()
		if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)==lr then
			local thg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToHand),tp,LOCATION_GRAVE,0,mg)
			if #thg<=0 then return end
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RTOHAND)
			local g2=thg:Select(1-tp,1,1,mg)
			if #g2<=0 then return end
			Duel.BreakEffect()
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end
	e:GetLabelObject():SetLabel(0)
end