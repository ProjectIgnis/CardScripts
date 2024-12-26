--ツルプルプルン
--Tsuru-Puru-Purun
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,1<<c:GetSequence())>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MMZONE) and chkc:IsControler(tp) and s.spfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MMZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MMZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsControler(tp)) then return end
	local seq=tc:GetSequence()
	local c=e:GetHandler()
	if Duel.Destroy(tc,REASON_EFFECT)>0 and c:IsRelateToEffect(e)
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,1<<seq)>0 then
		local g=c:GetColumnGroup():Filter(aux.FaceupFilter(Card.IsControler,1-tp),nil)
		if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end
end