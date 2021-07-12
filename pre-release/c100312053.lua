-- 天空の聖水
-- The Sacred Water of the Sky
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Activate "The Sanctuary in the Sky" or search a monster that lists it
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.acthtg)
	e1:SetOperation(s.acthop)
	c:RegisterEffect(e1)
	-- Banish self from GY to replace destruction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_series={0x44,0x269}
s.listed_names={CARD_SANCTUARY_SKY}
function s.acfilter(c,tp)
	return c:IsCode(CARD_SANCTUARY_SKY) and c:GetActivateEffect()
		and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.thfilter(c)
	return c:IsMonster() and aux.IsCodeListed(c,CARD_SANCTUARY_SKY) and c:IsAbleToHand()
end
function s.acthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp)
			or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function s.lpfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x44) or c:IsSetCard(0x269))
end
function s.acthop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp)
	local th=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- Choose effect to apply
	local op
	if ac and th then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif ac then 
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif th then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1 
	end
	-- Apply chosen effect
	local gainlp=nil
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then gainlp=aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) end
	elseif op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			gainlp=Duel.SendtoHand(g,nil,REASON_EFFECT)>0
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- Gain LP
	if gainlp and (Duel.IsEnvironment(CARD_SANCTUARY_SKY) 
		or Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_SANCTUARY_SKY),0,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil))
		and Duel.IsExistingMatchingCard(s.lpfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Recover(tp,Duel.GetMatchingGroupCount(s.lpfilter,tp,LOCATION_MZONE,0,nil)*500,REASON_EFFECT)
	end
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsReason(REASON_BATTLE) and aux.IsCodeListed(c,CARD_SANCTUARY_SKY)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end