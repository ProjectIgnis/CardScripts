--ガガガマジシャン－ガガガマジック
--Gagaga Magician - Gagaga Magic
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand: You can Special Summon both it and 1 other "Zubaba", "Gagaga", "Gogogo", or "Dododo" monster from your hand or GY, except "Gagaga Magician - Gagaga Magic", and if you do, immediately after this effect resolves, Xyz Summon 1 "Zubaba", "Gagaga", "Gogogo", "Dododo", "Djinn", "Heroic Champion", "Number", "ZW -", or "ZS -" Xyz Monster using only those 2 monsters. When you do, treat the Level of 1 of the monsters the same as the other monster's
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ZUBABA,SET_GAGAGA,SET_GOGOGO,SET_DODODO,SET_DJINN,SET_HEROIC_CHAMPION,SET_NUMBER,SET_ZW,SET_ZS}
s.listed_names={id}
local function samexyzlevel(handler,mc,lv)
	--When you do, treat the Level of 1 of the monsters the same as the other monster's
	local e1=Effect.CreateEffect(handler)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	mc:RegisterEffect(e1,true)
	return e1
end
function s.handgyspfilter(c,e,tp,mc)
	if c:IsCode(id) then return false end
	if not (c:IsSetCard({SET_ZUBABA,SET_GAGAGA,SET_GOGOGO,SET_DODODO}) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	local e1=samexyzlevel(c,c,mc:GetLevel())
	local e2=samexyzlevel(c,mc,c:GetLevel())
	local res=Duel.IsExistingMatchingCard(s.extraspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,Group.FromCards(mc,c))
	if e1 then e1:Reset() end
	if e2 then e2:Reset() end
	return res
end
function s.extraspfilter(c,e,tp,mg)
	return c:IsSetCard({SET_ZUBABA,SET_GAGAGA,SET_GOGOGO,SET_DODODO,SET_DJINN,SET_HEROIC_CHAMPION,SET_NUMBER,SET_ZW,SET_ZS})
		and c:IsXyzMonster() and c:IsXyzSummonable(nil,mg,2,2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>=2
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.handgyspfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,c,e,tp,c) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.GetMZoneCount(tp)>=2) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.handgyspfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp,c):GetFirst()
	if not sc then return end
	local g=Group.FromCards(c,sc)
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==2 then
		local e1=samexyzlevel(c,c,sc:GetLevel())
		local e2=samexyzlevel(c,sc,c:GetLevel())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=Duel.SelectMatchingCard(tp,s.extraspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g):GetFirst()
		if xyz then
			Duel.XyzSummon(tp,xyz,g,nil,2,2)
		else
			if e1 then e1:Reset() end
			if e2 then e2:Reset() end
		end
	end
end