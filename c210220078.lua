--HDi・シンクロ
--Dimension Synchro
--Created and scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.matfilter(c)
	return c:IsCanBeSynchroMaterial()
		and (c:IsFaceup() or not c:IsLocation(LOCATION_ONFIELD))
		and (c:IsPreviousLocation(LOCATION_ONFIELD) or not c:IsLocation(LOCATION_GRAVE))
end
function s.filter(c,e,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(c:GetLevel()*2)
	c:RegisterEffect(e1)
	local res=c:IsSynchroSummonable(nil,mg)
	e1:Reset()
	return res
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.CheckLPCost(tp,1500)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg) end
	Duel.PayLPCost(tp,1500)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local tc=e:GetLabelObject()
	if not tc:IsLocation(LOCATION_EXTRA) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(tc:GetLevel()*2)
	tc:RegisterEffect(e1)
	if not tc:IsSynchroSummonable(nil,mg) then return end
	Auxiliary.SynchroSend=2
	Duel.SynchroSummon(tp,tc,nil,mg)
	Auxiliary.SynchroSend=0
	e1:Reset()
end
