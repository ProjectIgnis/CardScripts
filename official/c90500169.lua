--レベルダウン！？
--Level Down!?
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x41}
function s.filter(c,e,tp,ft)
	if c:IsFacedown() or not c:IsSetCard(0x41) or not c:IsAbleToDeck() or (ft<=0 and c:GetSequence()>=5) then return false end
	local op=c:GetOwner()
	local locct=Duel.GetLocationCount(op,LOCATION_MZONE)
	local cp=c:GetControler()
	if op==cp and locct<=-1 then return false end
	if op~=cp and locct<=0 then return false end
	local class=c:GetMetatable(true)
	return class and class.LVnum~=nil and class.LVset~=nil and Duel.IsExistingMatchingCard(s.spfilter,op,LOCATION_GRAVE,0,1,nil,class,e,tp,op)
end
function s.spfilter(c,oclass,e,tp,op)
	local class=c:GetMetatable(true)
	return class.LVnum~=nil and class.LVnum<oclass.LVnum and class.LVset==oclass.LVset and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,op)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp,ft) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,ft)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local op=tc:GetOwner()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)==0 then return end
	if Duel.GetLocationCount(op,LOCATION_MZONE)<=0 then return end
	local class=c:GetMetatable(true)
	if class==nil or class.LVnum==nil or class.LVset==nil then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,op,LOCATION_GRAVE,0,1,1,nil,class,e,tp,op)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,op,true,false,POS_FACEUP)
	end
end
