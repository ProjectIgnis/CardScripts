--古の秘儀
--Ancient Secrets
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Normal Monster from your hand, Deck, or GY in Defense Position (if you Special Summon from the Deck, it must be Level 4 or lower), or if you control a Normal Monster Card, you can apply 1 of these effects instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (c:IsLevelBelow(4) or not c:IsLocation(LOCATION_DECK))
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local monster_card_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsOriginalType,TYPE_NORMAL),tp,LOCATION_ONFIELD,0,1,nil)
	if chk==0 then
		if mmz_chk and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) then return true end
		return monster_card_chk and (Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 or Duel.IsPlayerCanDraw(tp,2)
			or (mmz_chk and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,0,tp,false,false)))
	end
	if not monster_card_chk then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,2)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local op=nil
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsOriginalType,TYPE_NORMAL),tp,LOCATION_ONFIELD,0,1,nil) then
		local b1=mmz_chk and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)
		local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		local b3=Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,nil)
		local b4=Duel.IsPlayerCanDraw(tp,2)
		local b5=mmz_chk and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,0,tp,false,false)
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)},
			{b3,aux.Stringid(id,3)},
			{b4,aux.Stringid(id,4)},
			{b5,aux.Stringid(id,5)})
	else
		op=1
	end
	if op==1 then
		--Special Summon 1 Normal Monster from your hand, Deck, or GY in Defense Position (if you Special Summon from the Deck, it must be Level 4 or lower)
		if not mmz_chk then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	elseif op==2 then
		--● Destroy all monsters your opponent controls
		local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==3 then
		--● Destroy all Spells/Traps your opponent controls
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==4 then
		--● Draw 2 cards
		Duel.Draw(tp,2,REASON_EFFECT)
	elseif op==5 then
		--● Special Summon 1 monster from either GY to your field
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,0,tp,false,false)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end