--魅惑の舞
--Allure Dance
--Scripted by AlphaKretin
local s,id=GetID()
local SET_ALLURE_QUEEN=0x14
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ALLURE_QUEEN))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--must attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_MUST_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	c:RegisterEffect(e3)
	--choose atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e3:SetCondition(s.atkcon)
	c:RegisterEffect(e4)
	--special summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(122520,0)) --needs changing
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,id)
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_ALLURE_QUEEN}
function s.eqfilter(c,code)
	return c:GetFlagEffect(code)~=0
end
function s.atkval(e,c)
	return c:GetEquipGroup():Filter(s.eqfilter,nil,c:GetOriginalCode()):GetSum(Card.GetAttack)
end
s.aqfilter=aux.FilterFaceupFunction(Card.IsSetCard,SET_ALLURE_QUEEN)
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(s.aqfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
s.oaqfilter=aux.FilterFaceupFunction(Card.IsOriginalSetCard,SET_ALLURE_QUEEN)
function s.eqgroup(tp)
	local og=Group.CreateGroup()
	local tg=Duel.GetMatchingGroup(s.oaqfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(tg) do
		local eg=tc:GetEquipGroup()
		eg:Filter(s.eqfilter,nil,tc:GetOriginalCode())
		og:Merge(eg)
	end
	return og
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=s.eqgroup(tp)
	g:Filter(Card.IsAbleToGraveAsCost,nil)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:Select(tp,1,1,nil)
	Duel.SendtoGrave(tg,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ALLURE_QUEEN) and c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(#sg)(sg,e,tp,mg) and sg:GetClassCount(Card.GetCode)==#sg
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=math.min(ft,g:GetClassCount(Card.GetCode))
	if chk==0 then return ct>0 and 
		aux.SelectUnselectGroup(g,e,tp,ct,ct,s.rescon,chk) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=math.min(ft,g:GetClassCount(Card.GetCode))
	if ct<1 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,s.rescon,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end