--妖仙獣 侍郎風
--Yosenju Saburokaze
--scripted by AlphaKreitn
local s,id=GetID()
function s.initial_effect(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.actg)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
	--return
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
s.listed_series={0xb3}
s.listed_names={62681049,79861914}
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0xb3),tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function s.thfilter(c)
	return c:IsSetCard(0xb3) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3) and c:IsAbleToDeck()
end
function s.acfilter(c,tp)
	return c:IsCode(62681049,79861914) and not c:IsForbidden() --and c:GetActivateEffect():IsActivatable(tp)
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) and 
		Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local ag=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #ag>0 then
		local ac=ag:GetFirst()
		if Duel.MoveToField(ac,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			--[[local te=ac:GetActivateEffect()
			local tep=ac:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			removed, reason: uncertain if this effect byopasses costs and activation requirements
			--]]
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToEffect(e) then
				Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
			end
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(s.rettg)
	e1:SetOperation(s.retop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~(RESET_TEMP_REMOVE|RESET_TURN_SET)|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e1)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end