--エクストラ・シェイブ・リボーン
--Extra Shave Reborn
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.prefilter(c,tp)
	return c:IsPreviousControler(tp) and (c:GetPreviousTypeOnField()&TYPE_MONSTER)==TYPE_MONSTER and c:HasLevel() 
		and (c:GetOriginalType()&TYPE_EXTRA)==TYPE_EXTRA
end
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	local cg=eg:Filter(s.prefilter,nil,tp)
	local rg,lv=cg:GetMaxGroup(Card.GetLevel)
	if #cg==0 or #rg==0 then return false end
	e:SetLabel(lv)
	return #cg>0
end
function s.spfilter(c,e,tp,lv)
	return (c:GetOriginalType()&TYPE_EXTRA)==TYPE_EXTRA and c:HasLevel() and c:GetLevel()<lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	local lv=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,lv) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,#tg,0,0)
end
function s.activate(e,tp,eg,ev,ep,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
