--霊獣の騎襲
--Ritual Beast Ambush
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x10b5,0x20b5,0xb5}
function s.filter1(c,e,tp)
	return c:IsSetCard(0x10b5) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c,e,tp)
end
function s.filter2(c,e,tp)
	return c:IsSetCard(0x20b5) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if #g<=ft then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,ft,ft,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			g:Sub(sg)
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.splimit(e,c)
	return not c:IsSetCard(0xb5)
end
