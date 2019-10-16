--コンタクト・アウト
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x9}
function s.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9) and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.spfilter(c,e,tp,fc)
	return fc.material and c:IsCode(table.unpack(fc.material)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and tc:IsLocation(LOCATION_EXTRA) then
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,tc)
		if tc:CheckFusionMaterial(sg,nil,PLAYER_NONE|FUSPROC_NOTFUSION) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local mats=Duel.SelectFusionMaterial(tp,tc,sg)
			Duel.SpecialSummon(mats,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
