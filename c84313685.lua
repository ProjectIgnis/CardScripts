--ヴァイロン・テセラクト
local s,id=GetID()
function s.initial_effect(c)
	aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x30),true,false)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.gspcon)
	e1:SetTarget(s.gsptg)
	e1:SetOperation(s.gspop)
	c:RegisterEffect(e1)
end
s.listed_series={0x30}
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.IsUnionState(e) and e:GetHandler():GetEquipTarget()==eg:GetFirst()
end
function s.gfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x30) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
