--天雷震龍－サンダー・ドラゴン
--Thunder Dragonlord
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Special summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Targeted thunder monster cannot be targeted by opponent's card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tgcon)
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--Send 1 "Thunder Dragon" card from deck to GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.gycon)
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
	--Check if a thunder monster's effect was activated in hand
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
s.listed_series={SET_THUNDER_DRAGON}
function s.chainfilter(re,tp,cid)
	return not (re:IsMonsterEffect() and re:GetHandler():IsRace(RACE_THUNDER)
		and (Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_HAND))
end
function s.spfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsLevelBelow(8) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return (Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)~=0 or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,c)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
end
function s.tgcheck(sg,e,tp)
	return sg:IsExists(Card.IsRace,1,nil,RACE_THUNDER)
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.tgcheck,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.tgcheck,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsRace(RACE_THUNDER) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsRace,RACE_THUNDER),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsRace,RACE_THUNDER),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Cannot be targeted by opponent's card effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetDescription(3061)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.gyfilter(c)
	return c:IsSetCard(SET_THUNDER_DRAGON) and c:IsAbleToGrave()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end