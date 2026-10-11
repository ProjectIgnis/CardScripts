--無垢なる血盟 ドゥームズ
--Ars Magna DoomZ
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 monsters, including an "Ars Magna" or "DoomZ" monster
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	--Any monster destroyed by battle with your linked monster is banished
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c)
		return c:IsLinked()
	end)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--During your Main Phase: You can destroy, or banish, 1 card you control, then you can shuffle up to 2 cards from any GY(s) into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.desbantg)
	e2:SetOperation(s.desbanop)
	c:RegisterEffect(e2)
	--You can banish this card from your GY; Special Summon 1 "DoomZ" monster from your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ARS_MAGNA,SET_DOOMZ}
s.material_setcode={SET_ARS_MAGNA,SET_DOOMZ}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,{SET_ARS_MAGNA,SET_DOOMZ},lc,sumtype,tp)
end
function s.desbantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_EITHER,LOCATION_GRAVE)
end
function s.desbanop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	local option_1=true
	local option_2=sc:IsAbleToRemove()
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,3)},
		{option_2,aux.Stringid(id,4)})
	if (choice==1 and Duel.Destroy(sc,REASON_EFFECT)>0) or (choice==2 and Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)>0) then
		if choice==2 and not (sc:IsLocation(LOCATION_REMOVED) or sc:IsType(TYPE_TOKEN)) then return end
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.BreakEffect()
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DOOMZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end