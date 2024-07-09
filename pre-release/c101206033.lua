--殺戮聖徒レジーナ
--Azamina Moa Regina
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 Illusion monster + 1 Level 6 or higher Fiend monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ILLUSION),s.matfilter)
	--Special Summon 1 Illusion monster from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Destroy up to 2 cards on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_AZAMINA,SET_SINFUL_SPOILS}
function s.matfilter(c,fc,sumtype,tp)
	return c:IsLevelAbove(6) and c:IsRace(RACE_FIEND,fc,sumtype,tp)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local trig_code1,trig_code2,trig_setcodes=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2,CHAININFO_TRIGGERING_SETCODES)
	if trig_code1==id or trig_code2==id then return false end
	for _,setcode in ipairs(trig_setcodes) do
		if (SET_AZAMINA&0xfff)==(setcode&0xfff) and (SET_AZAMINA&setcode)==SET_AZAMINA then return true end
		if (SET_SINFUL_SPOILS&0xfff)==(setcode&0xfff) and (SET_SINFUL_SPOILS&setcode)==SET_SINFUL_SPOILS then return true end
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end