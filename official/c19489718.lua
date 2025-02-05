--魔鍵銃－バトスバスター
--Magikey Mechmusket - Batosbuster
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Add 1 "Magikey" card from your Deck to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsRitualSummoned() end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Place cards on bottom of Deck to negate effects of attacking monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DISABLE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MAGIKEY}
function s.thfilter(c)
	return c:IsSetCard(SET_MAGIKEY) and c:IsAbleToHand()
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
function s.atkfilter(c)
	return c:IsMonster() and (c:IsType(TYPE_NORMAL) or c:IsSetCard(SET_MAGIKEY))
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_GRAVE,0,nil)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsFaceup() then
		local att=0
		for gc in g:Iter() do
			att=att|gc:GetAttribute()
		end
		return not bc:IsStatus(STATUS_DISABLED) and bc:GetAttribute()&att~=0
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	local tc=e:GetHandler():GetBattleTarget()
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #hg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,#hg,nil)
	if #g>0 and Duel.SendtoDeck(g,tp,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==#g
		and tc and tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(1-tp)
		and not tc:IsImmuneToEffect(e) and not tc:IsStatus(STATUS_DISABLED) then
		--Negate its effects, then draw cards equal to the number of cards placed under the Deck
		tc:NegateEffects(c,RESETS_STANDARD_PHASE_END)
		Duel.BreakEffect()
		Duel.Draw(tp,#g,REASON_EFFECT)
	end 
end