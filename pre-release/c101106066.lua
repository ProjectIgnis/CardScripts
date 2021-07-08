--天斗輝巧極
--Ursarctic Drytron
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Banish replace
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(CARD_URSARCTIC_BIG_DIPPER)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.repcon)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(CARD_URSARCTIC_DRYTRON)
	c:RegisterEffect(e3)
end
s.listed_names={101106040,89264428,58793369,27693363,97148796}
s.listed_series={0x165,0x151}
function s.rmfilter(c)
	return c:IsCode(89264428,58793369) and c:IsAbleToRemove()
		and (c:IsFaceup() or not c:IsOnField())
end
function s.excheck(tp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,27693363,97148796),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.spfilter(c,e,tp,sg)
	return c:IsCode(101106040) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0 
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==2 and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND | LOCATION_ONFIELD 
	if s.excheck(tp) then
		loc = loc | LOCATION_DECK 
	end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,loc,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_HAND | LOCATION_ONFIELD 
	if s.excheck(tp) then
		loc = loc | LOCATION_DECK 
	end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,loc,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,1,tp,HINTMSG_REMOVE)
	if #sg==2 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if tc then
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end 
end
function s.repcon(e)
	return e:GetHandler():IsAbleToRemoveAsCost()
end
function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x165) or c:IsSetCard(0x151)) and (not extracon or extracon(base,c,e,tp,eg,ep,ev,re,r,rp,chk))
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Remove(base:GetHandler(),POS_FACEUP,REASON_COST+REASON_REPLACE)
end