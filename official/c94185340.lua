--サクリファイス・ランクアップ
--Sacrifice Level-Up
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Banish 2 Xyz materials and Special Summon 1 Xyz mnster from the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsType(TYPE_XYZ)) then return false end
	local og=c:GetOverlayGroup()
	return og:IsExists(Card.IsAbleToRemove,2,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRank()+1)
end
function s.spfilter(c,e,tp,rank)
	return c:IsType(TYPE_XYZ) and c:IsRank(rank)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g:GetFirst():GetOverlayGroup(),2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local og=tc:GetOverlayGroup()
	if #og<2 then return end
	local rank=tc:GetRank()+1
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=og:FilterSelect(tp,Card.IsAbleToRemove,2,2,nil)
	if Duel.Remove(rg,nil,REASON_EFFECT)==2 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,rank) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,rank):GetFirst()
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
			--Cannot attack this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3206)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			sc:RegisterEffect(e1,true)
		end
	end
end