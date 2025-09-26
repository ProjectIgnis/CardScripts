--
--R.B. Lambda Blade
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 "R.B." card from your Deck to the GY, except "R.B. Lambda Blade"
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOGRAVE)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.tgtg)
	e1a:SetOperation(s.tgop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--Destroy this card, and if you do, take control of an opponent's monster, but destroy it during the End Phase card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetCost(Cost.PayLP(1400))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_RB}
function s.tgfilter(c)
	return c:IsSetCard(SET_RB) and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.desconfilter(c,ec,lg)
	return c:IsSetCard(SET_RB) and c:IsLinkMonster() and c:IsFaceup() and (lg:IsContains(c) or c:GetLinkedGroup():IsContains(ec))
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsMainPhase(1-tp) and Duel.IsExistingMatchingCard(s.desconfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c,c:GetLinkedGroup())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0
		and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		and tc:IsControler(1-tp) and Duel.GetControl(tc,tp) then
		--Destroy it during the End Phase
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,0,0,aux.Stringid(id,2))
	end
end