-- ロイヤル・ストレート・スラッシャー
-- Royal Straight Slasher
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Must be Special Summoned by "Royal Straight"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- Destroy all opponent cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- Special Summon up to 3 LIGHT Warrior monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={100290002,CARD_JACK_KNIGHT,CARD_QUEEN_KNIGHT,CARD_KING_KNIGHT}
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_JACK_KNIGHT)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_QUEEN_KNIGHT)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_KING_KNIGHT)
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsLevelAbove(1) and c:IsLevelBelow(5) and c:IsAbleToGrave()
end
function s.tgrescon(sg)
	local res=#sg==sg:GetClassCount(Card.GetLevel)
	return res,not res
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then
		if #dg<1 then return false end
		local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		return #tg>4 and aux.SelectUnselectGroup(tg,e,tp,5,5,s.tgrescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,5,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if #g<5 then return end
	local tg=aux.SelectUnselectGroup(g,e,tp,5,5,s.tgrescon,1,tp,HINTMSG_TOGRAVE)
	if #tg==5 and Duel.SendtoGrave(tg,REASON_EFFECT)>0 then
		local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		if #dg<1 then return end
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	local ft=math.min(3,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end