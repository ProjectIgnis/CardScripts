--クリスタル・クラウド・ドラゴン
--Krystal Cloud Dragon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If you control no monsters, or all monsters you control mention "Endless Darkness": You can Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	-- If this card is Normal or Special Summoned: You can add 1 monster that mentions "Endless Darkness" from your Deck to your hand, except a Level 6 monster, or if you have a banished "Blue-Eyes" monster, you can add 2 such monsters with different Attributes from each other instead
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetTarget(s.thtg)
	e2a:SetOperation(s.thop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end
s.listed_names={CARD_ENDLESS_DARKNESS}
s.listed_series={SET_BLUE_EYES}
function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.NOT(aux.FaceupFilter(Card.ListsCode,CARD_ENDLESS_DARKNESS)),tp,LOCATION_MZONE,0,1,nil)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thfilter(c)
	return c:IsMonster() and c:ListsCode(CARD_ENDLESS_DARKNESS) and not c:IsLevel(6) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.blueyesfilter(c)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsMonster() and c:IsFaceup()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local max_number=Duel.IsExistingMatchingCard(s.blueyesfilter,tp,LOCATION_REMOVED,0,1,nil) and 2 or 1
		local thg=aux.SelectUnselectGroup(g,e,tp,1,max_number,aux.dpcheck(Card.GetAttribute),1,tp,HINTMSG_ATOHAND)
		if #thg==0 then return end
		Duel.SendtoHand(thg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,thg)
	end
end