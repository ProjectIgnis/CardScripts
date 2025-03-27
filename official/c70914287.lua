--クリバビロン
--Kuribabylon
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--SP Summon Self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--ATK/DEF Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--SP Summon Kuribohs
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCondition(s.spcon)
	c:RegisterEffect(e5)
end
s.listed_names={44632120,71036835,7021574,34419588,CARD_KURIBOH}
s.listed_series={SET_KURIBOH}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)>Duel.GetMatchingGroupCount(Card.IsMonster,1-tp,LOCATION_GRAVE,0,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.atkfilter(c)
	return c:IsSetCard(SET_KURIBOH) and c:IsMonster() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_MZONE|LOCATION_GRAVE,0,nil)*300
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() and Duel.GetCurrentChain()==0
end
function s.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local locs=LOCATION_GRAVE|LOCATION_HAND
	if chk==0 then
		return c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>=5
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,locs,0,1,nil,e,tp,44632120)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,locs,0,1,nil,e,tp,71036835)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,locs,0,1,nil,e,tp,7021574)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,locs,0,1,nil,e,tp,34419588)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,locs,0,1,nil,e,tp,CARD_KURIBOH)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,5,tp,locs)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<5 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		local locs=LOCATION_GRAVE|LOCATION_HAND
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,locs,0,nil,e,tp,44632120)
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,locs,0,nil,e,tp,71036835)
		local g3=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,locs,0,nil,e,tp,7021574)
		local g4=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,locs,0,nil,e,tp,34419588)
		local g5=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,locs,0,nil,e,tp,CARD_KURIBOH)
		if #g1>0 and #g2>0 and #g3>0 and #g4>0 and #g5>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg1=g1:Select(tp,1,1,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg2=g2:Select(tp,1,1,nil)
			sg1:Merge(sg2)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg3=g3:Select(tp,1,1,nil)
			sg1:Merge(sg3)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg4=g4:Select(tp,1,1,nil)
			sg1:Merge(sg4)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg5=g5:Select(tp,1,1,nil)
			sg1:Merge(sg5)
			Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
end